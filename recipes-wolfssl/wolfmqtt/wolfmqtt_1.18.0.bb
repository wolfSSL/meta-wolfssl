SUMMARY = "wolfMQTT Client Library"
DESCRIPTION = "wolfMQTT is a client library implementation of the MQTT \
               protocol, written in ANSI C and targeted for embedded, RTOS, \
               and resource-constrained environments. It has been built from \
               the ground up to be multi-platform, space conscious, and \
               extensible. It includes support for the MQTT v5.0 protocol."
HOMEPAGE = "https://www.wolfssl.com/products/wolfmqtt"
BUGTRACKER = "https://github.com/wolfssl/wolfmqtt/issues"
SECTION = "libs"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2c1c00f9d3ed9e24fa69b932b7e7aff2"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfMQTT.git;nobranch=1;protocol=https;rev=91b01f4be412fff883374168aa4da2bd00d2968c"


S = "${WORKDIR}/git"

inherit autotools pkgconfig

EXTRA_OECONF = "--with-libwolfssl-prefix=${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"

do_configure:prepend() {
    (cd ${S}; ./autogen.sh; cd -)
}
