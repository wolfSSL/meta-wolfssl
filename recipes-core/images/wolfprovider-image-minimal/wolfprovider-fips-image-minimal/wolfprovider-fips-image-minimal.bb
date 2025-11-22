SUMMARY = "Minimal image with wolfSSL FIPS, test utilities, and wolfProvider in standalone mode"
DESCRIPTION = "A minimal Linux image that includes wolfSSL FIPS library, test/benchmark utilities, and wolfProvider configured in standalone mode"

# Set provider to wolfssl-fips for this image (no local.conf configuration needed)
PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"

# Add wolfProvider packages with OpenSSL 3.x support in standalone mode (FIPS)
# The bbappend files in this directory configure packages based on provider
IMAGE_INSTALL:append = " \
    wolfssl-fips \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfprovidertest \
    wolfprovidercmd \
    wolfproviderenv \
    bash \
"

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

