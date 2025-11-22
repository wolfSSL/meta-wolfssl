# Configure OpenSSL (non-FIPS standalone mode) for wolfprovider-image-minimal
#
# This bbappend directly configures OpenSSL to use wolfProvider
# when wolfssl is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc',
        allowed_providers=['wolfssl']
    )
}


