WOLFCRYPT_BENCHMARK_DIR = "${B}/wolfcrypt/benchmark/.libs"
WOLFCRYPT_BENCHMARK = "benchmark"
WOLFCRYPT_BENCHMARK_YOCTO = "wolfcryptbenchmark"
WOLFCRYPT_INSTALL_DIR = "${D}${bindir}"

python () {
    # Get the environment variables WOLFCRYPT_BENCHMARK_DIR, WOLFCRYPT_BENCHMARK,
    #   WOLFCRYPT_BENCHMARK_YOCTO, and WOLFCRYPT_INSTALL_DIR
    wolfcrypt_benchmark_dir = d.getVar('WOLFCRYPT_BENCHMARK_DIR', True)
    wolfcrypt_benchmark = d.getVar('WOLFCRYPT_BENCHMARK', True)
    wolfcrypt_benchmark_yocto = d.getVar('WOLFCRYPT_BENCHMARK_YOCTO', True)
    wolfcrypt_install_dir = d.getVar('WOLFCRYPT_INSTALL_DIR', True)

    bbnote = 'bbnote "Installing wolfCrypt Benchmarks"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolfcrypt_install_dir)
    cpBenchmark = 'cp "%s/%s" "%s/%s"\n' % (wolfcrypt_benchmark_dir, wolfcrypt_benchmark, wolfcrypt_install_dir, wolfcrypt_benchmark_yocto)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpBenchmark)
}



TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DBENCH_EMBEDDED"

