SUMMARY = "Minimal image with wolfSSL and test utilities"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library with test/benchmark utilities"

# Add wolfSSL configured with test/benchmark support
# The wolfssl_%.bbappend in this directory configures wolfSSL with --enable-crypttests
IMAGE_INSTALL:append = " wolfcrypttest wolfcryptbenchmark"

require recipes-core/images/core-image-minimal.bb