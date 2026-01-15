# Configure gnutls for gnutls-nonfips-image-minimal
inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/gnutls/gnutls-enable-wolfssl.inc',
        allowed_providers=['wolfssl']  # Standard wolfSSL only
        )
}
