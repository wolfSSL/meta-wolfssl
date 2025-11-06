FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Override version and source for target builds only
PV:class-target = "3.8.9+git${SRCPV}"

LIC_FILES_CHKSUM:class-target = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464 \
                    file://COPYING.LESSERv2;md5=4bf661c1e3793e55c8d1051bc5e0ae21"

# Add gnutls-wolfssl specific dependencies
DEPENDS:append:class-target = " wolfssl libunistring gmp nettle libtasn1 p11-kit zlib \
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
"

TARGET_CFLAGS:append:class-target = " -DGNUTLS_WOLFSSL"

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

# Skip the prepend from the base recipe for target builds
do_configure:prepend:class-target() {
    :
}

# Install fipshmac binary for target
do_install:append:class-target() {
    if ${@bb.utils.contains('PACKAGECONFIG', 'fips', 'true', 'false', d)}; then
        install -d ${D}${bindir}
        if [ -f ${B}/lib/.libs/fipshmac ]; then
            install -m 0755 ${B}/lib/.libs/fipshmac ${D}${bindir}/
            bbnote "Installed fipshmac to ${D}${bindir}/"
        else
            bbwarn "fipshmac not found at ${B}/lib/.libs/fipshmac"
        fi
    fi
}

# Generate HMAC files on target after installation
pkg_postinst_ontarget:${PN}-fips:class-target() {
    if test -x ${bindir}/fipshmac; then
        echo "Generating FIPS HMAC files for GnuTLS (wolfSSL backend)..."

        # Create config directory
        mkdir -p ${sysconfdir}/gnutls
        touch ${sysconfdir}/gnutls/config

        # Set library paths if needed
        export LD_LIBRARY_PATH=${libdir}:$LD_LIBRARY_PATH

        # Generate HMAC for libgnutls
        if ls ${libdir}/libgnutls.so.30.*.* >/dev/null 2>&1; then
            ${bindir}/fipshmac ${libdir}/libgnutls.so.30.*.* > ${libdir}/.libgnutls.so.30.hmac 2>&1 || \
                echo "Warning: Failed to generate HMAC for libgnutls"
        fi

        # Generate HMACs for dependent libraries (adjust as needed for wolfSSL)
        # Note: These may be in different locations when using wolfSSL
        if ls ${libdir}/libnettle.so.8.* >/dev/null 2>&1; then
            ${bindir}/fipshmac ${libdir}/libnettle.so.8.* > ${libdir}/.libnettle.so.8.hmac 2>&1 || true
        fi

        if ls ${libdir}/libgmp.so.10.*.* >/dev/null 2>&1; then
            ${bindir}/fipshmac ${libdir}/libgmp.so.10.*.* > ${libdir}/.libgmp.so.10.hmac 2>&1 || true
        fi

        if ls ${libdir}/libhogweed.so.6.* >/dev/null 2>&1; then
            ${bindir}/fipshmac ${libdir}/libhogweed.so.6.* > ${libdir}/.libhogweed.so.6.hmac 2>&1 || true
        fi

        echo "FIPS HMAC generation complete"
    else
        echo "Warning: fipshmac not found at ${bindir}/fipshmac"
    fi
}
