SUMMARY = "wolfProvider is a Provider designed for Openssl 3.X.X"
DESCRIPTION = "wolfProvider is a crypto backend interface for use as an OpenSSL Provider"
HOMEPAGE = "https://github.com/wolfSSL/wolfProvider"
BUGTRACKER = "https://github.com/wolfSSL/wolfProvider/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"
DEPENDS += "util-linux-native"

PROVIDES += "wolfprovider"
RPROVIDES_${PN} = "wolfprovider"

SRC_URI = "git://github.com/wolfssl/wolfProvider.git;nobranch=1;protocol=https;rev=a8223f5707a9c4460d89f4cbe7b3a129c4e85c6a"

DEPENDS += " virtual/wolfssl \
            openssl \
            "

RDEPENDS:${PN} += "wolfssl openssl"

inherit autotools pkgconfig wolfssl-helper

S = "${WORKDIR}/git"

# Install provider module symlink (autotools already creates libwolfprov.so symlinks)
install_provider_module() {
    # Ensure target library exists
    if [ ! -f ${D}${libdir}/libwolfprov.so.0.0.0 ]; then
        echo "libwolfprov.so.0.0.0 not found in ${D}${libdir}/" >&2
        exit 1
    fi
    
    # Create the OpenSSL module directory symlink
    install -d ${D}${libdir}/ssl-3/modules
    if [ ! -e ${D}${libdir}/ssl-3/modules/libwolfprov.so ]; then
        ln -sf ${libdir}/libwolfprov.so.0.0.0 ${D}${libdir}/ssl-3/modules/libwolfprov.so
    fi
}

do_install[postfuncs] += "install_provider_module"

CFLAGS:append = " -I${S}/include"
CXXFLAGS:append = " -I${S}/include"
CPPFLAGS:append = " -I${S}/include"

EXTRA_OECONF += " --with-openssl=${STAGING_EXECPREFIXDIR}"

# Keep unversioned .so in the runtime package
FILES_SOLIBSDEV = ""

# Explicitly list what goes to -dev instead (headers, pc)
FILES:${PN}-dev = "${includedir} ${libdir}/pkgconfig/*.pc"

# Ensure the symlink is assigned to runtime
FILES:${PN} += "${libdir}/libwolfprov.so ${libdir}/ssl-3/modules/libwolfprov.so"

# Shipping an unversioned .so in runtime: suppress QA warning
INSANE_SKIP:${PN} += "dev-so"

