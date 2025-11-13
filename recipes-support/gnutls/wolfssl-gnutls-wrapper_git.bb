SUMMARY = "wolfSSL GnuTLS Crypto Wrapper Library"
DESCRIPTION = "Cryptography wrapper library that registers as a GnuTLS crypto \
provider and delegates cryptographic operations to wolfSSL."
HOMEPAGE = "https://github.com/wolfssl/gnutls-wolfssl"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

PV = "1.0+git${SRCPV}"

DEPENDS = "virtual/wolfssl gnutls"
RDEPENDS:${PN} += "wolfssl gnutls bash"

SRC_URI = "git://github.com/wolfssl/gnutls-wolfssl.git;protocol=https;branch=main;destsuffix=git"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git/wolfssl-gnutls-wrapper"

# Custom installation prefix
WOLFSSL_GNUTLS_PREFIX = "/opt/wolfssl-gnutls-wrapper"

inherit pkgconfig

EXTRA_OEMAKE = " \
    'CC=${CC}' \
    'GNUTLS_INSTALL=${STAGING_DIR_TARGET}${prefix}' \
    'WOLFSSL_INSTALL=${STAGING_DIR_TARGET}${prefix}' \
"

CFLAGS:append = " \
    -I${STAGING_INCDIR} \
    -DENABLE_WOLFSSL \
    -fPIC \
"

LDFLAGS:append = " \
    -L${STAGING_LIBDIR} \
    -Wl,-rpath,${libdir} \
    -Wl,-rpath,${WOLFSSL_GNUTLS_PREFIX}/lib \
    -Wl,--no-as-needed \
    -Wl,-z,now \
"

do_compile() {
    bbnote "Building wolfSSL-GnuTLS wrapper..."

    # Compiling the wrapper
    oe_runmake \
        CC="${CC}" \
        CFLAGS="${CFLAGS}" \
        LDFLAGS="${LDFLAGS}" \
        GNUTLS_INSTALL="${STAGING_DIR_TARGET}${prefix}" \
        WOLFSSL_INSTALL="${STAGING_DIR_TARGET}${prefix}" \
        all

    bbnote "Building GnuTLS-wolfSSL tests..."

    # Compiling tests
    cd ${S}/tests
    oe_runmake \
        CC="${CC}" \
        CFLAGS="${CFLAGS}" \
        LDFLAGS="${LDFLAGS}" \
        GNUTLS_INSTALL="${STAGING_DIR_TARGET}${prefix}" \
        WOLFSSL_INSTALL="${STAGING_DIR_TARGET}${prefix}" \
        PROVIDER_PATH="${WOLFSSL_GNUTLS_PREFIX}" \
        all
}

do_install:class-target() {
    # Install to /usr/lib/gnutls
    install -d ${D}${libdir}
    if [ -f ${S}/libgnutls-wolfssl-wrapper.so ]; then
        install -m 0755 ${S}/libgnutls-wolfssl-wrapper.so ${D}${libdir}
        bbnote "Installed wrapper to ${D}${libdir}"
    else
        bbwarn "Wrapper library not found"
        ls -la ${S}/ || true
    fi

    # Install headers if they exist
    if [ -d ${S}/include ]; then
        install -d ${D}${includedir}/gnutls-wolfssl-wrapper
        install -m 0644 ${S}/include/*.h ${D}${includedir}/gnutls-wolfssl-wrapper/ || true
    fi

    # Install pkg-config file if it exists
    if [ -f ${S}/gnutls-wolfssl-wrapper.pc ]; then
        install -d ${D}${libdir}/pkgconfig
        install -m 0644 ${S}/gnutls-wolfssl-wrapper.pc ${D}${libdir}/pkgconfig/
    fi

    # Create compatibility symlinks for hardcoded /opt paths
    install -d ${D}/opt/wolfssl-gnutls-wrapper/lib
    ln -sf ${libdir}/libgnutls-wolfssl-wrapper.so \
        ${D}/opt/wolfssl-gnutls-wrapper/lib/libgnutls-wolfssl-wrapper.so

    # Install tests to /opt/wolfssl-gnutls-wrapper/tests
    bbnote "Installing GnuTLS-wolfSSL tests..."
    install -d ${D}${WOLFSSL_GNUTLS_PREFIX}/tests

    # Install Makefile
    install -m 0644 ${S}/tests/Makefile ${D}${WOLFSSL_GNUTLS_PREFIX}/tests/

    # Install test utility header
    if [ -f ${S}/tests/test_util.h ]; then
        install -m 0644 ${S}/tests/test_util.h ${D}${WOLFSSL_GNUTLS_PREFIX}/tests/
    fi

    # Install all test executables
    for test in ${S}/tests/test_*; do
        if [ -f "$test" ] && [ -x "$test" ]; then
            install -m 0755 "$test" ${D}${WOLFSSL_GNUTLS_PREFIX}/tests/
        fi
    done

    # Install any additional test files
    if [ -f ${S}/tests/run ]; then
        install -m 0755 ${S}/tests/run ${D}${WOLFSSL_GNUTLS_PREFIX}/tests/
    fi

    # Create a helper script to run tests with proper environment
    cat > ${D}${WOLFSSL_GNUTLS_PREFIX}/tests/run-tests.sh << 'EOF'
#!/bin/bash
# Helper script to run GnuTLS-wolfSSL tests with proper environment

export LD_LIBRARY_PATH=/usr/lib:/opt/wolfssl-gnutls-wrapper/lib:$LD_LIBRARY_PATH
export LD_PRELOAD=/opt/wolfssl-gnutls-wrapper/lib/libgnutls-wolfssl-wrapper.so
export GNUTLS_DEBUG_LEVEL=3

# Optional: Enable FIPS mode
# export GNUTLS_FORCE_FIPS_MODE=1

echo "=== GnuTLS-wolfSSL Test Environment ==="
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "LD_PRELOAD: $LD_PRELOAD"
echo "Test directory: /opt/wolfssl-gnutls-wrapper/tests"
echo ""

cd /opt/wolfssl-gnutls-wrapper/tests

if [ $# -eq 0 ]; then
    echo "Running all tests..."
    make run
else
    echo "Running specific test: $1"
    ./"$1"
fi
EOF

    chmod 755 ${D}${WOLFSSL_GNUTLS_PREFIX}/tests/run-tests.sh

    # Create a convenience symlink in /usr/bin
    install -d ${D}${bindir}
    ln -sf ${WOLFSSL_GNUTLS_PREFIX}/tests/run-tests.sh ${D}${bindir}/gnutls-wolfssl-tests
}

FILES:${PN}:class-target = "\
    ${libdir}/*.so \
    /opt/wolfssl-gnutls-wrapper/lib/*.so \
    ${WOLFSSL_GNUTLS_PREFIX}/tests/* \
    ${bindir}/gnutls-wolfssl-tests \
"

FILES:${PN}-dev:class-target = "\
    ${includedir}/* \
    ${libdir}/pkgconfig/* \
"

INSANE_SKIP:${PN}:class-target += "dev-so ldflags"
SOLIBS:class-target = ".so"
FILES_SOLIBSDEV:class-target = ""
