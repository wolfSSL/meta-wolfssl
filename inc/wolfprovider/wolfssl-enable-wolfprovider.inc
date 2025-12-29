# Configuration to enable wolfprovider support in wolfssl
# To enable debug add `--enable-debug --enable-keylog-export` to EXTRA_OECONF

inherit wolfssl-compatibility

EXTRA_OECONF += " --enable-all-crypto --with-eccminsz=192 --with-max-ecc-bits=1024 --enable-opensslcoexist --enable-sha"
TARGET_CFLAGS += " -DWC_RSA_NO_PADDING -DWOLFSSL_PUBLIC_MP -DHAVE_PUBLIC_FFDHE -DHAVE_FFDHE_6144 -DHAVE_FFDHE_8192 -DWOLFSSL_PSS_LONG_SALT -DWOLFSSL_PSS_SALT_LEN_DISCOVER -DRSA_MIN_SIZE=1024 -DWOLFSSL_OLD_OID_SUM"

# Use a marker file to signal we are a non-FIPS build
WOLFSSL_ISFIPS = "0"

do_install_wolfprovider() {
    install -d ${D}${sysconfdir}/wolfssl
    echo "0" > ${D}${sysconfdir}/wolfssl/fips-enabled
}

addtask do_install_wolfprovider after do_install before do_package
do_install_wolfprovider[fakeroot] = "1"

