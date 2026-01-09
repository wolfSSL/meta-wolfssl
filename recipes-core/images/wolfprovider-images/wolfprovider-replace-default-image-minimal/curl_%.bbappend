# Configure curl with wolfprovider FIPS mode.
#
# This bbappend is needed when using curl with wolfprovider FIPS mode.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/curl/curl-enable-wolfprovider-fips.inc',
        allowed_providers=['wolfssl-fips']
    )
}

