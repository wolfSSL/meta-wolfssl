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

SRC_URI = "git://github.com/wolfssl/wolfProvider.git;nobranch=1;protocol=https;rev=f8f432408f2c6f446a9e5bd9330577d2c2e1ed4f"

DEPENDS += " virtual/wolfssl \
            openssl \
            "

RDEPENDS:${PN} += "wolfssl openssl"

inherit autotools pkgconfig wolfssl-helper

S = "${WORKDIR}/git"

CFLAGS += " -I${S}/include -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS += " -I${S}/include  -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS += " -Wl,--build-id=none"
EXTRA_OECONF += " --with-openssl=${STAGING_EXECPREFIXDIR}"