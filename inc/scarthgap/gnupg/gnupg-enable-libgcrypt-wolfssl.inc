inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/files:')
    wolfssl_varAppendNonOverride(d, 'SRC_URI', ' file://gnupg-2.4.8-use-pkgconfig-for-libgcrypt.patch')
}
