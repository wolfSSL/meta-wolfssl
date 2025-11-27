# Configure wolfProvider FIPS support for wolfSSL
#
# This bbappend automatically configures wolfssl or wolfssl-fips with the features
# needed by wolfprovider when 'wolfprovider' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   require conf/wolfssl-fips.conf # If FIPS mode is enabled

inherit wolfssl-osp-support

python __anonymous() {
    # wolfProvider non-FIPS mode
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider.inc',
        allowed_providers=['wolfssl']
    )
}

# Disable package check since this is configuration for wolfssl itself
deltask do_wolfssl_check_package


