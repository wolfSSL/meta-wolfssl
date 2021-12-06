SUMMARY = "wolfTPM Portable TPM 2.0 Library"
DESCRIPTION = "wolfTPM is a portable TPM 2.0 project, designed for embedded \
               use. It is highly portable, due to having been written in \
               native C, having a single IO callback for hardware interface, \
               no external dependencies, and its compact code with low \
               resource use."
HOMEPAGE = "https://www.wolfssl.com/products/wolftpm"
BUGTRACKER = "https://github.com/wolfssl/wolftpm/issues"
SECTION = "libs"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfTPM.git;tag=v${PV}"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

EXTRA_OECONF = "--with-wolfcrypt=${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"

do_configure_prepend() {
    (cd ${S}; ./autogen.sh; cd -)
}
