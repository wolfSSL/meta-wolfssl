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

WOLF_PY_TEST_TARGET_DIR = "/home/root/wolf-py-tests"
WOLF_PY_TEST_README = "README.txt"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${WOLF_PY_TEST_TARGET_DIR}
    echo "This is a dummy package" > ${D}${WOLF_PY_TEST_TARGET_DIR}/${WOLF_PY_TEST_README}
}

FILES:${PN} += "${WOLF_PY_TEST_TARGET_DIR}/${WOLF_PY_TEST_README}"
