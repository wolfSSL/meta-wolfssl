SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfProvider"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, test/benchmark utilities, and wolfProvider for OpenSSL 3.x integration"

# Add wolfProvider packages with OpenSSL 3.x support
# The wolfssl_%.bbappend in this directory configures wolfSSL with wolfProvider features
IMAGE_INSTALL:append = " \
    wolfssl \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfprovidertest \
    bash \
"

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb


