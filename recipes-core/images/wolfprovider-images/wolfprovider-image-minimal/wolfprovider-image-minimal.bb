SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfProvider"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, test/benchmark utilities, and wolfProvider for OpenSSL 3.x integration"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'IMAGE_INSTALL', ' wolfssl wolfprovider openssl openssl-bin wolfprovidertest wolfprovidercmd wolfproviderenv bash')
}

require recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb
