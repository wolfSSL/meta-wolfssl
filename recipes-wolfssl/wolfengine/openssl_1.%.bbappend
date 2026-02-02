inherit wolfssl-helper

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfengine', 'inc/wolfengine/openssl/openssl-enable-wolfengine.inc')
}

# OpenSSL is a dependency of wolfengine, not a direct image package
# The check above already validates wolfengine is in IMAGE_INSTALL
deltask do_wolfssl_check_package