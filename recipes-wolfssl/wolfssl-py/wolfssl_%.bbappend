# Conditionally configure wolfssl with wolfssl-py support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfssl-py', 'inc/wolfssl-py/wolfssl-enable-wolfssl-py.inc')
}
