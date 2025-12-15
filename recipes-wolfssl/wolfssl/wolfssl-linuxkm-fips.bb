SUMMARY = "wolfSSL Linux kernel module (libwolfssl.ko)"
DESCRIPTION = "Out-of-tree Linux kernel module for wolfSSL/wolfCrypt"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://WolfSSL_LicenseAgmt_JAN-2024.pdf;md5=9b56a02d020e92a4bd49d0914e7d7db8"
DEPENDS += "virtual/kernel openssl-native"

# Use the same commercial FIPS bundle as user-mode wolfssl
# These come from wolfssl-fips.conf (WOLFSSL_SRC, WOLFSSL_SRC_PASS, WOLFSSL_SRC_SHA)
# Users can set WOLFSSL_SRC_DIR in local.conf to specify bundle location
WOLFSSL_SRC_DIR ?= "${@os.path.dirname(d.getVar('FILE', True))}/commercial/files"

# Enable commercial bundle extraction only when WOLFSSL_SRC is configured
# Set BEFORE inherit so it overrides the class default
COMMERCIAL_BUNDLE_ENABLED ?= "${@'1' if d.getVar('WOLFSSL_SRC') else '0'}"
COMMERCIAL_BUNDLE_DIR     = "${WOLFSSL_SRC_DIR}"
COMMERCIAL_BUNDLE_NAME    = "${WOLFSSL_SRC}"
COMMERCIAL_BUNDLE_PASS    = "${WOLFSSL_SRC_PASS}"
COMMERCIAL_BUNDLE_SHA     = "${WOLFSSL_SRC_SHA}"
COMMERCIAL_BUNDLE_TARGET  = "${WORKDIR}"

# Build for target kernel
inherit module-base wolfssl-helper autotools wolfssl-commercial

# Skip the package check for wolfssl itself (it's the base library)
deltask do_wolfssl_check_package

# Fetch the .7z bundle (or README placeholder if not configured)
SRC_URI = "${@ get_commercial_src_uri(d) }"

# After extraction, S points to the top directory of the bundle:
#   ${WORKDIR}/${WOLFSSL_SRC}
S = "${@ get_commercial_source_dir(d) }"
B = "${S}"

# Build depends on the kernel
DEPENDS += "binutils-cross-${TARGET_ARCH}"

# Make sure we package the .ko
PACKAGES = "${PN} ${PN}-dbg"
FILES:${PN} += "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/libwolfssl.ko"
FILES:${PN}-dbg += "${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/.debug"

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
    --enable-all-crypto \
    --enable-crypttests \
"

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    install -m 0644 ${S}/linuxkm/libwolfssl.ko \
        ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
}

# Skip package QA warnings for kernel modules
INSANE_SKIP:${PN} += "buildpaths debug-files"
INSANE_SKIP:${PN}-dbg += "buildpaths"