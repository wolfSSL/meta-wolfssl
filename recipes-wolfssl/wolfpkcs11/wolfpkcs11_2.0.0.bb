SUMMARY = "wolfPKCS11 PKCS#11 Library"
DESCRIPTION = "wolfPKCS11 is a PKCS#11 library that implements cryptographic algorithms using wolfCrypt."
HOMEPAGE = "https://www.wolfssl.com/products/wolfpkcs11"
BUGTRACKER = "https://github.com/wolfSSL/wolfPKCS11/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://gpl-3.0.txt;md5=d32239bcb673463ab874e80d47fae504"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfSSL/wolfPKCS11.git;nobranch=1;protocol=https;rev=6b76537e4cc5bea0358b7059fda26d1872584be4"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

export CFLAGS += ' -I${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr/include -L${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr/lib'

python() {
    distro_version = d.getVar('DISTRO_VERSION', True)
    autogen_command = 'cd ${S}; ./autogen.sh'
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        # For Dunfell and earlier
        d.appendVar('do_configure_prepend', autogen_command)
    else:
        # For Kirkstone and later
        d.appendVar('do_configure:prepend', autogen_command)
}

# Add reproducible build flags
export CFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export CXXFLAGS += ' -g0 -O2 -ffile-prefix-map=${WORKDIR}=.'
export LDFLAGS += ' -Wl,--build-id=none'

# Ensure consistent locale
export LC_ALL = "C"