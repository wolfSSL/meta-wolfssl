FILESEXTRAPATHS:prepend := "${WOLFSSL_LAYERDIR}/recipes-examples/wolfprovider/wolfprovidertest/files:"
SRC_URI += "file://wolfprovidertest.sh"

# Override CERTS_DIR to point to the installed location instead of build directory
CFLAGS:append = ' -DCERTS_DIR=\\"/usr/share/wolfprovider-test/certs\\"'
CXXFLAGS:append = ' -DCERTS_DIR=\\"/usr/share/wolfprovider-test/certs\\"'

WOLFPROVIDER_TEST_DIR = "${B}/test/.libs"
WOLFPROVIDER_TEST = "unit.test"
WOLFPROVIDER_TEST_BIN = "unit.test"
WOLFPROVIDER_INSTALL_DIR = "${D}${bindir}"
WOLFPROVIDER_CERTS_DIR = "${S}/certs"
WOLFPROVIDER_CERTS_INSTALL_DIR = "${D}${datadir}/wolfprovider-test/certs"

do_install:append() {
    bbnote "Installing wolfProvider Tests"
    
    # Install the wrapper script as wolfprovidertest
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfprovidertest.sh ${D}${bindir}/wolfprovidertest
    
    # Install the test binary
    if [ -f "${B}/test/.libs/unit.test" ]; then
        install -m 0755 ${B}/test/.libs/unit.test ${D}${bindir}/unit.test
    elif [ -f "${B}/test/unit.test" ]; then
        install -m 0755 ${B}/test/unit.test ${D}${bindir}/unit.test
    elif [ -f "${B}/unit.test" ]; then
        install -m 0755 ${B}/unit.test ${D}${bindir}/unit.test
    fi
    
    # Install test certificates
    bbnote "Installing wolfProvider Certificates"
    install -m 0755 -d ${D}${datadir}/wolfprovider-test/certs
    if [ -d "${S}/certs" ]; then
        cp -r ${S}/certs/*.pem ${D}${datadir}/wolfprovider-test/certs/ 2>/dev/null || true
    fi
}

# Append test files and library files to FILES using Python
python __anonymous() {
    pn = d.getVar('PN')
    
    # Get existing FILES value (set by autotools class and base recipe)
    existing_files = d.getVar('FILES:' + pn) or ''
    
    # Append our test files and ensure base recipe's library files are included
    new_files = existing_files + ' '.join([
        '${bindir}/wolfprovidertest',
        '${bindir}/unit.test',
        '${datadir}/wolfprovider-test/certs/*',
        '${libdir}/libwolfprov.so',
        '${libdir}/libwolfprov.so.*',
        '${libdir}/ssl-3',
        '${libdir}/ssl-3/modules',
        '${libdir}/ssl-3/modules/libwolfprov.so'
    ])
    
    # Set the combined value (this avoids the "replaces original key" warning)
    d.setVar('FILES:' + pn, new_files)
    
    # Same approach for RDEPENDS
    existing_rdepends = d.getVar('RDEPENDS:' + pn) or ''
    new_rdepends = existing_rdepends + ' bash wolfproviderenv'
    d.setVar('RDEPENDS:' + pn, new_rdepends)
    
    # Same approach for INSANE_SKIP
    existing_skip = d.getVar('INSANE_SKIP:' + pn) or ''
    new_skip = existing_skip + ' dev-so build-deps'
    d.setVar('INSANE_SKIP:' + pn, new_skip)
}

