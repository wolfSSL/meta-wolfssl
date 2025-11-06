SUMMARY = "GnuTLS-wolfSSL Test Suite"
DESCRIPTION = "Test applications for verifying gnutls-wolfssl integration. \
This includes tests for cryptographic operations, key exchange, ciphers, and more."
HOMEPAGE = "https://github.com/wolfssl/gnutls-wolfssl"
SECTION = "examples"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

# Use git versioning
PV = "1.0+git${SRCPV}"

DEPENDS = "wolfssl gnutls wolfssl-gnutls-wrapper"
RDEPENDS:${PN} = "wolfssl gnutls wolfssl-gnutls-wrapper bash"

SRC_URI = "git://github.com/wolfssl/gnutls-wolfssl.git;protocol=https;branch=main;destsuffix=git"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git/wolfssl-gnutls-wrapper/tests"

inherit pkgconfig

# Use standard system paths
CFLAGS:append = " \
    -I${STAGING_INCDIR} \
"

LDFLAGS:append = " \
    -L${STAGING_LIBDIR} \
    -Wl,-rpath,${libdir} \
"

do_compile() {
    bbnote "Building GnuTLS-wolfSSL tests..."

    oe_runmake \
        CC="${CC}" \
        CFLAGS="${CFLAGS}" \
        LDFLAGS="${LDFLAGS}" \
        GNUTLS_INSTALL="${STAGING_DIR_TARGET}${prefix}" \
        WOLFSSL_INSTALL="${STAGING_DIR_TARGET}${prefix}" \
        all
}

do_install() {
    # Install tests to /usr/lib/gnutls-wolfssl-tests/
    install -d ${D}${libdir}/gnutls-wolfssl-tests

    # Install Makefile
    install -m 0644 ${S}/Makefile ${D}${libdir}/gnutls-wolfssl-tests/

    # Install all test executables
    for test in ${S}/test_*; do
        if [ -f "$test" ] && [ -x "$test" ]; then
            install -m 0755 "$test" ${D}${libdir}/gnutls-wolfssl-tests/
        fi
    done

    # Install any additional test files
    if [ -f ${S}/run ]; then
        install -m 0755 ${S}/run ${D}${libdir}/gnutls-wolfssl-tests/
    fi

    # Create a helper script to run tests with proper environment
    cat > ${D}${libdir}/gnutls-wolfssl-tests/run-tests.sh << 'EOF'
#!/bin/bash
# Helper script to run GnuTLS-wolfSSL tests with proper environment

export LD_LIBRARY_PATH=${libdir}:$LD_LIBRARY_PATH
export LD_PRELOAD=${libdir}/gnutls/libgnutls-wolfssl-wrapper.so
export GNUTLS_DEBUG_LEVEL=3

echo "=== GnuTLS-wolfSSL Test Environment ==="
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "LD_PRELOAD: $LD_PRELOAD"
echo "Test directory: ${libdir}/gnutls-wolfssl-tests"
echo ""

cd ${libdir}/gnutls-wolfssl-tests

if [ $# -eq 0 ]; then
    echo "Running all tests..."
    make run
else
    echo "Running specific test: $1"
    ./"$1"
fi
EOF

    # Make it executable and substitute variables
    chmod 755 ${D}${libdir}/gnutls-wolfssl-tests/run-tests.sh
    sed -i "s|\${libdir}|${libdir}|g" ${D}${libdir}/gnutls-wolfssl-tests/run-tests.sh

    # Create a convenience symlink in /usr/bin
    install -d ${D}${bindir}
    ln -sf ${libdir}/gnutls-wolfssl-tests/run-tests.sh ${D}${bindir}/gnutls-wolfssl-tests
}

FILES:${PN} = "\
    ${libdir}/gnutls-wolfssl-tests/* \
    ${bindir}/gnutls-wolfssl-tests \
"

# Allow running tests as non-root
INSANE_SKIP:${PN} += "ldflags"
