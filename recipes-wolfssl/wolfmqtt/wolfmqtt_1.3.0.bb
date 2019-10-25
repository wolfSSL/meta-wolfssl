SUMMARY = "wolfMQTT Client Library"
DESCRIPTION = "wolfMQTT is a client library implementation of the MQTT \
               protocol, written in ANSI C and targeted for embedded, RTOS, \
               and resource-constrained environments. It has been built from \
               the ground up to be multi-platform, space conscious, and \
               extensible. It includes support for the MQTT v5.0 protocol."
HOMEPAGE = "https://www.wolfssl.com/products/wolfmqtt"
BUGTRACKER = "https://github.com/wolfssl/wolfmqtt/issues"
SECTION = "libs"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2c1c00f9d3ed9e24fa69b932b7e7aff2"

DEPENDS += "wolfssl"

SRC_URI[md5sum] = "9b699c26eb5cccb2e1a1cb1d781eb3c7"
SRC_URI[sha256sum] = "7d1c85dab2838e504b650e0d7e64dc5c5c5b022d65cc5015e5b3c8a2494d29ed"
SRC_URI = "https://www.wolfssl.com/wolfmqtt-${PV}.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools
