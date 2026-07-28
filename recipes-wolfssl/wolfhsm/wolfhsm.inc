# Shared include for wolfHSM recipes.
#
# wolfHSM is a hardware security module framework: a client/server protocol
# plus a set of platform "ports" mapping transport, flash, time and lock
# primitives onto a given target.

HOMEPAGE = "https://www.wolfssl.com/products/wolfhsm"
BUGTRACKER = "https://github.com/wolfSSL/wolfHSM/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

# NOTE: pinned to a wolfSSL/wolfHSM main tip at the time of writing. Bump as
# upstream evolves. Downstream users can override via local.conf:
#   SRCREV:pn-wolfhsm = "<sha>"
SRC_URI = "git://github.com/wolfSSL/wolfHSM.git;protocol=https;branch=main"
SRCREV ?= "4aeecb2c35686bd4daeb40b3537500d15a93aff9"

S = "${WORKDIR}/git"
