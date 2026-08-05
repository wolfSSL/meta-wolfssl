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
WOLFBOOT_REPO ?= "git://github.com/wolfssl/wolfBoot.git"
WOLFBOOT_BRANCH ?= "master"
WOLFBOOT_PROTOCOL ?= "https"
WOLFBOOT_WOLFSSL_REPO ?= "git://github.com/wolfssl/wolfssl.git"
WOLFBOOT_WOLFSSL_BRANCH ?= "master"
WOLFBOOT_WOLFSSL_PROTOCOL ?= "https"
WOLFBOOT_WOLFSSL_URI = "${WOLFBOOT_WOLFSSL_REPO};protocol=${WOLFBOOT_WOLFSSL_PROTOCOL};branch=${WOLFBOOT_WOLFSSL_BRANCH};name=wolfssl;destsuffix=git/lib/wolfssl"

SRC_URI = " \
    ${WOLFBOOT_REPO};protocol=${WOLFBOOT_PROTOCOL};branch=${WOLFBOOT_BRANCH};name=wolfboot;destsuffix=git \
    ${@'' if d.getVar('WOLFBOOT_WOLFSSL_SRC') else d.getVar('WOLFBOOT_WOLFSSL_URI')} \
"
SRCREV_wolfboot ?= "9a667f2a7527da2b8e490ae7923665321af2d3ac"
SRCREV_wolfssl  ?= "1d363f3adceba9d1478230ede476a37b0dcdef24"
SRCREV_FORMAT    = "${@'wolfboot' if d.getVar('WOLFBOOT_WOLFSSL_SRC') else 'wolfboot_wolfssl'}"

# Directories and file patterns the staging copy below leaves out. Kept in one
# place because the fingerprint must prune exactly what the copy prunes: a file
# that is skipped by the copy but hashed by the fingerprint (a stale .o from a
# native ./configure && make, say) would rebuild wolfBoot over a file that never
# reaches the build.
WOLFBOOT_WOLFSSL_EXCLUDE_DIRS = ".git .libs"
WOLFBOOT_WOLFSSL_EXCLUDE_GLOBS = "*.o *.lo *.a *.la *.so *.so.*"

def wolfboot_wolfssl_src_id(d):
    """Fingerprint the external wolfSSL tree: relative path, size and mtime of
    every file that do_stage_external_wolfssl would copy. Fed into the task
    hashes below so that editing the tree rebuilds wolfBoot. BitBake otherwise
    hashes only the WOLFBOOT_WOLFSSL_SRC *string*, and changes to its contents
    would silently reuse a stale wolfboot.elf. Returns '' (and costs nothing)
    when the feature is not in use."""
    import os
    import fnmatch
    import hashlib

    src = d.getVar('WOLFBOOT_WOLFSSL_SRC')
    if not src or not os.path.isdir(src):
        return ''

    skip_dirs = (d.getVar('WOLFBOOT_WOLFSSL_EXCLUDE_DIRS') or '').split()
    skip_globs = (d.getVar('WOLFBOOT_WOLFSSL_EXCLUDE_GLOBS') or '').split()

    h = hashlib.sha256()
    for root, dirs, files in os.walk(src):
        dirs[:] = sorted(x for x in dirs if x not in skip_dirs)
        for name in sorted(files):
            if any(fnmatch.fnmatch(name, pat) for pat in skip_globs):
                continue
            path = os.path.join(root, name)
            try:
                st = os.lstat(path)
            except OSError:
                continue
            entry = '%s %d %d\n' % (os.path.relpath(path, src),
                                    st.st_size, st.st_mtime_ns)
            h.update(entry.encode())
    return h.hexdigest()

# The fingerprint has to be a plain string in the datastore, not a deferred
# ${@...} expansion: vardeps hashes a variable's *unexpanded* value, so
# "${@wolfboot_wolfssl_src_id(d)}" is a constant as far as the task hashes are
# concerned and editing the tree would never rebuild. Setting the value here
# puts the digest itself into the hash.
python () {
    if d.getVar('WOLFBOOT_WOLFSSL_SRC'):
        d.setVar('WOLFBOOT_WOLFSSL_SRC_ID', wolfboot_wolfssl_src_id(d))
}

# ...and the recipe must be re-parsed every time for that to be re-evaluated;
# a cached parse would keep serving the digest from whenever the tree was last
# looked at. Only when the feature is in use, so ordinary builds keep their
# parse cache.
BB_DONT_CACHE = "${@'1' if d.getVar('WOLFBOOT_WOLFSSL_SRC') else ''}"

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
    #
    # Two steps through an intermediate archive rather than tar|tar: a plain
    # POSIX shell reports only the extract side of a pipeline, so a create
    # side that died halfway (read error, vanished file) would go unnoticed
    # and leave a silently incomplete tree. Each tar is checked on its own so
    # the failure names which half broke; letting 'set -e' abort the task here
    # would report a bare ExecutionError and leave the intermediate archive
    # (an entire wolfSSL tree's worth of it) behind in ${WORKDIR}.
    #
    # The exclusions come from the shared lists above so they cannot drift
    # from what the fingerprint hashes. 'set -f' keeps the shell from
    # expanding the *.o-style patterns against the current directory while
    # they are being assembled into the argument list.
    set -f
    tar_excludes=""
    for pat in ${WOLFBOOT_WOLFSSL_EXCLUDE_DIRS} ${WOLFBOOT_WOLFSSL_EXCLUDE_GLOBS}; do
        tar_excludes="$tar_excludes --exclude=$pat"
    done

    rm -f "${WOLFBOOT_WOLFSSL_STAGED_SRC}.tar"
    if ! tar -cf "${WOLFBOOT_WOLFSSL_STAGED_SRC}.tar" \
            -C "${WOLFBOOT_WOLFSSL_SRC}" $tar_excludes . ; then
        rm -f "${WOLFBOOT_WOLFSSL_STAGED_SRC}.tar"
        set +f
        bbfatal "Failed to archive WOLFBOOT_WOLFSSL_SRC='${WOLFBOOT_WOLFSSL_SRC}'." \
                "The tree may be unreadable or changing underneath the build."
    fi
    if ! tar -xf "${WOLFBOOT_WOLFSSL_STAGED_SRC}.tar" \
            -C "${WOLFBOOT_WOLFSSL_STAGED_SRC}" ; then
        rm -f "${WOLFBOOT_WOLFSSL_STAGED_SRC}.tar"
        set +f
        bbfatal "Failed to unpack the staging copy of" \
                "WOLFBOOT_WOLFSSL_SRC='${WOLFBOOT_WOLFSSL_SRC}' into" \
                "${WOLFBOOT_WOLFSSL_STAGED_SRC}. Out of space in ${WORKDIR}?"
    fi
    set +f
    rm -f "${WOLFBOOT_WOLFSSL_STAGED_SRC}.tar"

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
