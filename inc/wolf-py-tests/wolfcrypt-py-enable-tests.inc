# Enable test directory installation for wolfcrypt-py
#
# This include file configures wolfcrypt-py to install its test directory
# to the target system for running Python binding tests.

inherit wolfssl-compatibility

WOLFCRYPT_PY_TEST_DIR = "${S}"
WOLFCRYPT_PY_DIR = "/home/root/wolf-py-tests/wolfcrypt-py-test"
WOLFCRYPT_PY_TEST_TARGET_DIR = "${D}${WOLFCRYPT_PY_DIR}"

python () {
    wolfcrypt_py_test_dir = d.getVar('WOLFCRYPT_PY_TEST_DIR', True)
    wolfcrypt_py_test_target_dir = d.getVar('WOLFCRYPT_PY_TEST_TARGET_DIR', True)

    installDirCmd = 'install -m 0755 -d "%s"\n' % wolfcrypt_py_test_target_dir
    cpWolfcryptPyTestCmd = 'cp -r %s/* %s\n' % (wolfcrypt_py_test_dir, wolfcrypt_py_test_target_dir)

    d.appendVar('do_install', installDirCmd)
    d.appendVar('do_install', cpWolfcryptPyTestCmd)
}

python __anonymous() {
    pn = d.getVar('PN') or d.getVar('PN', True)
    wolfcrypt_py_dir = d.getVar('WOLFCRYPT_PY_DIR') or d.getVar('WOLFCRYPT_PY_DIR', True)

    wolfssl_varAppend(d, 'FILES', pn, ' ' + wolfcrypt_py_dir + '/*')
}

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1"
