# Configure wolfssl-fips for libgcrypt-image-minimal
#
# This bbappend directly configures wolfssl-fips with features needed for libgcrypt support.
# Since we're already in wolfssl-fips context, just include the configuration directly.

require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-enable-libgcrypt.inc

