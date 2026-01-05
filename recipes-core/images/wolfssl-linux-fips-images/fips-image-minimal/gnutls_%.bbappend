# Configure gnutls for fips-image-minimal
#
# This bbappend directly configures gnutls to use wolfSSL backend
# when wolfssl-fips is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/${LAYERSERIES_CORENAMES}/gnutls/gnutls-enable-wolfssl.inc

