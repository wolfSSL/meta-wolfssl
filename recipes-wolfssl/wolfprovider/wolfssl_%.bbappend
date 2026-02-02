# Configure wolfSSL to support wolfProvider
#
# This bbappend automatically configures wolfssl or wolfssl-fips with the features
# needed by wolfprovider when 'wolfprovider' is in WOLFSSL_FEATURES or IMAGE_INSTALL
#
# Usage in local.conf:
#   require conf/wolfssl-fips.conf # If FIPS mode is enabled
#   IMAGE_INSTALL += "wolfprovider"

inherit wolfssl-osp-support

python __anonymous() {
    # wolfProvider non-FIPS mode
    wolfssl_conditional_include_ext(
        d,
        enable_for='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider.inc',
        allowed_providers=['wolfssl']
    )
}

# Disable package check since this is configuration for wolfssl itself
deltask do_wolfssl_check_package


