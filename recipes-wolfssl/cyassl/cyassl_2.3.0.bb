SUMMARY = "CyaSSL Embedded SSL Library"
DESCRIPTION = "CyaSSL is a lightweight SSL library written in C and \
               optimized for embedded and RTOS environments. It can be \
               Up to 20 times smaller than OpenSSL while still supporting \
               a full TLS 1.2 client and server."
HOMEPAGE = "http://www.yassl.com/yaSSL/Products-cyassl.html"
BUGTRACKER = "http://github.com/cyassl/cyassl/issues"
SECTION = "libs/network"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=94d55d512a9ba36caa9b7df079bae19f"

PR = "r0"

SRC_URI = "http://www.yassl.com/cyassl-${PV}.zip"

SRC_URI[md5sum] = "e73b50c95eae06a2fb4a7eb0183b21ab"
SRC_URI[sha256sum] = "b597f1c55d3bc4556d9c37e98ca56da2a529e111164d97c650fb097ef0a0d461"

inherit autotools siteinfo

# Detect and build with correct endianness
CFLAGS += "${@base_conditional('SITEINFO_ENDIANNESS', 'le', '', '-DBIG_ENDIAN_ORDER', d)}"

