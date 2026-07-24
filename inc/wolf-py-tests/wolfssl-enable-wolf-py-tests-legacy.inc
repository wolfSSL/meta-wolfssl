# Configuration to enable wolf-py-tests support in wolfssl
# Python tests may need specific features enabled
#
# Declarative on purpose: this inc is included by wolfssl_conditional_require()
# from an anonymous function, and python () blocks registered that late never
# run. FILES uses the literal package name because expandKeys() has already run.
EXTRA_OECONF += "--enable-shared"

WOLFSSL_PY_TEST_CERTS_DIR = "/home/root/wolf-py-tests/certs"
WOLFSSL_PY_CERTS_DIR = "/certs"
WOLFSSL_PY_CERTS_INSTALL_DIR = "${D}${WOLFSSL_PY_TEST_CERTS_DIR}"
WOLFSSL_PY_CERTS_SOURCE_DIR = "${S}${WOLFSSL_PY_CERTS_DIR}"

do_install_append() {
    bbnote "Installing Certs Directory for wolf-py Tests"
    install -m 0755 -d "${WOLFSSL_PY_CERTS_INSTALL_DIR}"
    cp -r ${WOLFSSL_PY_CERTS_SOURCE_DIR}/*.der ${WOLFSSL_PY_CERTS_INSTALL_DIR}
    cp -r ${WOLFSSL_PY_CERTS_SOURCE_DIR}/*.pem ${WOLFSSL_PY_CERTS_INSTALL_DIR}
}

FILES_wolfssl += "${WOLFSSL_PY_TEST_CERTS_DIR}/*"
