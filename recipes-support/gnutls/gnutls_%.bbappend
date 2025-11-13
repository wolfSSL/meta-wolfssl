# Conditionally enable wolfSSL backend for gnutls
#
# This bbappend automatically enables wolfSSL backend when:
#   1. 'gnutls' is in WOLFSSL_FEATURES (explicit intent)
#   2. AND PREFERRED_PROVIDER_virtual/wolfssl is in the allowed list
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "gnutls"
#   require conf/wolfssl-fips.conf

inherit wolfssl-osp-support

python __anonymous() {
    # gnutls-wolfssl currently only supports wolfssl-fips
    # In the future, it may support regular wolfssl as well
    wolfssl_osp_conditional_include(
        d,
        feature_name='gnutls',
        inc_file='inc/gnutls/gnutls-enable-wolfssl.inc',
        allowed_providers=['wolfssl-fips']  # Only FIPS supported for now
    )
}
