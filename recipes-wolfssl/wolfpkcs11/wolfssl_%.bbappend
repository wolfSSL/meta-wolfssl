inherit wolfssl-helper
deltask do_wolfssl_check_package

python __anonymous() {
    wolfssl_conditional_require(d, 'wolfpkcs11', 'inc/wolfpkcs11/wolfssl-enable-wolfpkcs11.inc')
}
