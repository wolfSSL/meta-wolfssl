# Conditionally enable wolfSSL backend for libgcrypt
#
# This bbappend automatically enables wolfSSL backend when:
#   1. 'libgcrypt' is in WOLFSSL_FEATURES (explicit intent)
#   2. AND PREFERRED_PROVIDER_virtual/wolfssl is in the allowed list
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "libgcrypt"
#   require conf/wolfssl-fips.conf

inherit wolfssl-osp-support

python __anonymous() {
    # libgcrypt-wolfssl currently only supports wolfssl-fips
    # In the future, it may support regular wolfssl as well
    wolfssl_osp_conditional_include(
        d,
        feature_name='libgcrypt',
        inc_file='inc/libgcrypt/libgcrypt-enable-wolfssl.inc',
        allowed_providers=['wolfssl-fips']  # Only FIPS supported for now
    )
}

