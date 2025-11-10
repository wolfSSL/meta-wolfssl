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

DEPENDS += "virtual/wolfssl"
RDEPENDS:${PN} += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfMQTT.git;nobranch=1;protocol=https;rev=320ed37633f896cf2485c9c5f8bed3400ae8b4d5"


S = "${WORKDIR}/git"

inherit autotools pkgconfig wolfssl-helper

EXTRA_OECONF = "--with-libwolfssl-prefix=${STAGING_EXECPREFIXDIR}"

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale                                                      
export LC_ALL = "C"