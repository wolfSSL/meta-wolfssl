# Configure OpenSSL (standalone mode) for wolfprovider-images
#
# This bbappend directly configures OpenSSL to use wolfProvider
# when wolfssl is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc

