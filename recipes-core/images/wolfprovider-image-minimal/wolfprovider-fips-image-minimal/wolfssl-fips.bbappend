# Configure wolfSSL (FIPS standalone mode) for wolfprovider-fips-image-minimal
#
# This bbappend directly configures wolfSSL to use FIPS mode
# when wolfssl-fips is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc',
        allowed_providers=['wolfssl-fips']
    )
}

