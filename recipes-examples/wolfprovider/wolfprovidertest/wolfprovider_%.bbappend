# Conditionally configure wolfProvider with unit tests
#
# This bbappend automatically enables wolfProvider unit tests when
# wolfprovidertest is in IMAGE_INSTALL or WOLFSSL_FEATURES

inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(
        d,
        package_name='wolfprovidertest',
        inc_path='inc/wolfprovider/wolfprovider-enable-unittest.inc'
    )
}
