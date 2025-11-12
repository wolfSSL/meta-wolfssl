inherit wolfssl-helper

python __anonymous() {
    # standalone
    wolfssl_conditional_require(d, 'wolfprovider', 'inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc')
    # replace default
    wolfssl_conditional_require(d, 'wolfprovider', 'inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc')

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

# OpenSSL is a dependency of wolfprovider, not a direct image package
# The check above already validates wolfprovider is in IMAGE_INSTALL
deltask do_wolfssl_check_package

