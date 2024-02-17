WOLFCRYPT_BENCHMARK_DIR = "${B}/wolfcrypt/benchmark/.libs"                      
WOLFCRYPT_BENCHMARK = "benchmark"                                               
WOLFCRYPT_BENCHMARK_YOCTO = "wolfcryptbenchmark" 

do_install:append() {
    bbnote "Installing wolfCrypt Benchmarks"                                
    install -m 0755 -d ${D}${bindir}                                        
    cp ${WOLFCRYPT_BENCHMARK_DIR}/${WOLFCRYPT_BENCHMARK} ${D}${bindir}/${WOLFCRYPT_BENCHMARK_YOCTO}
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DBENCH_EMBEDDED"
