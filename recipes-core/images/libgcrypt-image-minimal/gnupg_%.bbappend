# Configure gnupg for libgcrypt-image-minimal
#
# This bbappend is needed when using gnupg with libgcrypt to use wolfSSL backend
# when wolfssl-fips is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/gnupg/gnupg-enable-libgcrypt-wolfssl.inc',
        allowed_providers=['wolfssl-fips']
    )
}

