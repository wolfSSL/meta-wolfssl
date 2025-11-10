SUMMARY = "Minimal image with wolfSSL, test utilities, and Python bindings"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, test/benchmark utilities, and Python bindings (wolfssl-py and wolfcrypt-py) with testing support"

# Add Python packages with wolfSSL support and testing requirements
# The wolfssl_%.bbappend in this directory configures wolfSSL with Python features
IMAGE_INSTALL:append = " \
    wolfssl \
    wolfssl-py \
    wolfcrypt-py \
    wolf-py-tests \
    python3 \
    python3-cffi \
    python3-pytest \
"

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

