# Shared include for wolfHSM recipes.
#
# wolfHSM is a hardware security module framework: a client/server protocol
# plus a set of platform "ports" mapping transport, flash, time and lock
# primitives onto a given target.

HOMEPAGE = "https://www.wolfssl.com/products/wolfhsm"
BUGTRACKER = "https://github.com/wolfSSL/wolfHSM/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

# Pinned to the wolfHSM release git tag.
SRC_URI = "git://github.com/wolfSSL/wolfHSM.git;nobranch=1;protocol=https;rev=dd3ff8835cfdac7b9bede42afe52e729a999f3d7"

# Newer releases (styhead+/wrynose) unpack into ${UNPACKDIR} and name the git
# checkout after the recipe; oe-core there rejects S = "${WORKDIR}/git"
# outright. Older releases (through scarthgap) have no UNPACKDIR and unpack
# straight into ${WORKDIR}. Same pattern as the wolfssl/wolftpm/wolfboot
# recipes in this layer.
python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}
