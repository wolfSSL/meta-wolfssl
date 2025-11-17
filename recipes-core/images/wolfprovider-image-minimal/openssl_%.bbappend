# Configure OpenSSL support for wolfProvider
#
# This bbappend automatically configures OpenSSL based on:
#   1. 'wolfprovider' in WOLFSSL_FEATURES
#   2. WOLFPROVIDER_MODE setting (standalone or replace-default)
#
# Usage in local.conf:
#   WOLFSSL_FEATURES = "wolfprovider"
#   WOLFPROVIDER_MODE = "standalone"  # or "replace-default"

inherit wolfssl-helper

python __anonymous() {
    # Standalone mode
    wolfssl_conditional_require_mode(
        d,
        package_name='wolfprovider',
        mode='standalone',
        inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc'
    )
    # Replace-default mode
    wolfssl_conditional_require_mode(
        d,
        package_name='wolfprovider',
        mode='replace-default',
        inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc'
    )
}


