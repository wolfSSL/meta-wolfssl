SUMMARY = "wolfCLU is a command line utility with wolfSSL"
DESCRIPTION = "wolfCLU is a lightweight command line utility written in C and \
               optimized for embedded and RTOS environments."
HOMEPAGE = "https://www.wolfssl.com/products/wolfclu"
BUGTRACKER = "https://github.com/wolfssl/wolfclu/issues"
SECTION = "bin"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PROVIDES += "wolfclu"
RPROVIDES_${PN} = "wolfclu"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfclu.git;nobranch=1;protocol=https;tag=v${PV}-stable;"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

EXTRA_OECONF = "--with-wolfssl=${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"

BBCLASSEXTEND += "native nativesdk"

do_configure_prepend() {
    (cd ${S}; ./autogen.sh; cd -)
}

