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
PROVIDES += "wolfssl"
RPROVIDES_${PN} = "wolfssl"

SRC_URI[md5sum] = "b0f9dbc7a9e322762d5d36384a9cecc6"
SRC_URI[sha256sum] = "6d9cb110947efebd637f5d480bf810c30e915041b1eb8671e3c487d37d14047a"
SRC_URI = "https://www.wolfssl.com/wolfssl-${PV}.zip"

inherit autotools

BBCLASSEXTEND += "native nativesdk"
