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

DEPENDS += " virtual/wolfssl \
            openssl \
            "

inherit autotools pkgconfig wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl openssl')
}

CFLAGS += " -I${S}/include -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS += " -I${S}/include  -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS += " -Wl,--build-id=none"
EXTRA_OECONF += " --with-openssl=${STAGING_EXECPREFIXDIR} --with-wolfssl=${STAGING_EXECPREFIXDIR} "