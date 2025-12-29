# Enable test directory installation for wolfssl-py
#
# This include file configures wolfssl-py to install its test directory
# to the target system for running Python binding tests.

inherit wolfssl-compatibility

WOLFSSL_PY_TEST_DIR = "${S}"
WOLFSSL_PY_DIR = "/home/root/wolf-py-tests/wolfssl-py-test"
WOLFSSL_PY_TEST_TARGET_DIR = "${D}${WOLFSSL_PY_DIR}"

python () {
    wolfssl_py_test_dir = d.getVar('WOLFSSL_PY_TEST_DIR', True)
    wolfssl_py_test_target_dir = d.getVar('WOLFSSL_PY_TEST_TARGET_DIR', True)

    installDir = 'install -m 0755 -d "%s"\n' % (wolfssl_py_test_target_dir)
    cpWolfsslPyTest = 'cp -r %s/* %s\n' % (wolfssl_py_test_dir, wolfssl_py_test_target_dir)

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpWolfsslPyTest)
}

python __anonymous() {
    pn = d.getVar('PN') or d.getVar('PN', True)
    wolfssl_py_dir = d.getVar('WOLFSSL_PY_DIR') or d.getVar('WOLFSSL_PY_DIR', True)

    wolfssl_varAppend(d, 'FILES', pn, ' ' + wolfssl_py_dir + '/*')
}

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1"
