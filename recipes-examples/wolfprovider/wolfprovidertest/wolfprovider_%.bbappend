FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
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

python () {
    wolfprovider_test_dir = d.getVar('WOLFPROVIDER_TEST_DIR', True)
    wolfprovider_test = d.getVar('WOLFPROVIDER_TEST', True)
    wolfprovider_test_bin = d.getVar('WOLFPROVIDER_TEST_BIN', True)
    wolfprovider_install_dir = d.getVar('WOLFPROVIDER_INSTALL_DIR', True)
    wolfprovider_certs_dir = d.getVar('WOLFPROVIDER_CERTS_DIR', True)
    wolfprovider_certs_install_dir = d.getVar('WOLFPROVIDER_CERTS_INSTALL_DIR', True)

    bbnote = 'bbnote "Installing wolfProvider Tests"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolfprovider_install_dir)
    # Install the binary as unit.test (its original name)
    cpTest = 'if [ -f "%s/%s" ]; then cp "%s/%s" "%s/%s"; fi\n' % (wolfprovider_test_dir, wolfprovider_test, wolfprovider_test_dir, wolfprovider_test, wolfprovider_install_dir, wolfprovider_test_bin)
    
    bbnote = 'bbnote "Installing wolfProvider Certificates"\n'
    installCertsDir = 'install -m 0755 -d "%s"\n' % (wolfprovider_certs_install_dir)
    cpCerts = 'if [ -d "%s" ]; then cp -r %s/*.pem %s/ 2>/dev/null || true; fi\n' % (wolfprovider_certs_dir, wolfprovider_certs_dir, wolfprovider_certs_install_dir)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpTest)
    d.appendVar('do_install', installCertsDir)
    d.appendVar('do_install', cpCerts)
}

do_install:append() {
    # Install the wrapper script as wolfprovidertest
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfprovidertest.sh ${D}${bindir}/wolfprovidertest
}

FILES:${PN} += "${bindir}/wolfprovidertest ${bindir}/unit.test ${datadir}/wolfprovider-test/certs/*"
RDEPENDS:${PN} += "bash wolfproviderenv"
