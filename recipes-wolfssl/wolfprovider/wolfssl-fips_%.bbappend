# Conditionally configure wolfssl FIPS with wolfprovider support
# This bbappend checks the WOLFSSL_FEATURES and IMAGE_INSTALL variables

inherit wolfssl-helper
inherit wolfssl-osp-support
deltask do_wolfssl_check_package

python __anonymous() {
    # FIPS mode
    wolfssl_osp_conditional_include(
        d,
        feature_name='wolfprovider',
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc',
        allowed_providers=['wolfssl-fips']
    )
}

