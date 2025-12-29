SUMMARY = "Minimal image with wolfSSL and multiple sub-packages (wolfssh, wolfmqtt, wolfprovider, wolftpm)"
DESCRIPTION = "A combined demonstration image including wolfssh, wolfmqtt, wolfprovider, and wolftpm with TPM support"

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'IMAGE_INSTALL', ' wolfssh wolfmqtt wolfprovider wolfprovidertest openssl openssl-bin wolftpm-wrap-test tpm2-tools tpm2-tss libtss2 libtss2-mu libtss2-tcti-device libtss2-tcti-mssim bash')
    wolfssl_varAppendNonOverride(d, 'DISTRO_FEATURES', ' security tpm tpm2')
    wolfssl_varAppendNonOverride(d, 'MACHINE_FEATURES', ' tpm tpm2')
    wolfssl_varAppendNonOverride(d, 'KERNEL_FEATURES', ' features/tpm/tpm.scc')
}

IMAGE_FEATURES += "package-management"

# Validate TPM features are enabled
python __anonymous() {
    distro_features = d.getVar('DISTRO_FEATURES') or ''
    if 'tpm' not in distro_features or 'tpm2' not in distro_features or 'security' not in distro_features:
        bb.fatal("TPM support requires 'DISTRO_FEATURES += \"security tpm tpm2\"' in local.conf")

    machine_features = d.getVar('MACHINE_FEATURES') or ''
    if 'tpm' not in machine_features or 'tpm2' not in machine_features:
        bb.fatal("TPM support requires 'MACHINE_FEATURES += \"tpm tpm2\"' in local.conf")

    kernel_features = d.getVar('KERNEL_FEATURES') or ''
    if 'features/tpm/tpm.scc' not in kernel_features:
        bb.fatal("TPM support requires 'KERNEL_FEATURES += \"features/tpm/tpm.scc\"' in local.conf")
}
