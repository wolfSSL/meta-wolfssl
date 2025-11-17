# Configure wolfProvider FIPS support for wolfSSL
#
# This bbappend automatically configures wolfssl or wolfssl-fips with the features
# needed by wolfprovider when 'wolfprovider' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "wolfprovider"
#   require conf/wolfssl-fips.conf # If FIPS mode is enabled

inherit wolfssl-osp-support

python __anonymous() {
    # wolfProvider non-FIPS mode
    wolfssl_osp_conditional_include(
        d,
        feature_name='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider.inc',
        allowed_providers=['wolfssl']
    )
    # wolfProvider FIPS mode
    wolfssl_osp_conditional_include(
        d,
        feature_name='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc',
        allowed_providers=['wolfssl-fips']
    )
}

# Disable package check since this is configuration for wolfssl itself
deltask do_wolfssl_check_package


