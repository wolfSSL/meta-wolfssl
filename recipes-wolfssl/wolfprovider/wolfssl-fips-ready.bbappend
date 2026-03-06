# Configure wolfSSL FIPS Ready to support wolfProvider
#
# This bbappend automatically configures wolfssl-fips-ready with the features
# needed by wolfprovider when 'wolfprovider' is in WOLFSSL_FEATURES or IMAGE_INSTALL
#
# Usage in local.conf:
#   require conf/wolfssl-fips-ready.conf
#   IMAGE_INSTALL += "wolfprovider"

inherit wolfssl-osp-support

python __anonymous() {
    # wolfProvider FIPS Ready mode
    wolfssl_conditional_include_ext(
        d,
        enable_for='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider-fips-ready.inc',
        allowed_providers=['wolfssl-fips-ready']
    )
}

# Disable package check since this is configuration for wolfssl itself
deltask do_wolfssl_check_package
