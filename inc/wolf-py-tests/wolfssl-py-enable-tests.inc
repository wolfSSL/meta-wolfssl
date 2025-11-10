# Enable test directory installation for wolfssl-py
#
# This include file configures wolfssl-py to install its test directory
# to the target system for running Python binding tests.

WOLFSSL_PY_TEST_DIR = "${S}"
WOLFSSL_PY_DIR = "/home/root/wolf-py-tests/wolfssl-py-test"
WOLFSSL_PY_TEST_TARGET_DIR = "${D}${WOLFSSL_PY_DIR}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfssl_py_test_dir = d.getVar('WOLFSSL_PY_TEST_DIR', True)
    wolfssl_py_test_target_dir = d.getVar('WOLFSSL_PY_TEST_TARGET_DIR', True)

    installDir = 'install -m 0755 -d "%s"\n' % (wolfssl_py_test_target_dir)
    cpWolfsslPyTest = 'cp -r %s/* %s\n' % (wolfssl_py_test_dir, wolfssl_py_test_target_dir)

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpWolfsslPyTest)

    # Append to FILES:${PN} within the Python function
    pn = d.getVar('PN', True)
    wolfssl_py_dir = d.getVar('WOLFSSL_PY_DIR', True)
    
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn    
    
    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfssl_py_dir + '/*'
    d.setVar(files_var_name, new_files)
}

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1"

