FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Override version and source for target builds only
PV:class-target = "3.8.9+git${SRCPV}"
LIC_FILES_CHKSUM:class-target = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://COPYING.LESSERv2;md5=4bf661c1e3793e55c8d1051bc5e0ae21"

# Add gnutls-wolfssl specific dependencies
DEPENDS:append:class-target = " virtual/wolfssl libunistring gmp nettle libtasn1 p11-kit zlib \
           bison-native libtasn1-native gperf-native gtk-doc-native gettext-native \
           autoconf-native automake-native libtool-native"
RDEPENDS:${PN}:append:class-target = " wolfssl"

# Use wolfSSL fork of gnutls
SRC_URI:class-target = "git://github.com/wolfSSL/gnutls.git;protocol=https;branch=gnutls-wolfssl \
                        file://0001-creating-hmac-file-should-be-excuted-in-target-envi.patch \
"
SRCREV:class-target = "${AUTOREV}"
S:class-target = "${WORKDIR}/git"
B:class-target = "${S}"

# Enable FIPS mode
PACKAGECONFIG:append:class-target = " fips"

# Configure options for wolfSSL backend
EXTRA_OECONF:class-target = "\
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

TARGET_CFLAGS:append:class-target = " -DGNUTLS_WOLFSSL"

# Create dummy files so base prepend doesn't fail
do_configure:prepend:class-target() {
    touch ${WORKDIR}/04939b75417cc95b7372c6f208c4bda4579bdc34
    touch ${WORKDIR}/5477db1bb507a35e8833c758ce344f4b5b246d8e
    touch ${WORKDIR}/3e94dcdff862ef5d6db8b5cc8e59310b5f0cdfe2
}

do_configure:class-target() {
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
