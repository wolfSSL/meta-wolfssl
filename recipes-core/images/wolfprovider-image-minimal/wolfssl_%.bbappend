# Configure wolfSSL for wolfProvider support in image
# 
# This bbappend automatically configures wolfSSL based on:
#   1. 'wolfprovider' in WOLFSSL_FEATURES
#   2. PREFERRED_PROVIDER_virtual/wolfssl setting
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "wolfprovider"
#   PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl"  # or "wolfssl-fips"

inherit wolfssl-osp-support

python __anonymous() {
    # non-FIPS mode
    wolfssl_osp_conditional_include(
        d,
        feature_name='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider.inc',
        allowed_providers=['wolfssl']
    )
    # FIPS mode
    wolfssl_osp_conditional_include(
        d,
        feature_name='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc',
        allowed_providers=['wolfssl-fips']
    )
}


