# Configure wolfSSL for wolfclu and Python bindings combined image

# Enable wolfclu
require ${WOLFSSL_LAYERDIR}/inc/wolfclu/wolfssl-enable-wolfclu.inc

# Enable Python bindings
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-py/wolfssl-enable-wolfssl-py.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfcrypt-py/wolfssl-enable-wolfcrypt-py.inc
require ${WOLFSSL_LAYERDIR}/inc/wolf-py-tests/wolfssl-enable-wolf-py-tests.inc

# Note: crypto tests (wolfcrypttest, wolfcryptbenchmark) are already included from wolfssl-image-minimal

