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

SRC_URI[md5sum] = "e61610187eb20d45c9e31f5c5a8f9c91"
SRC_URI[sha256sum] = "b98ce6cc3f1a9fb12c8e9cbc29ba0c40e740272cfce9e138c9a73b227f88bc70"
SRC_URI = "https://www.wolfssl.com/wolfssh-${PV}.zip"

inherit autotools
