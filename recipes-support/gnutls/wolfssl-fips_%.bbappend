# Configure wolfssl-fips for gnutls integration
#
# This bbappend automatically configures wolfssl-fips with the features
# needed by gnutls-wolfssl when 'gnutls' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "gnutls"
#   require conf/wolfssl-fips.conf

inherit wolfssl-helper

python __anonymous() {
    # Check if gnutls is in WOLFSSL_FEATURES
    wolfssl_features = d.getVar('WOLFSSL_FEATURES') or ''

    if 'gnutls' in wolfssl_features.split():
        bb.note("gnutls in WOLFSSL_FEATURES - configuring wolfssl-fips for gnutls support")
        # Use the helper to include the configuration
        wolfssl_conditional_require(d, 'gnutls', 'inc/wolfssl-fips/wolfssl-enable-gnutls.inc')
}

# Disable package check since this is configuration for wolfssl-fips itself
deltask do_wolfssl_check_package
