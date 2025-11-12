# Manual configuration for wolfprovider-image-minimal
# Configure OpenSSL for wolfProvider support

# WARNING: need to specify replace default or standalone mode not both
# Uncomment this to use wolfProvider in standalone mode
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc
# Uncomment this to use wolfProvider in replace-default mode
# require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc


