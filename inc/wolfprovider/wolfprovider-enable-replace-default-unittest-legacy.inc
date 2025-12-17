# Enable replace default unit tests with wolfProvider

# Also export as environment variable for configure script compatibility
export WOLFPROV_REPLACE_DEFAULT = "1"
export WOLFPROV_REPLACE_DEFAULT_TESTING = "1"

# Enable unit tests that use internal OpenSSL provider functions
# These functions (ossl_provider_new, ossl_provider_activate, etc.) are only available
# when OpenSSL is patched with the replace-default patch
CPPFLAGS_append = " -DWOLFPROV_REPLACE_DEFAULT"
CPPFLAGS_append = " -DWOLFPROV_REPLACE_DEFAULT_UNIT_TEST"
CPPFLAGS_append = " -DWOLFPROV_QUICKTEST"


