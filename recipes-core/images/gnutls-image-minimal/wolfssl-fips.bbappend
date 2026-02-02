# Configure wolfssl-fips for gnutls-image-minimal
#
# This bbappend directly configures wolfssl-fips with features needed for gnutls support.
# Since we're already in wolfssl-fips context, just include the configuration directly.

require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-enable-gnutls.inc

