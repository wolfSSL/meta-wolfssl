# Shared include for wolfBoot recipes
#
# Pulls the wolfBoot source tree and the wolfSSL submodule source side-by-side.
# wolfBoot bundles wolfSSL under lib/wolfssl, so we stage wolfSSL there instead
# of fetching it from the wolfBoot submodule pointer (keeps the two SRCREVs
# explicit and greppable). Set WOLFBOOT_WOLFSSL_SRC to build against an
# existing wolfSSL source tree instead, see the block below.

HOMEPAGE = "https://github.com/wolfssl/wolfBoot"
BUGTRACKER = "https://github.com/wolfssl/wolfBoot/issues"
SECTION = "bootloaders"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

# --- Optional: build against an existing wolfSSL source tree ----------------
#
# Set WOLFBOOT_WOLFSSL_SRC to the absolute path of a wolfSSL source tree to
# build wolfCrypt from it instead of the pinned copy fetched below. When it is
# set the wolfSSL entry drops out of SRC_URI entirely and nothing is downloaded
# making SRCREV_wolfssl unused.
#
# NOTE: this reuses a source *tree*, not a built library. wolfBoot compiles the
# wolfCrypt sources itself into a -nostdlib bare-metal image; it can never link
# against the target libwolfssl.so that the wolfssl recipe produces.
WOLFBOOT_WOLFSSL_SRC ?= ""

# Private copy of that tree, made by do_stage_external_wolfssl below. The copy
# is not an optimisation: wolfBoot compiles objects *alongside* the wolfCrypt
# sources ($(WOLFBOOT_LIB_WOLFSSL)/wolfcrypt/src/*.o, in both options.mk and
# tools/keytools/Makefile), so building in place would write into the caller's
# tree -- and race with it if it belongs to another recipe. Copying also lets
# WOLFBOOT_WOLFSSL_SRC live somewhere read-only or shared.
WOLFBOOT_WOLFSSL_STAGED_SRC = "${WORKDIR}/wolfssl-external"

# NOTE: SRCREVs below are pinned to wolfSSL/wolfBoot master and
# wolfSSL/wolfssl master tips at the time of writing. Bump these as
# upstream evolves. Downstream users can override via local.conf:
#   SRCREV_wolfboot:pn-wolfboot = "<sha>"
#   SRCREV_wolfboot:pn-wolfboot-keytools-native = "<sha>"
SRC_URI = " \
    git://github.com/wolfssl/wolfBoot.git;protocol=https;branch=master;name=wolfboot;destsuffix=git \
    ${@'' if d.getVar('WOLFBOOT_WOLFSSL_SRC') else 'git://github.com/wolfssl/wolfssl.git;protocol=https;branch=master;name=wolfssl;destsuffix=git/lib/wolfssl'} \
"
SRCREV_wolfboot ?= "9a667f2a7527da2b8e490ae7923665321af2d3ac"
SRCREV_wolfssl  ?= "1d363f3adceba9d1478230ede476a37b0dcdef24"
SRCREV_FORMAT    = "${@'wolfboot' if d.getVar('WOLFBOOT_WOLFSSL_SRC') else 'wolfboot_wolfssl'}"

def wolfboot_wolfssl_src_id(d):
    """Fingerprint the external wolfSSL tree: relative path, size and mtime of
    every file. Fed into the task hashes below so that editing the tree rebuilds
    wolfBoot. BitBake otherwise hashes only the WOLFBOOT_WOLFSSL_SRC *string*,
    and changes to its contents would silently reuse a stale wolfboot.elf.
    Returns '' (and costs nothing) when the feature is not in use."""
    import os
    import hashlib

    src = d.getVar('WOLFBOOT_WOLFSSL_SRC')
    if not src or not os.path.isdir(src):
        return ''

    h = hashlib.sha256()
    for root, dirs, files in os.walk(src):
        # Same pruning as the copy below, so the fingerprint tracks exactly
        # what gets staged.
        dirs[:] = sorted(x for x in dirs if x not in ('.git', '.libs'))
        for name in sorted(files):
            path = os.path.join(root, name)
            try:
                st = os.lstat(path)
            except OSError:
                continue
            entry = '%s %d %d\n' % (os.path.relpath(path, src),
                                    st.st_size, st.st_mtime_ns)
            h.update(entry.encode())
    return h.hexdigest()

WOLFBOOT_WOLFSSL_SRC_ID = "${@wolfboot_wolfssl_src_id(d)}"

python check_wolfboot_wolfssl_src() {
    import os

    src = d.getVar('WOLFBOOT_WOLFSSL_SRC') or ''
    if not src:
        return
    if not os.path.isabs(src):
        bb.fatal("WOLFBOOT_WOLFSSL_SRC='%s' must be an absolute path. wolfBoot's "
                 "Makefile only abspaths WOLFBOOT_LIB_WOLFSSL when the value "
                 "comes from a makefile; the recipe passes it on the make "
                 "command line, which overrides that assignment, so a relative "
                 "path reaches every sub-makefile verbatim and resolves against "
                 "whichever working directory each one runs in." % src)
    if not os.path.isdir(os.path.join(src, 'wolfcrypt', 'src')):
        bb.fatal("WOLFBOOT_WOLFSSL_SRC='%s' does not look like a wolfSSL source "
                 "tree (no wolfcrypt/src directory)." % src)
}

do_stage_external_wolfssl() {
    if [ -z "${WOLFBOOT_WOLFSSL_SRC}" ]; then
        return 0
    fi

    rm -rf "${WOLFBOOT_WOLFSSL_STAGED_SRC}"
    mkdir -p "${WOLFBOOT_WOLFSSL_STAGED_SRC}"

    # Prebuilt objects are excluded so a natively-configured wolfSSL tree
    # (./configure && make) cannot leak host x86 .o/.a files into the cross
    # build: wolfBoot's object paths sit inside this tree, and make would
    # happily reuse an existing .o that is newer than its .c.
    tar -cf - -C "${WOLFBOOT_WOLFSSL_SRC}" \
        --exclude=.git --exclude=.libs \
        --exclude='*.o' --exclude='*.lo' --exclude='*.a' --exclude='*.la' \
        --exclude='*.so' --exclude='*.so.*' \
        . | tar -xf - -C "${WOLFBOOT_WOLFSSL_STAGED_SRC}"

    # Guard against a half-copied tree: the pipeline above reports only the
    # extract side's exit status under a plain POSIX shell.
    if [ ! -f "${WOLFBOOT_WOLFSSL_STAGED_SRC}/wolfcrypt/src/asn.c" ]; then
        bbfatal "Failed to stage WOLFBOOT_WOLFSSL_SRC='${WOLFBOOT_WOLFSSL_SRC}':" \
                "wolfcrypt/src/asn.c is missing from the copy at" \
                "${WOLFBOOT_WOLFSSL_STAGED_SRC}."
    fi

    chmod -R u+w "${WOLFBOOT_WOLFSSL_STAGED_SRC}"
}
do_stage_external_wolfssl[prefuncs] += "check_wolfboot_wolfssl_src"
do_stage_external_wolfssl[vardeps] += "WOLFBOOT_WOLFSSL_SRC_ID"
do_compile[vardeps] += "WOLFBOOT_WOLFSSL_SRC_ID"
addtask stage_external_wolfssl after do_unpack before do_compile

python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}
