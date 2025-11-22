SUMMARY = "Minimal image with wolfSSL FIPS, test utilities, and wolfProvider in replace-default mode"
DESCRIPTION = "A minimal Linux image that includes wolfSSL FIPS library, and wolfProvider configured to replace OpenSSL's default provider"

# Set provider to wolfssl-fips for this image (no local.conf configuration needed)
PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"

# Add wolfProvider packages with OpenSSL 3.x support in FIPS replace-default mode
# The bbappend files in this directory configure packages based on provider
# Unit tests are disabled in replace-default mode for now until we have a way to correctly run them
IMAGE_INSTALL:append = " \
    wolfssl-fips \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfprovidercmd \
    wolfproviderenv \
    bash \
"

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

