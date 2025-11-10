# Configure wolfSSL for libgcrypt integration
#
# This include file configures wolfSSL with the necessary features
# to support libgcrypt-wolfssl (libgcrypt with wolfSSL/wolfCrypt backend)
#
# Required wolfSSL features:
#   --enable-fips=v5    : FIPS 140-3 validation
#   --enable-keygen     : Key generation support
#
# Required compile flags:
#   HAVE_AES_ECB               : AES ECB mode support
#   WC_RSA_DIRECT              : Direct RSA operations
#   WC_RSA_NO_PADDING          : RSA without padding
#   WOLFSSL_PUBLIC_MP          : Public multi-precision math
#   WOLFSSL_RSA_KEY_CHECK      : RSA key validation
#   ACVP_VECTOR_TESTING        : ACVP test vector support
#   WOLFSSL_ECDSA_SET_K        : ECDSA k value setting

EXTRA_OECONF += " --enable-fips=v5 --enable-keygen "

TARGET_CFLAGS += "-DHAVE_AES_ECB -DWC_RSA_DIRECT -DWC_RSA_NO_PADDING -DWOLFSSL_PUBLIC_MP -DWOLFSSL_RSA_KEY_CHECK -DACVP_VECTOR_TESTING -DWOLFSSL_ECDSA_SET_K"

