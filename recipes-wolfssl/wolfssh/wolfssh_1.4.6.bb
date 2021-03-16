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

SRC_URI[md5sum] = "7217789cdf50d02bd7ebac07396dfed2"
SRC_URI[sha256sum] = "db6c11e8fc99ec2c5192e95bda79e75a9818b31bbc456c7b8cce11c4ed9455c3"
SRC_URI = "https://www.wolfssl.com/wolfssh-${PV}.zip"

inherit autotools
