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

SRC_URI = "git://github.com/wolfSSL/wolfssl-py.git;nobranch=1;protocol=https;rev=e601a8bce4bad619d7732a589724a269e4fdb979"


DEPENDS += " wolfssl \
             python3-pip-native \
             python3-cffi-native \
             python3-cffi \
             python3-native \
             python3 \ 
           "

RDEPENDS_${PN} += " python3 \
                    python3-cffi \
                  "

inherit setuptools3  

S = "${WORKDIR}/git"

WOLFSSL_YOCTO_DIR = "${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"

export USE_LOCAL_WOLFSSL="${WOLFSSL_YOCTO_DIR}"

# Add reproducible build flags
CFLAGS += " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS += " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS += " -Wl,--build-id=none"

# Ensure consistent locale for build reproducibility
export LC_ALL = "C"
