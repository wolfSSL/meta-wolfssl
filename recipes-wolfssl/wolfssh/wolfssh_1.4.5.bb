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

SRC_URI[md5sum] = "d7ad6b88de80bfff171bcf069987fa93"
SRC_URI[sha256sum] = "3e9ecb4aef9af54edc1674e54ebc64950aa77b8b4c92136486c411eabec94262"
SRC_URI = "https://www.wolfssl.com/wolfssh-${PV}.zip"

inherit autotools
