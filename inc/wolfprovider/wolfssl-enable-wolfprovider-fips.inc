# Configuration to enable wolfprovider FIPS support in wolfssl

EXTRA_OECONF += " --enable-fips=v5 --enable-opensslcoexist"
TARGET_CFLAGS += " -DWOLFSSL_OLD_OID_SUM -DWOLFSSL_DH_EXTRA"

# Use a marker file to signal we are a FIPS build
WOLFSSL_ISFIPS = "1"

# commercial bundle missing stamp-h.in required by automake with 5.2.1
do_configure:prepend() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}

do_install:append() {
    install -d ${D}${sysconfdir}/wolfssl
    echo "1" > ${D}${sysconfdir}/wolfssl/fips-enabled
}


