# Configuration to enable wolfprovider FIPS Ready support in wolfssl
# To enable debug add `--enable-debug --enable-keylog-export` to EXTRA_OECONF

EXTRA_OECONF += " --enable-fips=ready --enable-opensslcoexist"
TARGET_CFLAGS += " -DWOLFSSL_OLD_OID_SUM -DWOLFSSL_DH_EXTRA"

# Use a marker file to signal we are a FIPS Ready build
WOLFSSL_ISFIPS = "1"

# bundle missing stamp-h.in required by automake
do_configure_prepend() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}

do_install_append() {
    install -d ${D}${sysconfdir}/wolfssl
    echo "1" > ${D}${sysconfdir}/wolfssl/fips-enabled
}
