SUMMARY = "wolfPKCS11 PKCS#11 Library"
DESCRIPTION = "wolfPKCS11 is a PKCS#11 library that implements cryptographic algorithms using wolfCrypt."
HOMEPAGE = "https://www.wolfssl.com/products/wolfpkcs11"
BUGTRACKER = "https://github.com/wolfSSL/wolfPKCS11/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://gpl-3.0.txt;md5=d32239bcb673463ab874e80d47fae504"

DEPENDS += "virtual/wolfssl"

SRC_URI = "git://github.com/wolfSSL/wolfPKCS11.git;nobranch=1;protocol=https;rev=6b76537e4cc5bea0358b7059fda26d1872584be4"

S = "${WORKDIR}/git"

inherit autotools pkgconfig wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')
}

export CFLAGS += ' -I${STAGING_INCDIR} -L${STAGING_LIBDIR}'

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale
export LC_ALL = "C"