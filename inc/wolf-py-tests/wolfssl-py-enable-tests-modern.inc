# Enable test directory installation for wolfssl-py
#
# Declarative on purpose: this inc is included by wolfssl_conditional_require()
# from an anonymous function, and python () blocks registered that late never
# run. FILES uses the literal package name because expandKeys() has already run.

WOLFSSL_PY_TEST_DIR = "${S}"
WOLFSSL_PY_DIR = "/home/root/wolf-py-tests/wolfssl-py-test"
WOLFSSL_PY_TEST_TARGET_DIR = "${D}${WOLFSSL_PY_DIR}"

do_install:append() {
    install -m 0755 -d "${WOLFSSL_PY_TEST_TARGET_DIR}"
    cp -r ${WOLFSSL_PY_TEST_DIR}/* ${WOLFSSL_PY_TEST_TARGET_DIR}
}

FILES:wolfssl-py += "${WOLFSSL_PY_DIR}/*"

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1"
