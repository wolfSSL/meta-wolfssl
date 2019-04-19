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

SRC_URI[md5sum] = "628cd94a361386c4df945b9f48c892a3"
SRC_URI[sha256sum] = "db795f40423bafefe6ff5905e2459a4195f6b72757d10764d55e5e4c596d1a5b"
SRC_URI = "https://www.wolfssl.com/wolfmqtt-1.2.0.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools

