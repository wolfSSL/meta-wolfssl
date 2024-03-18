WOLFCRYPT_TEST_DIR = "${B}/wolfcrypt/test/.libs"
WOLFCRYPT_TEST = "testwolfcrypt"
WOLFCRYPT_TEST_YOCTO = "wolfcrypttest"
WOLFCRYPT_INSTALL_DIR = "${D}${bindir}"

python () {
    # Get the environment variables WOLFCRYPT_TEST_DIR, WOLFCRYPT_TEST,
    #   WOLFCRYPT_TEST_YOCTO, and WOLFCRYPT_INSTALL_DIR
    wolfcrypt_test_dir = d.getVar('WOLFCRYPT_TEST_DIR', True)
    wolfcrypt_test = d.getVar('WOLFCRYPT_TEST', True)
    wolfcrypt_test_yocto = d.getVar('WOLFCRYPT_TEST_YOCTO', True)
    wolfcrypt_install_dir = d.getVar('WOLFCRYPT_INSTALL_DIR', True)

    bbnote = 'bbnote "Installing wolfCrypt Tests"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolfcrypt_install_dir)
    cpBenchmark = 'cp "%s/%s" "%s/%s"\n' % (wolfcrypt_test_dir, wolfcrypt_test, wolfcrypt_install_dir, wolfcrypt_test_yocto)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpBenchmark)
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DWOLFSSL_RSA_KEY_CHECK -DNO_WRITE_TEMP_FILES"
