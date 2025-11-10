# Conditionally configure wolfssl with wolfssh support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfssh', 'inc/wolfssh/wolfssl-enable-wolfssh.inc')
}
