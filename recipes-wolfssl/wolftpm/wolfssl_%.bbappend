# Conditionally configure wolfssl with wolftpm support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolftpm', 'inc/wolftpm/wolfssl-enable-wolftpm.inc')
}
