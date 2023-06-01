SUMMARY = "wolfCrypt Python, a.k.a. wolfcrypt is a Python module that \
           encapsulates wolfSSL's wolfCrypt API."
           
DESCRIPTION = "wolfCrypt is a lightweight, portable, C-language-based crypto \
               library targeted at IoT, embedded, and RTOS environments \
               primarily because of its size, speed, and feature set. It works \
               seamlessly in desktop, enterprise, and cloud environments as \
               well. It is the crypto engine behind wolfSSL's embedded ssl \
               library."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl"
BUGTRACKER = "https://github.com/wolfSSL/wolfcrypt-py/issues"
SECTION = "libs"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSING.rst;md5=e4abd0c56c3f6dc95a7a7eed4c77414b"




SRC_URI = "git://github.com/wolfSSL/wolfcrypt-py.git;nobranch=1;protocol=https;rev=1c242652a799190b55cc20964135297357e00b67"


DEPENDS += " wolfssl \
            python3-pip-native \
            python3-cffi-native \
            python3-native \
            "

inherit setuptools3  

S = "${WORKDIR}/git"


WOLFSSL_YOCTO_DIR = "${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"


do_compile:prepend(){
    export USE_LOCAL_WOLFSSL=${WOLFSSL_YOCTO_DIR}
    

}



