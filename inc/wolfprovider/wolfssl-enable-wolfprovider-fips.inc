# Configuration to enable wolfprovider FIPS support in wolfssl
# To enable debug add `--enable-debug --enable-keylog-export` to EXTRA_OECONF

inherit wolfssl-compatibility

EXTRA_OECONF += " --enable-fips=v5 --enable-opensslcoexist"
TARGET_CFLAGS += " -DWOLFSSL_OLD_OID_SUM -DWOLFSSL_DH_EXTRA"

# Use a marker file to signal we are a FIPS build
WOLFSSL_ISFIPS = "1"

# commercial bundle missing stamp-h.in required by automake with 5.2.1
do_create_stamp_h() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}

addtask do_create_stamp_h after do_unpack before do_configure


do_install_wolfprovider_fips() {
    install -d ${D}${sysconfdir}/wolfssl
    echo "1" > ${D}${sysconfdir}/wolfssl/fips-enabled
}

addtask do_install_wolfprovider_fips after do_install before do_package
do_install_wolfprovider_fips[fakeroot] = "1"

