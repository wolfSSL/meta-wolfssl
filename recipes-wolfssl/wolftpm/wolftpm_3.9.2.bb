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
RDEPENDS:${PN} += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfTPM.git;nobranch=1;protocol=https;rev=75938ca2b0810aba6ed21c5184e7a45d28003522"

S = "${WORKDIR}/git"

inherit autotools pkgconfig wolfssl-helper

EXTRA_OECONF = "--with-wolfcrypt=${STAGING_EXECPREFIXDIR}"

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale                                                      
export LC_ALL = "C"