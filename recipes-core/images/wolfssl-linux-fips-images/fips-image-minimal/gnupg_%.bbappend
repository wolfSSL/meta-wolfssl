# Configure gnupg for libgcrypt-image-minimal
#
# This bbappend is needed when using gnupg with libgcrypt to use wolfSSL backend
# when wolfssl-fips is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/gnupg/gnupg-enable-libgcrypt-wolfssl.inc

