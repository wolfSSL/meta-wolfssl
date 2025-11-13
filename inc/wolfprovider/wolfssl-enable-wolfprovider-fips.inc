# Configuration to enable wolfprovider FIPS support in wolfssl

EXTRA_OECONF += " --enable-fips=v5 --enable-opensslcoexist"
TARGET_CFLAGS += " -DWOLFSSL_OLD_OID_SUM -DWOLFSSL_DH_EXTRA"

# Use a marker file to signal we are a FIPS build
WOLFSSL_ISFIPS = "1"

do_install:append() {
    install -d ${D}${sysconfdir}/wolfssl
    echo "1" > ${D}${sysconfdir}/wolfssl/fips-enabled
}

FILES:${PN} += "${sysconfdir}/wolfssl/fips-enabled"


