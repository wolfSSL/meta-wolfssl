# Conditionally configure wolfssl with wolfcrypt-py support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfcrypt-py', 'inc/wolfcrypt-py/wolfssl-enable-wolfcrypt-py.inc')
}
