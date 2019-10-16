SUMMARY = "wolfSSL Lightweight Embedded SSL/TLS Library"
DESCRIPTION = "wolfSSL is a lightweight SSL/TLS library written in C and \
               optimized for embedded and RTOS environments. It can be up \
               to 20 times smaller than OpenSSL while still supporting \
               a full TLS client and server, up to TLS 1.3"
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "libs"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PROVIDES += "cyassl"
RPROVIDES_${PN} = "cyassl"

SRC_URI[md5sum] = "c7c06a9e2f2da3f18460f9be4fed78ec"
SRC_URI[sha256sum] = "c64c78f10045d02e9e345ed702c3eb9965caefa9bb152d4e11c68ff91a1b6219"
SRC_URI = "https://www.wolfssl.com/wolfssl-${PV}.zip"

inherit autotools

BBCLASSEXTEND += "native nativesdk"
