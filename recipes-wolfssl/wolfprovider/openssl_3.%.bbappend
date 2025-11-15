inherit wolfssl-helper

python __anonymous() {
    # standalone
    wolfssl_conditional_require(d, 'wolfprovider', 'inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc')
    # replace default
    wolfssl_conditional_require(d, 'wolfprovider', 'inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc')
}

# OpenSSL is a dependency of wolfprovider, not a direct image package
# The check above already validates wolfprovider is in IMAGE_INSTALL
deltask do_wolfssl_check_package

