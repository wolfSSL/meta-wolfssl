# Conditionally configure wolfssl-fips with wolfcrypttest support
# Matches the wolfssl variant so FIPS builds get the same helpers.

inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfcrypttest', 'inc/wolfcrypttest/wolfssl-enable-wolfcrypttest.inc')
}
