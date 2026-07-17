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

SRC_URI = "git://github.com/wolfssl/wolfTPM.git;nobranch=1;protocol=https;rev=1a19f639bc9f0be9825be1042687ff12ad44a40b"

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

# wolfTPM 4.0.0 added a firmware-TPM (fwTPM) server that is enabled by default on
# Linux x86_64/aarch64. Its fwtpm_command.c/fwtpm_crypto.c require AES-CFB
# (wc_AesCfb*/TPM2_AesCfb*), which this layer's wolfSSL is not built with, so the
# fwtpm_server target fails to link. Disable it to keep the pre-4.0.0 scope
# (library + examples). Enable --enable-aescfb in the wolfSSL config instead if the
# fwTPM server is needed.
EXTRA_OECONF = "--with-wolfcrypt=${STAGING_EXECPREFIXDIR} \
                --disable-fwtpm"

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale
export LC_ALL = "C"