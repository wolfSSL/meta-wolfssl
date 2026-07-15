SUMMARY = "wolfSSH Lightweight SSH Library"
DESCRIPTION = "wolfSSH is a lightweight SSHv2 library written in ANSI C and \
               targeted for embedded, RTOS, and resource-constrained \
               environments. wolfSSH supports client and server sides, and \
               includes support for SCP and SFTP."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssh"
BUGTRACKER = "https://github.com/wolfssl/wolfssh/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSING;md5=2c2d0ee3db6ceba278dd43212ed03733"

DEPENDS += "virtual/wolfssl"

# wolfSSL 5.9.2 dropped wolfssl/wolfcrypt/mlkem.h (only wc_mlkem.h remains), which
# breaks the unconditional include in wolfSSH 1.5.0. Pull the upstream fix directly
# from its commit at build time instead of vendoring a local patch copy.
SRC_URI = "git://github.com/wolfssl/wolfssh.git;nobranch=1;protocol=https;rev=8643d7be841184f766374e3b0ed68ced6391543c \
           https://github.com/wolfssl/wolfssh/commit/73b10ad26d51309852e87e74cb4e6d27f2faf33b.patch;name=mlkem-fix;apply=yes"
SRC_URI[mlkem-fix.sha256sum] = "a0f88ff9ad075e670d9ecc7d81a49b98bc881c37744aaf270d66313ec111a9cf"

# The mlkem fix is fetched directly from its upstream commit, so the patch file has
# no "Upstream-Status:" header. Newer OE (scarthgap/wrynose) runs the patch-status QA
# as a fatal ERROR (via CHECKLAYER_REQUIRED_TESTS) and greps every applied patch for
# that header, with no way to attach it to a URL-fetched patch. patch-status is gated
# by ERROR_QA (not INSANE_SKIP), so drop it via the version-agnostic helper. No-op on
# older releases where patch-status isn't present.
python () {
    wolfssl_varRemoveNonOverride(d, 'ERROR_QA', 'patch-status')
}

python () {
    if d.getVar('WOLFSSH_TYPE', False):
        return
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}

inherit autotools pkgconfig wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
}

EXTRA_OECONF = "--with-wolfssl=${STAGING_EXECPREFIXDIR}"

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale
export LC_ALL = "C"