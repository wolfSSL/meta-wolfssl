# Conditionally configure wolfssl with wolfclu support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables
# Set WOLFSSL_FEATURES:append = " wolfclu" in your image recipe to enable

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfclu', 'inc/wolfclu/wolfssl-enable-wolfclu.inc')
}

