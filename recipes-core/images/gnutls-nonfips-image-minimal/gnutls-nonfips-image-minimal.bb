SUMMARY = "Minimal image with gnutls-wolfssl (non-FIPS)"
DESCRIPTION = "This image includes gnutls configured to use standard wolfSSL \
(non-FIPS) as the crypto backend."

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

IMAGE_INSTALL += " \
      nettle \
      gnutls \
      gnutls-dev \
      gnutls-bin \
      wolfssl-gnutls-wrapper \
      wolfssl-gnutls-wrapper-dev \
      pkgconfig \
"
