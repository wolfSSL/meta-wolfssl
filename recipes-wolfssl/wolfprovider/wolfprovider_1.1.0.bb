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

# Pass replace-default mode to runtime
do_install:append() {
    install -d ${D}${sysconfdir}/wolfprovider
    if [ "${WOLFPROVIDER_REPLACE_DEFAULT}" = "1" ]; then
        echo "1" > ${D}${sysconfdir}/wolfprovider/replace-default-mode
    else
        echo "0" > ${D}${sysconfdir}/wolfprovider/replace-default-mode
    fi
    
    # Create symlink for unversioned .so
    install -d ${D}${libdir}
    ln -sf libwolfprov.so.0.0.0 ${D}${libdir}/libwolfprov.so
}

CFLAGS += " -I${S}/include -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS += " -I${S}/include  -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS += " -Wl,--build-id=none"
EXTRA_OECONF += " --with-openssl=${STAGING_EXECPREFIXDIR}"

# Keep unversioned .so in the runtime package
FILES_SOLIBSDEV = ""

# Explicitly list what goes to -dev instead (headers, pc)
FILES:${PN}-dev = "${includedir} ${libdir}/pkgconfig/*.pc"

# Ensure the symlink and config are assigned to runtime
FILES:${PN} += "${libdir}/libwolfprov.so ${sysconfdir}/wolfprovider/replace-default-mode"

# Shipping an unversioned .so in runtime: suppress QA warning
INSANE_SKIP:${PN} += "dev-so"