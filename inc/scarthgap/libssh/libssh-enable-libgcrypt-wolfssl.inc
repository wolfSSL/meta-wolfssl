# Disable chacha20-poly1305 in libssh when using libgcrypt-wolfssl backend
# wolfSSL-backed libgcrypt does not support chacha20 cipher in FIPS mode

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/files:')
    wolfssl_varAppendNonOverride(d, 'SRC_URI', ' file://enable-fips-mode.patch')
}
