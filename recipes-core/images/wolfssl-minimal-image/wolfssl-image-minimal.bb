SUMMARY = "Minimal image with wolfSSL and test utilities"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library with test/benchmark utilities"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'IMAGE_INSTALL', ' wolfcrypttest wolfcryptbenchmark')
}

require recipes-core/images/core-image-minimal.bb
