SUMMARY = "wolfTPM Portable TPM 2.0 Library"
DESCRIPTION = "wolfTPM is a portable TPM 2.0 project, designed for embedded \
               use. It is highly portable, due to having been written in \
               native C, having a single IO callback for hardware interface, \
               no external dependencies, and its compact code with low \
               resource use."
HOMEPAGE = "https://www.wolfssl.com/products/wolftpm"
BUGTRACKER = "https://github.com/wolfssl/wolftpm/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d32239bcb673463ab874e80d47fae504"

DEPENDS += "virtual/wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfTPM.git;nobranch=1;protocol=https;rev=09a426befc54e4afdf3eb2844f771b5d17656de7"

python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}

inherit autotools pkgconfig wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
}

# wolfTPM 4.x added a firmware-TPM (fwTPM) server that is enabled by default on
# Linux x86_64/aarch64. Its fwtpm_command.c/fwtpm_crypto.c require AES-CFB
# (wc_AesCfb*/TPM2_AesCfb*), which this layer's wolfSSL is not built with, so the
# fwtpm_server target fails to link. Disable it to keep the pre-4.0.0 scope
# (library + examples). Enable --enable-aescfb in the wolfSSL config instead if the
# fwTPM server is needed.
EXTRA_OECONF = "--with-wolfcrypt=${STAGING_EXECPREFIXDIR} \
                --disable-fwtpm"

# wolfTPM's TPM2_AesCfb* code uses the classic macro name AES_BLOCK_SIZE. When
# wolfSSL is built with OpenSSL coexistence (OPENSSL_COEXIST), aes.h only exposes
# WC_AES_BLOCK_SIZE and deliberately omits AES_BLOCK_SIZE, so the build fails with
# "'AES_BLOCK_SIZE' undeclared". Map the classic name to the WC_ name on the command
# line (equivalent to upstream wolfTPM PR #552). In non-coexist builds aes.h defines
# AES_BLOCK_SIZE to the same token, so this is a benign identical redefinition.
export CFLAGS += ' -DAES_BLOCK_SIZE=WC_AES_BLOCK_SIZE'

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale
export LC_ALL = "C"