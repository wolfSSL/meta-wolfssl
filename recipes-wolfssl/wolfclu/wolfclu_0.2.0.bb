SUMMARY = "wolfCLU is a command line utility with wolfSSL"
DESCRIPTION = "wolfCLU is a lightweight command line utility written in C and \
               optimized for embedded and RTOS environments."
HOMEPAGE = "https://www.wolfssl.com/products/wolfclu"
BUGTRACKER = "https://github.com/wolfssl/wolfclu/issues"
SECTION = "bin"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"

PROVIDES += "wolfclu"

DEPENDS += "virtual/wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfclu.git;nobranch=1;protocol=https;rev=ceefc9953aec4ccce6f921df67903101de28a3a0"

python () {
    if d.getVar('WOLFCLU_TYPE', False):
        return
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}

inherit autotools pkgconfig wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varSet(d, 'RPROVIDES', '${PN}', 'wolfclu')
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
}

EXTRA_OECONF = "--with-wolfssl=${STAGING_EXECPREFIXDIR}"

BBCLASSEXTEND += "native nativesdk"

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale
export LC_ALL = "C"


