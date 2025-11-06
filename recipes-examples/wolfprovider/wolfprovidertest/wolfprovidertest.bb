SUMMARY = "wolfProvider Unit Test Application"
DESCRIPTION = "wolfProvider unit test application used to test provider functionality"
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfprovider/issues"
SECTION = "x11/applications"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://../COPYING;md5=d32239bcb673463ab874e80d47fae504"
S = "${WORKDIR}/git/test"
DEPENDS += "wolfprovider"

SRC_URI = "git://github.com/wolfSSL/wolfProvider.git;nobranch=1;protocol=https;rev=v1.1.0"


do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFPROVIDER_TEST_DIR = "${datadir}/wolfprovider-test"
WOLFPROVIDER_TEST_INSTALL_DIR = "${D}${WOLFPROVIDER_TEST_DIR}"
WOLFPROVIDER_TEST_README = "README.txt"
WOLFPROVIDER_TEST_README_DIR = "${WOLFPROVIDER_TEST_INSTALL_DIR}/${WOLFPROVIDER_TEST_README}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfprovider_test_dir = d.getVar('WOLFPROVIDER_TEST_DIR', True)
    wolfprovider_test_install_dir = d.getVar('WOLFPROVIDER_TEST_INSTALL_DIR', True)
    wolfprovider_test_readme_dir = d.getVar('WOLFPROVIDER_TEST_README_DIR', True)

    bb.note("Installing dummy file for wolfProvider test example")
    installDir = 'install -m 0755 -d "%s"\n' % wolfprovider_test_install_dir
    makeDummy = 'echo "This is a dummy package" > "%s"\n' % wolfprovider_test_readme_dir

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', makeDummy)

    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn

    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfprovider_test_dir + '/*'
    d.setVar(files_var_name, new_files)
}
