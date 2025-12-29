# Disable the feature check for manual image configuration
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-manual-config.inc

# Enable unit tests for wolfprovider
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfprovider-enable-unittest.inc

inherit wolfssl-compatibility

# Enable quick test mode for standalone mode
python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'CPPFLAGS', ' -DWOLFPROV_QUICKTEST')
}
