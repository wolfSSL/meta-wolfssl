# Disable SHA-512/256 for wolfSSL FIPS compatibility
#
# wolfSSL FIPS does not include SHA-512/256 in its validated algorithm list.
# When using wolfProvider with wolfSSL FIPS, curl's SHA-512/256 based HTTP
# Digest authentication will fail at runtime since the algorithm is unavailable.
#
# By defining CURL_DISABLE_SHA512_256 at compile time, curl properly reports
# the feature as unavailable and tests that require it are skipped rather than
# failing.
CFLAGS:append = " -DCURL_DISABLE_SHA512_256"
