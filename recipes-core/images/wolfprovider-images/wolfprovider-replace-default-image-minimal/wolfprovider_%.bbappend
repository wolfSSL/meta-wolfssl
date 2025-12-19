# Disable the feature check for manual image configuration
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-manual-config.inc

# Enable unit tests for wolfprovider replace default mode
# The inc file handles all logic including symbol checking and conditional enabling
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfprovider-enable-replace-default-unittest.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfprovider-enable-unittest.inc

