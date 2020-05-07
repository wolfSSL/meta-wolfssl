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

SRC_URI[md5sum] = "c61cf4de64d005671343ba0de321f57c"
SRC_URI[sha256sum] = "5ed0febea1ae93bca413b933677412c57b07ec40fe9a33fbfc5fc4b04f342dba"
SRC_URI = "https://www.wolfssl.com/wolftpm-${PV}.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools
