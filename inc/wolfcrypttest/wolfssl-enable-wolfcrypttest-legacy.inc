# Configuration to enable wolfcrypttest support in wolfssl
EXTRA_OECONF += "--enable-crypttests"

python () {
    files_var = 'FILES_' + d.getVar('PN')
    d.appendVar(files_var, ' ${bindir}/wolfcrypttest')
}

do_install_append() {
    bbnote "Installing wolfCrypt Tests"
    if [ ! -x "${B}/wolfcrypt/test/.libs/testwolfcrypt" ]; then
        bbwarn "wolfCrypt test binary missing at ${B}/wolfcrypt/test/.libs/testwolfcrypt"
        return
    fi

    install -Dm0755 "${B}/wolfcrypt/test/.libs/testwolfcrypt" "${D}${bindir}/wolfcrypttest"
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DWOLFSSL_RSA_KEY_CHECK -DNO_WRITE_TEMP_FILES"
