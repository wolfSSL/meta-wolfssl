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

SRC_URI[md5sum] = "ad393239c7910de2d80d11242afb8fa8"
SRC_URI[sha256sum] = "a67f374280393a36dae6a4cf585cde26a37ca9170dc69d6c861f84730292488c"
SRC_URI = "https://www.wolfssl.com/wolfmqtt-${PV}.zip \
           file://0001-fix-have-wolfssl-m4-rule.patch"

inherit autotools
