# Conditionally configure wolfssl with wolfenginetest support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfenginetest', 'inc/wolfenginetest/wolfssl-enable-wolfenginetest.inc')
}

