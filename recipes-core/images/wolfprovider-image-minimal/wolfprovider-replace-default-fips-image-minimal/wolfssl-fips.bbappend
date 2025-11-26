# Configure wolfSSL (FIPS replace-default mode) for wolfprovider-replace-default-fips-image-minimal
#
# This bbappend directly configures wolfSSL to use FIPS mode in replace-default mode
# when wolfssl-fips is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc',
        allowed_providers=['wolfssl-fips']
    )
}

# Fix for commercial bundle missing stamp-h.in required by automake
do_configure:prepend() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}


