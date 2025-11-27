# Configure OpenSSL (replace-default mode) for wolfprovider-replace-default-image-minimal
#
# This bbappend directly configures OpenSSL to use wolfProvider in replace-default mode
# when wolfssl is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc

