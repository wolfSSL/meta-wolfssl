SUMMARY = "Minimal image with gnutls-wolfssl (gnutls with wolfSSL FIPS backend)"
DESCRIPTION = "This image includes gnutls configured to use wolfSSL/wolfCrypt as the \
               crypto backend. Requires wolfssl-fips provider and demonstrates FIPS-validated \
               cryptography through gnutls."

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

IMAGE_INSTALL += " \
    gnutls \
    gnutls-dev \
    gnutls-bin \
    gnutls-fips \
    wolfssl-gnutls-wrapper \
    wolfssl-gnutls-wrapper-dev \
    pkgconfig \
"

# This image requires wolfssl-fips
# Set in local.conf:
#   WOLFSSL_DEMOS = "wolfssl-image-minimal gnutls-image-minimal"
#   Absolute path to your fips configuration in meta-wolfssl
#   require conf/wolfssl-fips.conf

