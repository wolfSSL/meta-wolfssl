# Conditionally enable debug mode for wolfengine when testing
#
# This bbappend automatically enables debug configuration when:
#   1. 'wolfenginetest' is in IMAGE_INSTALL, OR
#   2. 'wolfenginetest' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   IMAGE_INSTALL:append = " wolfenginetest"
#   OR
#   WOLFSSL_FEATURES = "wolfenginetest"

inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfenginetest', 'inc/wolfenginetest/wolfengine-enable-test.inc')
}