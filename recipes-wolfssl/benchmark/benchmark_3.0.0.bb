SUMMARY = "Benchmark application to determine SSL performance with CyaSSL"
DESCRIPTION = "CyaSSL is a lightweight SSL library written in C and \
               optimized for embedded and RTOS environments. It can be \
               Up to 20 times smaller than OpenSSL while still supporting \
               a full TLS 1.2 client and server."
HOMEPAGE = "http://www.yassl.com/yaSSL/Products-cyassl.html"
BUGTRACKER = "http://github.com/cyassl/cyassl/issues"
SECTION = "x11/applications"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://../benchmark.c;beginline=1;endline=22;md5=8ec78656ef85d2a41baf7762ee937771"

PR = "r1"

SRC_URI = "file://benchmark.c"

SRC_URI[md5sum] = "f8a52bd3d5951ef116614c8c33b44e97"
SRC_URI[sha256sum] = "204427833d78a98d54728b3af52dca0ef58dcbea1f1cdfa8ef9c46e828086515"

S = "${WORKDIR}/${PN}-${PV}" 

#PACKAGE_ARCH = "i586"
#TARGET_ARCH = "i586"

do_compile() {
    clang -DNO_RABBIT -Wall -o benchmark /home/leah/wolfSSL/meta-wolfssl/recipes-wolfssl/benchmark/files/benchmark.c -lcyassl 
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/benchmark ${D}${bindir}
}
