# Conditionally enable wrap_test installation for wolfTPM
#
# This bbappend automatically enables wrap_test when:
#   1. 'wolftpm-wrap-test' is in IMAGE_INSTALL, OR
#   2. 'wolftpm-wrap-test' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   IMAGE_INSTALL:append = " wolftpm-wrap-test"
#   OR
#   WOLFSSL_FEATURES = "wolftpm-wrap-test"

inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(d, 'wolftpm-wrap-test', 'inc/wolftpm-tests/wolftpm-enable-wrap-test.inc')
}
