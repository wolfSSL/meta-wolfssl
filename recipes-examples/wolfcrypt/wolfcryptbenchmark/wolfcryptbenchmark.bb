SUMMARY = "wolfCrypt Benchmark Application"
DESCRIPTION = "wolfCrypt benchmark application used to benchmark crypto \
               algorithms included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

FILESEXTRAPATHS:prepend := "${THISDIR}:"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://benchmark.c;beginline=1;endline=20;md5=aca0c406899b7421c67598ba3f55d1a5"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfSSL/wolfssl.git;nobranch=1;protocol=https;rev=66596ad9e1d7efa8479656872cf09c9c1870a02e"

S = "${WORKDIR}/git/wolfcrypt/benchmark"

do_configure[noexec] = "1"
do_compile[noexec] = "1"
do_install() {
    install -d ${D}${datadir}/wolfcrypt-benchmark
    echo "This is a dummy package" > ${D}${datadir}/wolfcrypt-benchmark/README.txt
}

FILES:${PN} += "${datadir}/wolfcrypt-benchmark/*"
