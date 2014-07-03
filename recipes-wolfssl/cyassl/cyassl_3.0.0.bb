SUMMARY = "CyaSSL Embedded SSL Library"
DESCRIPTION = "CyaSSL is a lightweight SSL library written in C and \
               optimized for embedded and RTOS environments. It can be \
               Up to 20 times smaller than OpenSSL while still supporting \
               a full TLS 1.2 client and server."
HOMEPAGE = "http://www.yassl.com/yaSSL/Products-cyassl.html"
BUGTRACKER = "http://github.com/cyassl/cyassl/issues"
SECTION = "libs/network"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PR = "r1"

SRC_URI = "http://www.yassl.com/cyassl-${PV}.zip"


SRC_URI[md5sum] = "d29a841796180890bae47b159bb76d38"
SRC_URI[sha256sum] = "03825863aef91c5fccb68f1a23d1f2d404254f51fa5413b72fd4a022bece1eed"

S = "${WORKDIR}/${PN}-${PV}"

inherit autotools

# Detect and build with correct endianness
# CFLAGS += "${@base_conditional('SITEINFO_ENDIANNESS', 'le', '', '-DBIG_ENDIAN_ORDER', d)}"

