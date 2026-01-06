# Enable test directory installation for wolfcrypt-py
#
# This include file configures wolfcrypt-py to install its test directory
# to the target system for running Python binding tests.

WOLFCRYPT_PY_TEST_DIR = "${S}"
WOLFCRYPT_PY_DIR = "/home/root/wolf-py-tests/wolfcrypt-py-test"
WOLFCRYPT_PY_TEST_TARGET_DIR = "${D}${WOLFCRYPT_PY_DIR}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfcrypt_py_test_dir = d.getVar('WOLFCRYPT_PY_TEST_DIR', True)
    wolfcrypt_py_test_target_dir = d.getVar('WOLFCRYPT_PY_TEST_TARGET_DIR', True)

    installDirCmd = 'install -m 0755 -d "%s"\n' % wolfcrypt_py_test_target_dir
    cpWolfcryptPyTestCmd = 'cp -r %s/* %s\n' % (wolfcrypt_py_test_dir, wolfcrypt_py_test_target_dir)

    d.appendVar('do_install', installDirCmd)
    d.appendVar('do_install', cpWolfcryptPyTestCmd)

    pn = d.getVar('PN', True)
    wolfcrypt_py_dir = d.getVar('WOLFCRYPT_PY_DIR', True)

    # Legacy always uses underscore syntax
    files_var_name = 'FILES_' + pn

    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfcrypt_py_dir + '/*'
    d.setVar(files_var_name, new_files)
}

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1"
