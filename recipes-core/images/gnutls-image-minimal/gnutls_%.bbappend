# Configure gnutls for gnutls-image-minimal
#
# This bbappend directly configures gnutls to use wolfSSL backend
# when wolfssl-fips is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    yocto_version = d.getVar('LAYERSERIES_CORENAMES') or ''
    inc_path = f'inc/{yocto_version}/gnutls/gnutls-enable-wolfssl.inc'

    wolfssl_osp_include_if_provider(
        d,
        inc_file=inc_path,
        allowed_providers=['wolfssl-fips']
    )
}

