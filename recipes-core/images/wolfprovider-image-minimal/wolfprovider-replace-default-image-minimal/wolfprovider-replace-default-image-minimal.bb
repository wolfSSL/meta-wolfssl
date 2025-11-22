SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfProvider in replace-default mode"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, and wolfProvider configured to replace OpenSSL's default provider"

# Add wolfProvider packages with OpenSSL 3.x support in replace-default mode
# The openssl_%.bbappend in this directory configures OpenSSL with replace-default mode
# Unit tests are disabled in replace-default mode for now until we have a way to correctly run them
IMAGE_INSTALL:append = " \
    wolfssl \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfprovidercmd \
    wolfproviderenv \
    bash \
"

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

