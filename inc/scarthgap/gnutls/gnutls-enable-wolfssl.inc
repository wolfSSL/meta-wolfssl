inherit wolfssl-compatibility

# Override version and source for target builds only
PV_class-target = "3.8.11+git${SRCPV}"
LIC_FILES_CHKSUM_class-target = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://COPYING.LESSERv2;md5=4bf661c1e3793e55c8d1051bc5e0ae21"

S_class-target = "${WORKDIR}/git"
B_class-target = "${S}"
SRCREV_class-target = "${AUTOREV}"

# Configure options for wolfSSL backend
EXTRA_OECONF_class-target = "\
    --disable-doc \
    --disable-manpages \
    --disable-gtk-doc \
    --disable-gost \
    --disable-dsa \
    --disable-full-test-suite \
    --disable-valgrind-tests \
    --disable-dependency-tracking \
    --enable-srp-authentication \
    --enable-fips140-mode \
"

TARGET_CFLAGS_append_class-target = " -DGNUTLS_WOLFSSL"

python __anonymous() {
    if bb.data.inherits_class('target', d):
        wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/files:')
        wolfssl_varAppendNonOverride(d, 'DEPENDS', ' virtual/wolfssl libunistring gmp nettle libtasn1 p11-kit zlib bison-native libtasn1-native gperf-native gtk-doc-native gettext-native autoconf-native automake-native libtool-native')
        wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
        wolfssl_varAppendNonOverride(d, 'PACKAGECONFIG', ' fips')
        wolfssl_varAppendNonOverride(d, 'SRC_URI', ' git://github.com/wolfSSL/gnutls.git;protocol=https;branch=gnutls-wolfssl-3.8.11 file://0001-creating-hmac-file-should-be-excuted-in-target-envi.patch')
}

# Create dummy files so base prepend doesn't fail
do_configure_create_dummy_files() {
    touch ${WORKDIR}/04939b75417cc95b7372c6f208c4bda4579bdc34
    touch ${WORKDIR}/5477db1bb507a35e8833c758ce344f4b5b246d8e
    touch ${WORKDIR}/3e94dcdff862ef5d6db8b5cc8e59310b5f0cdfe2
}

addtask do_configure_create_dummy_files after do_unpack before do_configure
do_configure_create_dummy_files[class-target] = ""

do_configure_class-target() {
    cd ${S}
    if [ ! -f configure ]; then
        bbnote "Running bootstrap..."
        ./bootstrap
    fi
    bbnote "Running autoreconf..."
    autoreconf -fvi
    bbnote "Running configure..."
    oe_runconf
}

do_configure[network] = "1"
