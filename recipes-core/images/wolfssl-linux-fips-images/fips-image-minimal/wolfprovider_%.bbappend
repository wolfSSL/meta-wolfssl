# Disable the feature check for manual image configuration
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-manual-config.inc

# Enable unit tests for wolfprovider replace default mode since FIPS should always be using this
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfprovider-enable-replace-default-unittest.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfprovider-enable-unittest.inc
