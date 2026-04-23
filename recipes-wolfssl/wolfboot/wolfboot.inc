# Shared include for wolfBoot recipes
#
# Pulls the wolfBoot source tree and the wolfSSL submodule source side-by-side.
# wolfBoot bundles wolfSSL under lib/wolfssl, so we stage wolfSSL there instead
# of fetching it from the wolfBoot submodule pointer (keeps the two SRCREVs
# explicit and greppable).

HOMEPAGE = "https://github.com/wolfssl/wolfBoot"
BUGTRACKER = "https://github.com/wolfssl/wolfBoot/issues"
SECTION = "bootloaders"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

# NOTE: SRCREVs below are pinned to wolfSSL/wolfBoot master and
# wolfSSL/wolfssl master tips at the time of writing. Bump these as
# upstream evolves. Downstream users can override via local.conf:
#   SRCREV_wolfboot:pn-wolfboot = "<sha>"
#   SRCREV_wolfboot:pn-wolfboot-keytools-native = "<sha>"
# to pick up un-merged fixes (e.g. wolfSSL/wolfBoot#750 adds the ZynqMP
# hal_dts_fixup / MMU-cleanup-before-Linux / SDHCI cold-boot retry path
# needed for PetaLinux 2025.2 on ZCU102).
SRC_URI = " \
    git://github.com/dgarske/wolfBoot.git;protocol=https;branch=zynqmp_bb;name=wolfboot;destsuffix=git \
    git://github.com/wolfssl/wolfssl.git;protocol=https;branch=master;name=wolfssl;destsuffix=git/lib/wolfssl \
"
SRCREV_wolfboot ?= "0cecff09ab7ff2aec933bfe94347eed1286be4ac"
SRCREV_wolfssl  ?= "c4c71eece3e6eae7042a16fffdebf9bd80a4f2a1"
SRCREV_FORMAT    = "wolfboot_wolfssl"

S = "${WORKDIR}/git"
