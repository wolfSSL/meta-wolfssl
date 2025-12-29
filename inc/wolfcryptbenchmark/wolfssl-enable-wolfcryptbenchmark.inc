# Configuration to enable wolfcryptbenchmark support in wolfssl

inherit wolfssl-compatibility

EXTRA_OECONF += "--enable-crypttests"

do_install_wolfcryptbenchmark() {
    if [ ! -x "${B}/wolfcrypt/benchmark/.libs/benchmark" ]; then
        bbwarn "wolfCrypt benchmark binary missing at ${B}/wolfcrypt/benchmark/.libs/benchmark"
        return
    fi

    install -Dm0755 "${B}/wolfcrypt/benchmark/.libs/benchmark" "${D}${bindir}/wolfcryptbenchmark"
}

addtask do_install_wolfcryptbenchmark after do_install before do_package
do_install_wolfcryptbenchmark[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${bindir}/wolfcryptbenchmark')
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DBENCH_EMBEDDED"
