SUMMARY = "wolfCLU is a command line utility with wolfSSL"
DESCRIPTION = "wolfCLU is a lightweight command line utility written in C and \
               optimized for embedded and RTOS environments."
HOMEPAGE = "https://www.wolfssl.com/products/wolfclu"
BUGTRACKER = "https://github.com/wolfssl/wolfclu/issues"
SECTION = "bin"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PROVIDES += "wolfclu"
RPROVIDES_${PN} = "wolfclu"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfclu.git;nobranch=1;protocol=https;rev=c862879aa92bba201b42ea87f5008f53febf4be3"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

EXTRA_OECONF = "--with-wolfssl=${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"

BBCLASSEXTEND += "native nativesdk"

do_configure:prepend() {
    (cd ${S}; ./autogen.sh; cd -)
}

# Add reproducible build flags
CFLAGS:append = " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS:append = " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS:append = " -Wl,--build-id=none"

# Ensure consistent locale
export LC_ALL = "C"


