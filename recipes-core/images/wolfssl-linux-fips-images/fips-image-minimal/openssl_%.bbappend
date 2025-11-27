# Configure OpenSSL (replace-default mode) for fips-image-minimal
#
# This bbappend configures OpenSSL to use wolfProvider in replace-default mode

require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc

