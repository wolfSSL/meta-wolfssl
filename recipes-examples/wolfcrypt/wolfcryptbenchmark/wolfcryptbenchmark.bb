SUMMARY = "wolfCrypt Benchmark Application"
DESCRIPTION = "wolfCrypt benchmark application used to benchmark crypto \
               algorithms included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://benchmark.c;beginline=1;endline=20;md5=6a14f1f3bfbb40d2c3b7d0f3a1f98ffc"
S = "${WORKDIR}/git/wolfcrypt/benchmark"
DEPENDS += "virtual/wolfssl"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
}

SRC_URI = "git://github.com/wolfSSL/wolfssl.git;nobranch=1;protocol=https;rev=59f4fa568615396fbf381b073b220d1e8d61e4c2"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFCRYPT_BENCHMARK_DIR = "${datadir}/wolfcrypt-benchmark"
WOLFCRYPT_BENCHMARK_INSTALL_DIR = "${D}${WOLFCRYPT_BENCHMARK_DIR}"
WOLFCRYPT_BENCHMARK_README = "README.txt"
WOLFCRYPT_BENCHMARK_README_DIR = "${WOLFCRYPT_BENCHMARK_INSTALL_DIR}/${WOLFCRYPT_BENCHMARK_README}"

do_install_wolfcryptbenchmark_dummy() {
    bbnote "Installing dummy file for wolfCrypt benchmark example"
    install -m 0755 -d "${WOLFCRYPT_BENCHMARK_INSTALL_DIR}"
    echo "This is a dummy package" > "${WOLFCRYPT_BENCHMARK_README_DIR}"
}

addtask do_install_wolfcryptbenchmark_dummy after do_install before do_package
do_install_wolfcryptbenchmark_dummy[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFCRYPT_BENCHMARK_DIR}/*')
}
