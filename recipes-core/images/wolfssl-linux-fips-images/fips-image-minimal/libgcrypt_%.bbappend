# Configure libgcrypt for fips-image-minimal
#
# This bbappend directly configures libgcrypt to use wolfSSL backend
# when wolfssl-fips is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/${LAYERSERIES_CORENAMES}/libgcrypt/libgcrypt-enable-wolfssl.inc

