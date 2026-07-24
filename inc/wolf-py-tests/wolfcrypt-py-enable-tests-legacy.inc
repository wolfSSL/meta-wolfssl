# Enable test directory installation for wolfcrypt-py
#
# Declarative on purpose: this inc is included by wolfssl_conditional_require()
# from an anonymous function, and python () blocks registered that late never
# run. FILES uses the literal package name because expandKeys() has already run.

WOLFCRYPT_PY_TEST_DIR = "${S}"
WOLFCRYPT_PY_DIR = "/home/root/wolf-py-tests/wolfcrypt-py-test"
WOLFCRYPT_PY_TEST_TARGET_DIR = "${D}${WOLFCRYPT_PY_DIR}"

do_install_append() {
    install -m 0755 -d "${WOLFCRYPT_PY_TEST_TARGET_DIR}"
    cp -r ${WOLFCRYPT_PY_TEST_DIR}/* ${WOLFCRYPT_PY_TEST_TARGET_DIR}
}

FILES_wolfcrypt-py += "${WOLFCRYPT_PY_DIR}/*"

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1"
