# Configure wolfssl-fips for libgcrypt integration
#
# This bbappend automatically configures wolfssl-fips with the features
# needed by libgcrypt-wolfssl when 'libgcrypt' is in WOLFSSL_FEATURES
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "libgcrypt"
#   require conf/wolfssl-fips.conf

inherit wolfssl-helper

python __anonymous() {
    # Check if libgcrypt is in WOLFSSL_FEATURES
    wolfssl_features = d.getVar('WOLFSSL_FEATURES') or ''
    
    if 'libgcrypt' in wolfssl_features.split():
        bb.note("libgcrypt in WOLFSSL_FEATURES - configuring wolfssl-fips for libgcrypt support")
        # Use the helper to include the configuration
        wolfssl_conditional_require(d, 'libgcrypt', 'inc/wolfssl-fips/wolfssl-enable-libgcrypt.inc')
}

# Disable package check since this is configuration for wolfssl-fips itself
deltask do_wolfssl_check_package

