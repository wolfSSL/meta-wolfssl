# Conditionally configure openssl with wolfProvider support
# 
# This bbappend automatically enables wolfProvider backend when:
#   1. 'wolfprovider' is in WOLFSSL_FEATURES (explicit intent)
#   2. AND WOLFPROVIDER_MODE specifies the desired mode
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "wolfprovider"
#   WOLFPROVIDER_MODE = "standalone"  # or "replace-default"

inherit wolfssl-helper

python __anonymous() {
    # wolfProvider standalone mode (default)
    wolfssl_conditional_require_mode(
        d,
        package_name='wolfprovider',
        mode='standalone',
        inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc'
    )
    # wolfProvider replace-default mode
    wolfssl_conditional_require_mode(
        d,
        package_name='wolfprovider',
        mode='replace-default',
        inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc'
    )
}

# OpenSSL is a dependency of wolfprovider, not a direct image package
# The check above already validates wolfprovider is in IMAGE_INSTALL
deltask do_wolfssl_check_package

