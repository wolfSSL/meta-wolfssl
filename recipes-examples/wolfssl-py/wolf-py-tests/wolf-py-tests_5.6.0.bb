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

inherit wolfssl-compatibility

S = "${WORKDIR}/git"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFCRYPT_TEST_PY_DIR = "/home/root/wolf-py-tests"
WOLFCRYPT_TEST_PY_INSTALL_DIR = "${D}${WOLFCRYPT_TEST_PY_DIR}"
WOLFCRYPT_TEST_PY_README = "README.txt"
WOLFCRYPT_TEST_PY_README_DIR = "${WOLFCRYPT_TEST_PY_INSTALL_DIR}/${WOLFCRYPT_TEST_PY_README}"

do_install_wolf_py_tests_dummy() {
    bbnote "Installing dummy file for wolfCrypt test example"
    install -m 0755 -d "${WOLFCRYPT_TEST_PY_INSTALL_DIR}"
    echo "This is a dummy package" > "${WOLFCRYPT_TEST_PY_README_DIR}"
}

addtask do_install_wolf_py_tests_dummy after do_install before do_package
do_install_wolf_py_tests_dummy[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFCRYPT_TEST_PY_DIR}/*')
}
