SUMMARY = "wolfSSL FIPS Linux kernel module (libwolfssl.ko)"
DESCRIPTION = "Out-of-tree Linux kernel module for wolfSSL/wolfCrypt with FIPS 140-3 validation"
LICENSE = "CLOSED"
WOLFSSL_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2024.pdf"
WOLFSSL_LICENSE_MD5 ?= "9b56a02d020e92a4bd49d0914e7d7db8"
LIC_FILES_CHKSUM = "file://${WOLFSSL_LICENSE};md5=${WOLFSSL_LICENSE_MD5}"
DEPENDS += "virtual/kernel openssl-native"

# This recipe provides:
# - wolfssl-linuxkm-fips (automatic from recipe name)
# - virtual/wolfssl-linuxkm (build-time interface for switching implementations)
# At runtime, the wolfssl-linuxkm-fips package provides wolfssl-linuxkm to satisfy package dependencies
PROVIDES += "wolfssl-linuxkm-fips virtual/wolfssl-linuxkm"

# Build for target kernel
inherit module-base wolfssl-helper autotools wolfssl-commercial wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RPROVIDES', '${PN}', ' wolfssl-linuxkm')
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/libwolfssl.ko')
    wolfssl_varAppend(d, 'FILES', '${PN}-dbg', ' ${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/.debug')
    wolfssl_varAppend(d, 'INSANE_SKIP', '${PN}', ' buildpaths debug-files')
    wolfssl_varAppend(d, 'INSANE_SKIP', '${PN}-dbg', ' buildpaths')
}

# Lower preference so regular wolfssl-linuxkm is default
# Users must explicitly set PREFERRED_PROVIDER_virtual/wolfssl-linuxkm = "wolfssl-linuxkm-fips"
DEFAULT_PREFERENCE = "-1"

# Use the same commercial FIPS bundle as user-mode wolfssl
# These come from wolfssl-fips.conf (WOLFSSL_SRC, WOLFSSL_SRC_PASS, WOLFSSL_SRC_SHA)
# Users can set WOLFSSL_SRC_DIR in local.conf to specify bundle location
# Users can set WOLFSSL_SRC_DIRECTORY in local.conf to point directly to extracted source
WOLFSSL_SRC_DIR ?= "${@os.path.dirname(d.getVar('FILE', True))}/commercial/files"
WOLFSSL_SRC_DIRECTORY ?= ""
WOLFSSL_BUNDLE_FILE ?= ""
WOLFSSL_BUNDLE_GCS_URI ?= ""
WOLFSSL_BUNDLE_GCS_TOOL ?= ""
COMMERCIAL_BUNDLE_DIR     = "${WOLFSSL_SRC_DIR}"
COMMERCIAL_BUNDLE_NAME    = "${WOLFSSL_SRC}"
COMMERCIAL_BUNDLE_FILE    = "${WOLFSSL_BUNDLE_FILE}"
COMMERCIAL_BUNDLE_PASS    = "${WOLFSSL_SRC_PASS}"
COMMERCIAL_BUNDLE_SHA     = "${WOLFSSL_SRC_SHA}"
COMMERCIAL_BUNDLE_TARGET  = "${WORKDIR}"
COMMERCIAL_BUNDLE_GCS_URI = "${WOLFSSL_BUNDLE_GCS_URI}"
COMMERCIAL_BUNDLE_GCS_TOOL = "${@d.getVar('WOLFSSL_BUNDLE_GCS_TOOL') or 'auto'}"
COMMERCIAL_BUNDLE_SRC_DIR = "${WOLFSSL_SRC_DIRECTORY}"

# Kernel module FIPS hash configuration
# WOLFSSL_FIPS_HASH_MODE_LINUXKM controls whether to use manual hash or kernel's auto-generation
# - "manual": Use FIPS_HASH_LINUXKM from config
# - "auto": Let kernel module build system handle it (extract from error on first build)
WOLFSSL_FIPS_HASH_MODE_LINUXKM ?= "manual"
FIPS_HASH_LINUXKM ?= ""

# Skip the package check for wolfssl itself (it's the base library)
deltask do_wolfssl_check_package

# Fetch the .7z bundle (or README placeholder if not configured)
SRC_URI = "${@ get_commercial_src_uri(d) }"

# Use helper functions from wolfssl-commercial.bbclass for conditional configuration
# After extraction, S points to the top directory of the bundle:
#   ${WORKDIR}/${WOLFSSL_SRC}
S = "${@ get_commercial_source_dir(d) }"
B = "${S}"

# Optional: switch to GCS/tarball flow (gs:// URI) when set
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-commercial-gcs.inc

# Build depends on the kernel
DEPENDS += "binutils-cross-${TARGET_ARCH}"

# Make sure we package the .ko
PACKAGES = "${PN} ${PN}-dbg"

# Tie package arch to machine
PACKAGE_ARCH = "${MACHINE_ARCH}"
# Set kernel arch to target arch
KERNEL_ARCH = "${@map_kernel_arch(d.getVar('TARGET_ARCH'), d)}"
EXTRA_OEMAKE += "OBJDUMP=${TARGET_PREFIX}objdump"
EXTRA_OEMAKE += "NM=${TARGET_PREFIX}nm"
EXTRA_OEMAKE += "READELF=${TARGET_PREFIX}readelf"
EXTRA_OEMAKE += "OBJCOPY=${TARGET_PREFIX}objcopy"

# configure params
EXTRA_OECONF = " \
    --enable-linuxkm \
    --enable-fips=v5.2.4 \
    --with-linux-source=${STAGING_KERNEL_BUILDDIR} \
    --enable-crypttests \
    --enable-smallstack \
    --enable-sp-math-all \
    --disable-sp \
"

python __anonymous() {
    # Pass FIPS hash as compile-time define (same approach as userspace wolfssl-fips)
    if d.getVar('WOLFSSL_FIPS_HASH_MODE_LINUXKM') == 'manual' and d.getVar('FIPS_HASH_LINUXKM'):
        hash_val = d.getVar('FIPS_HASH_LINUXKM')
        wolfssl_varAppendNonOverride(d, 'EXTRA_OEMAKE', ' KERNEL_EXTRA_CFLAGS="-DWOLFCRYPT_FIPS_CORE_HASH_VALUE=' + hash_val + '"')
}

do_configure_fips_hash_check() {
    if [ "${WOLFSSL_FIPS_HASH_MODE_LINUXKM}" = "manual" ]; then
        if [ -n "${FIPS_HASH_LINUXKM}" ]; then
            bbnote "Kernel module manual FIPS mode - hash: ${FIPS_HASH_LINUXKM}"
        else
            bbwarn "WOLFSSL_FIPS_HASH_MODE_LINUXKM=manual but FIPS_HASH_LINUXKM is not set"
        fi
    else
        bbnote "Kernel module auto FIPS mode - will use 'make module-with-matching-fips-hash-no-sign' to compute and embed the correct hash"
    fi
}

addtask do_configure_fips_hash_check after do_patch before do_configure

do_compile() {
    if [ "${WOLFSSL_FIPS_HASH_MODE_LINUXKM}" = "auto" ]; then
        bbnote "Auto FIPS hash mode: running 'make module-with-matching-fips-hash-no-sign'"
        bbnote "This will build the .ko, compute the FIPS hash, and patch it in-place."

        # The linuxkm Makefile's libwolfssl-user-build step builds a host-native
        # userspace wolfSSL library (it unsets CC/LD itself, uses host cc), but
        # Yocto's cross-compilation LDFLAGS (containing --sysroot=...) and CPPFLAGS
        # would leak through and break the host build. Unset them here — the kernel
        # module build itself goes through 'make -C $(KERNEL_ROOT)' which is
        # self-contained.
        unset LDFLAGS
        unset CPPFLAGS

        # Run from top-level source dir so that the autotools-generated Makefile
        # exports KERNEL_ROOT, KERNEL_ARCH, and other configure-derived variables
        # to the linuxkm/ sub-make. Pass HOSTCC so the patched linuxkm Makefile
        # uses the correct host-native compiler instead of bare 'cc'.
        oe_runmake module-with-matching-fips-hash-no-sign HOSTCC=$(which ${BUILD_CC})
    else
        oe_runmake
    fi
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    install -m 0644 ${S}/linuxkm/libwolfssl.ko \
        ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
}
