SUMMARY = "wolfProvider is a Proivder designed for Openssl 3.X.X"
DESCRIPTION = "wolfProvider is a library that can be used as an Provider in OpenSSL"
HOMEPAGE = "https://github.com/wolfSSL/wolfProvider"
BUGTRACKER = "https://github.com/wolfSSL/wolfProvider/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"
DEPENDS += "util-linux-native"

PROVIDES += "wolfprovider"
RPROVIDES_${PN} = "wolfprovider"

SRC_URI = "git://github.com/wolfssl/wolfProvider.git;protocol=https;tag=v1.1.0"

DEPENDS += " wolfssl \
            openssl \
            "

inherit autotools pkgconfig

S = "${WORKDIR}/git"
OPENSSL_YOCTO_DIR = "${COMPONENTS_DIR}/${PACKAGE_ARCH}/openssl/usr"

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
EXTRA_OECONF += " --with-openssl=${OPENSSL_YOCTO_DIR}"
