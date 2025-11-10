# Configure wolfSSL for all sub-packages in combined image

# Enable wolfssh
require ${WOLFSSL_LAYERDIR}/inc/wolfssh/wolfssl-enable-wolfssh.inc

# Enable wolfprovider
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider.inc

# Enable wolftpm
require ${WOLFSSL_LAYERDIR}/inc/wolftpm/wolfssl-enable-wolftpm.inc
require ${WOLFSSL_LAYERDIR}/inc/wolftpm-tests/wolfssl-enable-wolftpm-wrap-test.inc

# Note: crypto tests (wolfcrypttest, wolfcryptbenchmark) are already included from wolfssl-image-minimal
