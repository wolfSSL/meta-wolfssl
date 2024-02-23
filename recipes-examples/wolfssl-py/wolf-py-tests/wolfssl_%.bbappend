WOLFSSL_PY_TEST_CERTS_DIR = "/home/root/wolf-py-tests/certs"
WOLFSSL_PY_CERTS_DIR = "/certs"
WOLFSSL_PY_CERTS_INSTALL_DIR = "${D}${WOLFSSL_PY_TEST_CERTS_DIR}"
WOLFSSL_PY_CERTS_SOURCE_DIR = "${S}${WOLFSSL_PY_CERTS_DIR}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
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


    pn = d.getVar('PN', True)
    wolfssl_py_test_certs_dir = d.getVar('WOLFSSL_PY_TEST_CERTS_DIR', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn
    
    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfssl_py_test_certs_dir + '/*'
    d.setVar(files_var_name, new_files)
}
