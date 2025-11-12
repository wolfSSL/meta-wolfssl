# Conditionally configure wolfssl with wolftpm-wrap-test support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolftpm-wrap-test', 'inc/wolftpm-tests/wolfssl-enable-wolftpm-wrap-test.inc')
}
