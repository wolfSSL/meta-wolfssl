inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfprovider', 'inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc')
}

# OpenSSL is a dependency of wolfprovider, not a direct image package
# The check above already validates wolfprovider is in IMAGE_INSTALL
deltask do_wolfssl_check_package

