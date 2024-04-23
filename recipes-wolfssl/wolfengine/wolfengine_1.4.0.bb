SUMMARY = "wolfEngine is a cryptography engine for openSSL versions 1.X.X"
DESCRIPTION = "wolfEngine is an OpenSSL 1.X.X engine backed by wolfSSL's wolfCrypt cryptography library."
HOMEPAGE = "https://github.com/wolfSSL/wolfEngine"
BUGTRACKER = "https://github.com/wolfSSL/wolfEngine/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"
DEPENDS += "util-linux-native"

PROVIDES += "wolfengine"

SRC_URI = "git://github.com/wolfssl/wolfengine.git;nobranch=1;protocol=https;rev=02c18e78d59c1e5a029c171a3879e99a145737ca"


S = "${WORKDIR}/git"

DEPENDS += " wolfssl \
            openssl \
            "

inherit autotools pkgconfig

OPENSSL_YOCTO_DIR = "${COMPONENTS_DIR}/${PACKAGE_ARCH}/openssl/usr"
WOLFSSL_YOCTO_DIR = "${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"


# Approach: Use Python to dynamically set function content based on Yocto version
python() {
    distro_version = d.getVar('DISTRO_VERSION', True)
    autogen_command = "cd ${S}; ./autogen.sh"
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        # For Dunfell and earlier
        d.appendVar('do_configure_prepend', autogen_command)
    else:
        # For Kirkstone and later
        d.appendVar('do_configure:prepend', autogen_command)
}

CFLAGS += " -I${S}/include -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS += " -I${S}/include  -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS += " -Wl,--build-id=none"
EXTRA_OECONF += " --with-openssl=${OPENSSL_YOCTO_DIR} --with-wolfssl=${WOLFSSL_YOCTO_DIR} "