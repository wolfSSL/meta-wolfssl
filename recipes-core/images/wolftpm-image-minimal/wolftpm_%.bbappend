# Disable the feature check for manual image configuration
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-manual-config.inc

# Enable software TPM support for testing with QEMU and TPM simulator
EXTRA_OECONF += "--enable-devtpm"

