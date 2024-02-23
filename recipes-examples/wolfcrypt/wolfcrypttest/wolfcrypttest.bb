SUMMARY = "wolfCrypt Test Application"
DESCRIPTION = "wolfCrypt test application used to test crypto algorithm \
               functionality included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://test.c;beginline=1;endline=20;md5=61d63fb8b820bae4d85beb53e7acf340"
S = "${WORKDIR}/git/wolfcrypt/test"
DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfSSL/wolfssl.git;nobranch=1;protocol=https;rev=66596ad9e1d7efa8479656872cf09c9c1870a02e"


do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFCRYPT_TEST_DIR = "${datadir}/wolfcrypt-test"
WOLFCRYPT_TEST_INSTALL_DIR = "${D}${WOLFCRYPT_TEST_DIR}"
WOLFCRYPT_TEST_README = "README.txt"
WOLFCRYPT_TEST_README_DIR = "${WOLFCRYPT_TEST_INSTALL_DIR}/${WOLFCRYPT_TEST_README}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfcrypt_test_dir = d.getVar('WOLFCRYPT_TEST_DIR', True)
    wolfcrypt_test_install_dir = d.getVar('WOLFCRYPT_TEST_INSTALL_DIR', True)
    wolfcrypt_test_readme_dir = d.getVar('WOLFCRYPT_TEST_README_DIR', True)

    bb.note("Installing dummy file for wolfCrypt test example")
    installDir = 'install -m 0755 -d "%s"\n' % wolfcrypt_test_install_dir
    makeDummy = 'echo "This is a dummy package" > "%s"\n' % wolfcrypt_test_readme_dir

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', makeDummy)

    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn
    
    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfcrypt_test_dir + '/*'
    d.setVar(files_var_name, new_files)
}

