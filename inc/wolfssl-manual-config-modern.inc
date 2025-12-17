# Include this file in any wolfSSL package bbappend when manually configuring wolfSSL.
# This will disable the feature check task that validates IMAGE_INSTALL or WOLFSSL_FEATURES.
#
# Usage in your-layer/recipes-wolfssl/<package>/<package>_%.bbappend:
#   require inc/wolfssl-manual-config.inc
#
# Or with full path:
#   require ${COREBASE}/../meta-wolfssl/inc/wolfssl-manual-config.inc
#
# Note: You also need to configure wolfSSL by including the appropriate
# wolfssl-enable-*.inc file(s) in your wolfssl_%.bbappend file.

deltask do_wolfssl_check_package

