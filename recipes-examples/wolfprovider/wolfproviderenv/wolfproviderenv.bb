SUMMARY = "Test suite for wolfProvider OpenSSL provider"
DESCRIPTION = "Enviroment setup for wolfProvider OpenSSL provider"
HOMEPAGE = "https://www.wolfssl.com"
SECTION = "examples"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

DEPENDS = "openssl pkgconfig-native virtual/wolfssl wolfprovider"
PROVIDES += "wolfproviderenv"

inherit pkgconfig wolfssl-compatibility

python __anonymous() {
    wolfssl_varSet(d, 'RPROVIDES', '${PN}', 'wolfproviderenv')
}

SRC_URI = "file://wolfproviderenv.c \
           file://wolfproviderenv.sh \
           https://raw.githubusercontent.com/wolfSSL/wolfProvider/master/provider.conf;name=provider_conf \
           https://raw.githubusercontent.com/wolfSSL/wolfProvider/master/provider-fips.conf;name=provider_fips_conf \
          "

# SHA256 checksums for the config files
SRC_URI[provider_conf.sha256sum] = "3ad9e7cf5aefb9d36b9482232365094f42390f3ef03778fa84c3efb39d48e4c2"
SRC_URI[provider_fips_conf.sha256sum] = "0b2174ab296aefa9a3f1fe40ccf0b988b25d09188ae5abad27fb60923754e98f"

S = "${WORKDIR}"

inherit pkgconfig

do_compile() {
    ${CC} ${WORKDIR}/wolfproviderenv.c -o wolfproviderverify \
        ${CFLAGS} ${LDFLAGS} $(pkg-config --cflags --libs openssl) -ldl -lwolfssl -lwolfprov
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfproviderverify ${D}${bindir}/wolfproviderverify
    install -m 0755 ${WORKDIR}/wolfproviderenv.sh ${D}${bindir}/wolfproviderenv
}

python __anonymous() {
    wolfssl_varSet(d, 'FILES', '${PN}', '${bindir}/wolfproviderverify ${bindir}/wolfproviderenv')
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' bash')
}
