SUMMARY = "Minimal image with libgcrypt-wolfssl (libgcrypt with wolfSSL FIPS backend)"
DESCRIPTION = "This image includes libgcrypt configured to use wolfSSL/wolfCrypt as the \
               crypto backend. Requires wolfssl-fips provider and demonstrates FIPS-validated \
               cryptography through libgcrypt."

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

IMAGE_INSTALL += " \
    libgcrypt \
    libgcrypt-ptest \
    ptest-runner \
"

# This image requires wolfssl-fips
# Set in local.conf:
#   WOLFSSL_DEMOS = "wolfssl-image-minimal libgcrypt-image-minimal"
#   require conf/wolfssl-fips.conf

