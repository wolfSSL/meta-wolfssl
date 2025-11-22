# Configure OpenSSL (FIPS replace-default mode) for wolfprovider-replace-default-fips-image-minimal
#
# This bbappend directly configures OpenSSL to use wolfProvider in replace-default mode
# when wolfssl-fips is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc',
        allowed_providers=['wolfssl-fips']
    )
}

