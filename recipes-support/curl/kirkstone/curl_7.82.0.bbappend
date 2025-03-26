PACKAGECONFIG:remove:class-target = "openssl"
DEPENDS:class-target += "wolfssl"
EXTRA_OECONF:class-target += "--with-wolfssl=${STAGING_DIR_HOST}${prefix} \
                                --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
                                "
CPPFLAGS:class-target += "-I${STAGING_DIR_HOST}${prefix}/include/wolfssl"

# Uncomment the line below if you're targeting FIPS compliance. NTLM uses MD5,
# which isn't a FIPS-approved algorithm.
# EXTRA_OECONF:class-target += "--disable-ntlm"
