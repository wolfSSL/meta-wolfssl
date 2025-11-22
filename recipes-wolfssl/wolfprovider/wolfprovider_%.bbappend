# Conditionally configure wolfProvider with unit tests
# 
# This bbappend automatically enables wolfProvider unit tests when:
#   1. 'wolfprovider' is in WOLFSSL_FEATURES (explicit intent)
#   2. AND WOLFPROVIDER_FLAGS contains "enable-tests"
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "wolfprovider"
#   WOLFPROVIDER_FLAGS = "enable-tests" # or dont set

inherit wolfssl-helper

python __anonymous() {
    # wolfProvider enable unit tests (via WOLFPROVIDER_FLAGS - separate from mode)
    wolfssl_conditional_require_flag(
        d,
        package_name='wolfprovider',
        flag_name='enable-tests',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovidertest.inc'
    )
}

# OpenSSL is a dependency of wolfprovider, not a direct image package
# The check above already validates wolfprovider is in IMAGE_INSTALL
deltask do_wolfssl_check_package

