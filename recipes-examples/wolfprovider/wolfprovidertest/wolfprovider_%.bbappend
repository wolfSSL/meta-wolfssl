FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://wolfprovidertest.sh"

WOLFPROVIDER_TEST_DIR = "${B}/test/.libs"
WOLFPROVIDER_TEST = "unit.test"
WOLFPROVIDER_TEST_BIN = "unit.test"
WOLFPROVIDER_INSTALL_DIR = "${D}${bindir}"

python () {
    wolfprovider_test_dir = d.getVar('WOLFPROVIDER_TEST_DIR', True)
    wolfprovider_test = d.getVar('WOLFPROVIDER_TEST', True)
    wolfprovider_test_bin = d.getVar('WOLFPROVIDER_TEST_BIN', True)
    wolfprovider_install_dir = d.getVar('WOLFPROVIDER_INSTALL_DIR', True)

    bbnote = 'bbnote "Installing wolfProvider Tests"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolfprovider_install_dir)
    # Install the binary as unit.test (its original name)
    cpTest = 'if [ -f "%s/%s" ]; then cp "%s/%s" "%s/%s"; fi\n' % (wolfprovider_test_dir, wolfprovider_test, wolfprovider_test_dir, wolfprovider_test, wolfprovider_install_dir, wolfprovider_test_bin)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpTest)
}

do_install:append() {
    # Install the wrapper script as wolfprovidertest
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfprovidertest.sh ${D}${bindir}/wolfprovidertest
}

FILES:${PN} += "${bindir}/wolfprovidertest ${bindir}/unit.test"
RDEPENDS:${PN} += "bash wolfproviderenv"
