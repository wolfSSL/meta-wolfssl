PACKAGECONFIG:remove:class-target = "openssl"
DEPENDS:class-target += "virtual/wolfssl"
EXTRA_OECONF:class-target += "--with-wolfssl=${STAGING_DIR_HOST}${prefix} \
                                --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
                                "
CPPFLAGS:class-target += "-I${STAGING_DIR_HOST}${prefix}/include/wolfssl"

# Uncomment the line below if you're targeting FIPS compliance. NTLM uses MD5,
# which isn't a FIPS-approved algorithm.
# EXTRA_OECONF:class-target += "--disable-ntlm"

# Add the directory where the patch is located to the search path
FILESEXTRAPATHS:prepend := "${THISDIR}/../patches:"

SRC_URI += "file://wolfssl-m4-options-fix.patch"