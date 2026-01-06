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

# Note: TPM features are set dynamically by this recipe and the .inc file
# If building standalone without the .inc file, ensure these are set in local.conf:
#   DISTRO_FEATURES += "security tpm tpm2"
#   MACHINE_FEATURES += "tpm tpm2"
#   KERNEL_FEATURES += "features/tpm/tpm.scc"
