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

SRC_URI[md5sum] = "8767030c8a046c126899f395c8973966"
SRC_URI[sha256sum] = "d48c936b39cd29d6d2b4996cf37449b6a26e769072f485e8563d11fa5f42fb60"
SRC_URI = "https://www.wolfssl.com/wolftpm-1.5.0.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools

