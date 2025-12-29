# Configuration to enable wolf-py-tests support in wolfssl
# Python tests may need specific features enabled

inherit wolfssl-compatibility

EXTRA_OECONF += "--enable-shared"

WOLFSSL_PY_TEST_CERTS_DIR = "/home/root/wolf-py-tests/certs"
WOLFSSL_PY_CERTS_DIR = "/certs"
WOLFSSL_PY_CERTS_INSTALL_DIR = "${D}${WOLFSSL_PY_TEST_CERTS_DIR}"
WOLFSSL_PY_CERTS_SOURCE_DIR = "${S}${WOLFSSL_PY_CERTS_DIR}"

python () {
    wolfssl_py_certs_install_dir = d.getVar('WOLFSSL_PY_CERTS_INSTALL_DIR', True)
    wolfssl_py_certs_source_dir = d.getVar('WOLFSSL_PY_CERTS_SOURCE_DIR', True)

    bbnote = 'bbnote "Installing Certs Directory for wolf-py Tests"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolfssl_py_certs_install_dir)
    cpDer = 'cp -r %s/*.der %s\n' % (wolfssl_py_certs_source_dir, wolfssl_py_certs_install_dir)
    cpPem = 'cp -r %s/*.pem %s\n' % (wolfssl_py_certs_source_dir, wolfssl_py_certs_install_dir)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpDer)
    d.appendVar('do_install', cpPem)
}

python __anonymous() {
    pn = d.getVar('PN') or d.getVar('PN', True)
    wolfssl_py_test_certs_dir = d.getVar('WOLFSSL_PY_TEST_CERTS_DIR') or d.getVar('WOLFSSL_PY_TEST_CERTS_DIR', True)

    wolfssl_varAppend(d, 'FILES', pn, ' ' + wolfssl_py_test_certs_dir + '/*')
}
