SUMMARY = "wolfSSH Lightweight SSH Library"
DESCRIPTION = "wolfSSH is a lightweight SSHv2 library written in ANSI C and \
               targeted for embedded, RTOS, and resource-constrained \
               environments. wolfSSH supports client and server sides, and \
               includes support for SCP and SFTP."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssh"
BUGTRACKER = "https://github.com/wolfssl/wolfssh/issues"
SECTION = "libs"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://LICENSING;md5=2c2d0ee3db6ceba278dd43212ed03733"

DEPENDS += "wolfssl"

SRC_URI[md5sum] = "beb32aabc3cbe1efdd90b72fab2ed114"
SRC_URI[sha256sum] = "62bdec345828e3f3b718c1e70208ba72c9e8e39769357a0a13e67ceee40845c3"
SRC_URI = "https://www.wolfssl.com/wolfssh-${PV}.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools
