# Enable replace default unit tests with wolfProvider

inherit wolfssl-compatibility

# Also export as environment variable for configure script compatibility
export WOLFPROV_REPLACE_DEFAULT = "1"
export WOLFPROV_REPLACE_DEFAULT_TESTING = "1"

# Enable unit tests that use internal OpenSSL provider functions
# These functions (ossl_provider_new, ossl_provider_activate, etc.) are only available
# when OpenSSL is patched with the replace-default patch
python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'CPPFLAGS', ' -DWOLFPROV_REPLACE_DEFAULT')
    wolfssl_varAppendNonOverride(d, 'CPPFLAGS', ' -DWOLFPROV_REPLACE_DEFAULT_UNIT_TEST')
    wolfssl_varAppendNonOverride(d, 'CPPFLAGS', ' -DWOLFPROV_QUICKTEST')
}
