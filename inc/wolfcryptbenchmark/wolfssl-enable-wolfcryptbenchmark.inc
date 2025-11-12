# Configuration to enable wolfcryptbenchmark support in wolfssl
EXTRA_OECONF += "--enable-crypttests"

python () {
    files_var = 'FILES:' + d.getVar('PN')
    d.appendVar(files_var, ' ${bindir}/wolfcryptbenchmark')
}

do_install:append() {
    bbnote "Installing wolfCrypt Benchmarks"
    if [ ! -x "${B}/wolfcrypt/benchmark/.libs/benchmark" ]; then
        bbwarn "wolfCrypt benchmark binary missing at ${B}/wolfcrypt/benchmark/.libs/benchmark"
        return
    fi

    install -Dm0755 "${B}/wolfcrypt/benchmark/.libs/benchmark" "${D}${bindir}/wolfcryptbenchmark"
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DBENCH_EMBEDDED"
