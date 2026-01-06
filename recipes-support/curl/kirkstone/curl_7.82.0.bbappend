inherit wolfssl-compatibility

PACKAGECONFIG_remove_class-target = "openssl"
DEPENDS_class-target += "virtual/wolfssl"
EXTRA_OECONF_class-target += "--with-wolfssl=${STAGING_DIR_HOST}${prefix} \
                                --with-ca-bundle=${sysconfdir}/ssl/certs/ca-certificates.crt \
                                "
CPPFLAGS_class-target += "-I${STAGING_DIR_HOST}${prefix}/include/wolfssl"

# Uncomment the line below if you're targeting FIPS compliance. NTLM uses MD5,
# which isn't a FIPS-approved algorithm.
# EXTRA_OECONF_class-target += "--disable-ntlm"

python __anonymous() {
    if bb.data.inherits_class('target', d):
        # Add the directory where the patch is located to the search path
        wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/../patches:')
        wolfssl_varAppendNonOverride(d, 'SRC_URI', ' file://wolfssl-m4-options-fix.patch')
}
