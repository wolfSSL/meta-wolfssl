# Configure libgcrypt for libgcrypt-image-minimal
#
# This bbappend directly configures libgcrypt to use wolfSSL backend
# when wolfssl-fips is the preferred provider.

inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/libgcrypt/libgcrypt-enable-wolfssl.inc',
        allowed_providers=['wolfssl-fips']
    )
}

