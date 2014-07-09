SUMMARY = "CtaoCrypt-test check for passing Cipher suites"
DESCRIPTION = "CyaSSL is a lightweight SSL library written in C and \
               optimized for embedded and RTOS environments. It can be \
               Up to 20 times smaller than OpenSSL while still supporting \
               a full TLS 1.2 client and server."
HOMEPAGE = "http://www.yassl.com/yaSSL/Products-cyassl.html"
BUGTRACKER = "http://github.com/cyassl/cyassl/issues"
SECTION = "x11/applications"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://../test.c;beginline=1;endline=22;md5=f747246cd0a9af15bafdfc72dba9d540"

PR = "r1"

SRC_URI = "file://test.c"

SRC_URI[md5sum] = "f747246cd0a9af15bafdfc72dba9d540"
SRC_URI[sha256sum] = "3e5e95a74ac1d58d8b1eb00e063556219905e096d2235e53d78b73035299c29a"

S = "${WORKDIR}/${PN}-${PV}" 

do_compile() {
    ${CC} ${CFLAGS} -DNO_RABBIT -DNO_MD4 -DNO_DSA -DNO_PWDBASED -Wall -o test ${WORKDIR}/test.c -lcyassl ${LDFLAGS} -I ${WORKDIR}/test.h 
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/test ${D}${bindir}
}
