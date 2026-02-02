SUMMARY = "wolfSSL Linux kernel module (libwolfssl.ko)"
DESCRIPTION = "Out-of-tree Linux kernel module for wolfSSL/wolfCrypt"
LICENSE = "GPL-3.0-only"
DEPENDS += "virtual/kernel openssl-native"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

# This recipe provides:
# - wolfssl-linuxkm (automatic from recipe name)
# - virtual/wolfssl-linuxkm (build-time interface for switching implementations)
PROVIDES += "wolfssl-linuxkm virtual/wolfssl-linuxkm"

# Build for target kernel
inherit module-base autotools wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varSet(d, 'RDEPENDS', '${PN}', '')
    wolfssl_varSet(d, 'FILES', '${PN}', '${nonarch_base_libdir}/modules ${sysconfdir}/modules-load.d')
    wolfssl_varAppend(d, 'INSANE_SKIP', '${PN}', ' buildpaths debug-files')
}

# Skip the package check for wolfssl itself (it's the base library)
deltask do_wolfssl_check_package

# Fetch wolfSSL from upstream GitHub
SRC_URI = "git://github.com/wolfSSL/wolfssl.git;protocol=https;branch=master"
SRCREV = "569a5e03882c4cdef9e99f3a4cfcee96bc25c2cb"

# After git fetch, S is the git checkout
S = "${WORKDIR}/git"

# Build in-tree; wolfSSL's configure expects linuxkm/ under the build dir
B = "${S}"

EXTRA_OECONF = " \
    --enable-linuxkm \
    --host=${HOST_SYS} \
    --build=${BUILD_SYS} \
    --with-linux-source=${STAGING_KERNEL_BUILDDIR} \
    --enable-all-crypto \
    --enable-crypttests \
"

# We use the in-tree linuxkm Kbuild rather than the standalone Makefile
do_compile() {
    # Avoid host CFLAGS interfering with kernel build
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS

    # build user mode build first
    oe_runmake
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    install -m 0644 ${S}/linuxkm/libwolfssl.ko \
        ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
}

# Remove debug directory if present
do_install_linuxkm_autoload() {
    install -d ${D}/etc/modules-load.d
    echo "libwolfssl" > ${D}/etc/modules-load.d/wolfssl.conf
}

addtask do_install_linuxkm_autoload after do_install before do_package
do_install_linuxkm_autoload[fakeroot] = "1"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
