# Conditionally enable test directory installation for wolfcrypt-py
#
# This bbappend automatically enables test installation when:
#   1. 'wolf-py-tests' is in IMAGE_INSTALL, OR
#   2. 'wolf-py-tests' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   IMAGE_INSTALL:append = " wolf-py-tests"
#   OR
#   WOLFSSL_FEATURES = "wolf-py-tests"

inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(d, 'wolf-py-tests', 'inc/wolf-py-tests/wolfcrypt-py-enable-tests.inc')
}

