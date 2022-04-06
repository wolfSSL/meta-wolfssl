PACKAGECONFIG_remove = "openssl"
DEPENDS += "wolfssl"
EXTRA_OECONF += "--with-wolfssl=${STAGING_DIR_HOST}${prefix}"
CPPFLAGS += "-I${STAGING_DIR_HOST}${prefix}/include/wolfssl"

# Uncomment the line below if you're targeting FIPS compliance. NTLM uses MD5,
# which isn't a FIPS-approved algorithm.
# EXTRA_OECONF += "--disable-ntlm"
