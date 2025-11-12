SUMMARY = "wolfSSL Python, a.k.a. wolfssl, is a Python module that encapsulates \
           wolfSSL's SSL/TLS library."
DESCRIPTION = "The wolfSSL SSL/TLS library is a lightweight, portable, \
               C-language-based library targeted at IoT, embedded, and RTOS \
               environments primarily because of its size, speed, and feature \
               set. It works seamlessly in desktop, enterprise, and cloud \
               environments as well."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl"
BUGTRACKER = "https://github.com/wolfSSL/wolfssl-py/issues"
SECTION = "libs"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSING.rst;md5=e4abd0c56c3f6dc95a7a7eed4c77414b"

SRC_URI = "git://github.com/wolfSSL/wolfssl-py.git;nobranch=1;protocol=https;rev=0a8a76c6d426289d9019e10d02db9a5af051fba8"

DEPENDS += " wolfssl-py \
             wolfcrypt-py \
           "  

S = "${WORKDIR}/git"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFCRYPT_TEST_PY_DIR = "/home/root/wolf-py-tests"
WOLFCRYPT_TEST_PY_INSTALL_DIR = "${D}${WOLFCRYPT_TEST_PY_DIR}"
WOLFCRYPT_TEST_PY_README = "README.txt"
WOLFCRYPT_TEST_PY_README_DIR = "${WOLFCRYPT_TEST_PY_INSTALL_DIR}/${WOLFCRYPT_TEST_PY_README}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfcrypt_test_py_dir = d.getVar('WOLFCRYPT_TEST_PY_DIR', True)
    wolfcrypt_test_py_install_dir = d.getVar('WOLFCRYPT_TEST_PY_INSTALL_DIR', True)
    wolfcrypt_test_py_readme_dir = d.getVar('WOLFCRYPT_TEST_PY_README_DIR', True)

    bbnote = 'bbnote "Installing dummy file for wolfCrypt test example"\n'
    installDir = 'install -m 0755 -d "%s"\n' % wolfcrypt_test_py_install_dir
    makeDummy = 'echo "This is a dummy package" > "%s"\n' % wolfcrypt_test_py_readme_dir

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', makeDummy)

    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn
    
    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfcrypt_test_py_dir + '/*'
    d.setVar(files_var_name, new_files)
}
