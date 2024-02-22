WOLFSSL_PY_TEST_CERTS_DIR = "/home/root/wolf-py-tests/wolfssl-py-test/certs"
WOLFSSL_PY_CERTS_DIR = "/certs"

do_install:append() {
    bbnote "Installing Certs Directory for wolf-py Tests"                   
    install -m 0755 -d ${D}${WOLFSSL_PY_TEST_CERTS_DIR}                     
    cp -r ${S}${WOLFSSL_PY_CERTS_DIR}/*.der ${D}${WOLFSSL_PY_TEST_CERTS_DIR}
    cp -r ${S}${WOLFSSL_PY_CERTS_DIR}/*.pem ${D}${WOLFSSL_PY_TEST_CERTS_DIR}
}


FILES:${PN} += " ${WOLFSSL_PY_TEST_CERTS_DIR}/* "
