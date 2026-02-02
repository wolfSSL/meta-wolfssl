SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfCLU"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, test/benchmark utilities, and wolfCLU command-line utility"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'IMAGE_INSTALL', ' wolfclu')
}

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb
