# Disable the feature check for manual image configuration
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-manual-config.inc

# Enable unit tests for standalone mode
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovidertest.inc

# Enable quick test mode for standalone mode
CPPFLAGS:append = " -DWOLFPROV_QUICKTEST"

