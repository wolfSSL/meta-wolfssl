SUMMARY = "wolfCrypt Test Application"
DESCRIPTION = "wolfCrypt test application used to test crypto algorithm \
               functionality included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

FILESEXTRAPATHS_prepend := "${THISDIR}:"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://test.c;beginline=1;endline=20;md5=06bc446ac36836d5b8686af43528e799"

DEPENDS += "wolfssl"

SRC_URI[md5sum] = "e63ee2efe3f8847c0ada4b884a408715"
SRC_URI[sha256sum] = "ec1cf65283bfaf9433b7f937dd8ab8aa54d7691e6646e5f3b84aea034d1d3b1e"
SRC_URI = "file://test.c file://test.h"

S = "${WORKDIR}"

do_compile() {
    ${CC} ${CFLAGS} -DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DUSE_FLAT_TEST_H -Wall -include wolfssl/options.h -o wolfcrypttest ${WORKDIR}/test.c -lwolfssl ${LDFLAGS}
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/wolfcrypttest ${D}${bindir}
}

