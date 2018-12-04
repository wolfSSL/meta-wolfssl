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

SRC_URI[md5sum] = "e1552d5d99f948d11e0ad6680001228c"
SRC_URI[sha256sum] = "ff2179bbcdc77e0b446c765e71294a208ab71949cd74fb46986e20644e3e7e5f"
SRC_URI = "https://www.wolfssl.com/wolfssh-1.3.0.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools

