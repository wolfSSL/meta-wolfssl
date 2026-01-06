SUMMARY = "wolfProvider Unit Test Application"
DESCRIPTION = "wolfProvider unit test application used to test provider functionality"
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfprovider/issues"
SECTION = "x11/applications"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-3.0-only;md5=c79ff39f19dfec6d293b95dea7b07891"
DEPENDS += "wolfprovider"

inherit wolfssl-compatibility

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFPROVIDER_TEST_DIR = "${datadir}/wolfprovider-test"
WOLFPROVIDER_TEST_INSTALL_DIR = "${D}${WOLFPROVIDER_TEST_DIR}"
WOLFPROVIDER_TEST_README = "README.txt"
WOLFPROVIDER_TEST_README_DIR = "${WOLFPROVIDER_TEST_INSTALL_DIR}/${WOLFPROVIDER_TEST_README}"

do_install_wolfprovidertest_dummy() {
    bbnote "Installing dummy file for wolfProvider test example"
    install -m 0755 -d "${WOLFPROVIDER_TEST_INSTALL_DIR}"
    echo "This is a dummy package" > "${WOLFPROVIDER_TEST_README_DIR}"
}

addtask do_install_wolfprovidertest_dummy after do_install before do_package
do_install_wolfprovidertest_dummy[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFPROVIDER_TEST_DIR}/*')
}
