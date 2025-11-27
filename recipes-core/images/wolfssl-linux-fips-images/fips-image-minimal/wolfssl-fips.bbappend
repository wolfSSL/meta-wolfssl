# Configure wolfSSL FIPS for fips-image-minimal
#
# This bbappend configures wolfSSL FIPS with libgcrypt, gnutls, and wolfProvider support

require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-enable-libgcrypt.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-enable-gnutls.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc

# Fix for commercial bundle missing stamp-h.in required by automake
do_configure:prepend() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}

