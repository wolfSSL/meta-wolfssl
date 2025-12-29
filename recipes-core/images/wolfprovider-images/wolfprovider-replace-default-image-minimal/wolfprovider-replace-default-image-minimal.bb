SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfProvider in replace-default mode"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, and wolfProvider configured to replace OpenSSL's default provider"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'IMAGE_INSTALL', ' wolfssl wolfprovider openssl openssl-bin openssl-ptest wolfprovidertest wolfprovidercmd wolfproviderenv bash')
}

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb
