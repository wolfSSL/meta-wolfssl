SUMMARY = "wolfSSL Linux kernel module (libwolfssl.ko)"
DESCRIPTION = "Out-of-tree Linux kernel module for wolfSSL/wolfCrypt"
LICENSE = "GPL-3.0-only"
DEPENDS += "virtual/kernel openssl-native"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

# Build for target kernel
inherit module-base autotools wolfssl-helper

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
do_install:append() {
    install -d ${D}/etc/modules-load.d
    echo "libwolfssl" > ${D}/etc/modules-load.d/wolfssl.conf
}

RDEPENDS:${PN} = ""

# Provide alias so both names work
RPROVIDES:${PN} = "kernel-module-libwolfssl"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

FILES:${PN} = "${nonarch_base_libdir}/modules \
               ${sysconfdir}/modules-load.d"

# Skip package QA warnings for kernel modules
INSANE_SKIP:${PN} += "buildpaths debug-files"
