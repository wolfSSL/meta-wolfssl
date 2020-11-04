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

SRC_URI[md5sum] = "a16e4a841d879c13e30d5f1c9a7dafc9"
SRC_URI[sha256sum] = "6440b96a558e4ac9ca138f05c41b21d2cea988ae2b4a8699140e8e9adf0c477f"
SRC_URI = "https://www.wolfssl.com/wolftpm-${PV}.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools
