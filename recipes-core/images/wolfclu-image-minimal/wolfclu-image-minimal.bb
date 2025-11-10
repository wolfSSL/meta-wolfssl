SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfCLU"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, test/benchmark utilities, and wolfCLU command-line utility"

# Add wolfCLU configured with wolfSSL support
# The wolfssl_%.bbappend in this directory configures wolfSSL with --enable-wolfclu
IMAGE_INSTALL:append = " wolfclu"

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

