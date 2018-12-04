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

SRC_URI[md5sum] = "122186e722d960954c93f8ed6a63dd1e"
SRC_URI[sha256sum] = "5bb3261af28c48c40127393954100938c085ee4a30adc34acb4418364127c8dd"
SRC_URI = "https://www.wolfssl.com/wolftpm-1.3.0.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools

