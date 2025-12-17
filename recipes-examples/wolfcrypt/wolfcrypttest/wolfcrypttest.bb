SUMMARY = "wolfCrypt Test Application"
DESCRIPTION = "wolfCrypt test application used to test crypto algorithm \
               functionality included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://test.c;beginline=1;endline=20;md5=928770bfaa2d2704ecffeb131cc7bfd8"
S = "${WORKDIR}/git/wolfcrypt/test"
DEPENDS += "virtual/wolfssl"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
}

SRC_URI = "git://github.com/wolfSSL/wolfssl.git;nobranch=1;protocol=https;rev=59f4fa568615396fbf381b073b220d1e8d61e4c2"


do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFCRYPT_TEST_DIR = "${datadir}/wolfcrypt-test"
WOLFCRYPT_TEST_INSTALL_DIR = "${D}${WOLFCRYPT_TEST_DIR}"
WOLFCRYPT_TEST_README = "README.txt"
WOLFCRYPT_TEST_README_DIR = "${WOLFCRYPT_TEST_INSTALL_DIR}/${WOLFCRYPT_TEST_README}"

do_install_wolfcrypttest_dummy() {
    bbnote "Installing dummy file for wolfCrypt test example"
    install -m 0755 -d "${WOLFCRYPT_TEST_INSTALL_DIR}"
    echo "This is a dummy package" > "${WOLFCRYPT_TEST_README_DIR}"
}

addtask do_install_wolfcrypttest_dummy after do_install before do_package
do_install_wolfcrypttest_dummy[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFCRYPT_TEST_DIR}/*')
}
