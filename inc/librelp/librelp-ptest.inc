inherit wolfssl-compatibility

python __anonymous() {
    if bb.data.inherits_class('target', d):
        wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/files:')
        wolfssl_varAppendNonOverride(d, 'SRC_URI', ' file://librelp-ptest.patch')
}
