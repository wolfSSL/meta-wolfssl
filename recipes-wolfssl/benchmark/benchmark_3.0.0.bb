SUMMARY = "Benchmark application to determine SSL performance with CyaSSL"
DESCRIPTION = "CyaSSL is a lightweight SSL library written in C and \
               optimized for embedded and RTOS environments. It can be \
               Up to 20 times smaller than OpenSSL while still supporting \
               a full TLS 1.2 client and server."
HOMEPAGE = "http://www.yassl.com/yaSSL/Products-cyassl.html"
BUGTRACKER = "http://github.com/cyassl/cyassl/issues"
SECTION = "libs/network"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://benchmark.c;beginline=1;endline=22;md5=8ec78656ef85d2a41baf7762ee937771"

PR = "r1"

SRC_URI = "file://benchmark.c"

SRC_URI[md5sum] = "ddcc220b6eac7a34b7435234388c7bf9"
SRC_URI[sha256sum] = "9ee6a58400bb63efcd78195e1b55502bd17d809016dfb122d1cfc6400e0b35d8"

S = "${WORKDIR}/${PN}-${PV}" 

do_compile() {
    clang -DNO_RABBIT -Wall -o benchmark /home/leah/wolfSSL/cyassl/ctaocrypt/benchmark/benchmark.c -lcyassl 
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 benchmark ${D}${bindir}
}
