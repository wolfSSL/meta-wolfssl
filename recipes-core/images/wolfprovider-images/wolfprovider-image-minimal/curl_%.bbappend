# Configure curl with wolfprovider FIPS mode.
#
# This bbappend is needed when using curl with wolfprovider FIPS mode.

inherit wolfssl-osp-support

python __anonymous() {
    yocto_version = d.getVar('LAYERSERIES_CORENAMES') or ''
    inc_path = f'inc/{yocto_version}/curl/curl-enable-wolfprovider-fips.inc'

    wolfssl_osp_include_if_provider(
        d,
        inc_file=inc_path,
        allowed_providers=['wolfssl-fips']
    )
}

