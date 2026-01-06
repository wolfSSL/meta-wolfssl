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

SRC_URI = "git://github.com/wolfssl/wolfProvider.git;nobranch=1;protocol=https;rev=5140cc3a1fce3dad0cd8a8e20fc402feb635b8be"

DEPENDS += " virtual/wolfssl \
            openssl \
            "

inherit autotools pkgconfig wolfssl-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl openssl')
    wolfssl_varSet(d, 'FILES', '${PN}-dev', '${includedir} ${libdir}/pkgconfig/*.pc')
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${libdir}/libwolfprov.so ${libdir}/ssl-3/modules/libwolfprov.so ${libdir}/ossl-modules/libwolfprov.so')
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${sysconfdir}/ssl/openssl.cnf.d/wolfprovider*.conf')
    wolfssl_varAppend(d, 'INSANE_SKIP', '${PN}', ' dev-so')
}

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

    # Create symlink in the ossl-modules directory
    install -d ${D}${libdir}/ossl-modules
    if [ ! -e ${D}${libdir}/ossl-modules/libwolfprov.so ]; then
        ln -sf ${libdir}/libwolfprov.so.0.0.0 ${D}${libdir}/ossl-modules/libwolfprov.so
    fi

    # Install config files to openssl.cnf.d/ (following Debian convention)
    install -d ${D}${sysconfdir}/ssl/openssl.cnf.d
    install -m 0644 ${S}/provider.conf ${D}${sysconfdir}/ssl/openssl.cnf.d/wolfprovider.conf
    install -m 0644 ${S}/provider-fips.conf ${D}${sysconfdir}/ssl/openssl.cnf.d/wolfprovider-fips.conf
}

do_install[postfuncs] += "install_provider_module"

CFLAGS += " -I${S}/include"
CXXFLAGS += " -I${S}/include"
CPPFLAGS += " -I${S}/include"

EXTRA_OECONF += " --with-openssl=${STAGING_EXECPREFIXDIR}"

# Keep unversioned .so in the runtime package
FILES_SOLIBSDEV = ""

