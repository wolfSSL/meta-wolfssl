# Configuration to enable wolfcrypttest support in wolfssl

inherit wolfssl-compatibility

EXTRA_OECONF += "--enable-crypttests"

do_install_wolfcrypttest() {
    if [ ! -x "${B}/wolfcrypt/test/.libs/testwolfcrypt" ]; then
        bbwarn "wolfCrypt test binary missing at ${B}/wolfcrypt/test/.libs/testwolfcrypt"
        return
    fi

    install -Dm0755 "${B}/wolfcrypt/test/.libs/testwolfcrypt" "${D}${bindir}/wolfcrypttest"
}

addtask do_install_wolfcrypttest after do_install before do_package
do_install_wolfcrypttest[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${bindir}/wolfcrypttest')
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DWOLFSSL_RSA_KEY_CHECK -DNO_WRITE_TEMP_FILES"

