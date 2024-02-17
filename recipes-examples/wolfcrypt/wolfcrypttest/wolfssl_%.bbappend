WOLFCRYPT_TEST_DIR = "${B}/wolfcrypt/test/.libs"
WOLFCRYPT_TEST = "testwolfcrypt"
WOLFCRYPT_TEST_YOCTO = "wolfcrypttest"

do_install:append() {                                                           
    bbnote "Installing wolfCrypt Tests"                                     
    install -m 0755 -d ${D}${bindir}                                        
    cp -r ${WOLFCRYPT_TEST_DIR}/${WOLFCRYPT_TEST} ${D}${bindir}/${WOLFCRYPT_TEST_YOCTO}
} 

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DWOLFSSL_RSA_KEY_CHECK -DNO_WRITE_TEMP_FILES"
