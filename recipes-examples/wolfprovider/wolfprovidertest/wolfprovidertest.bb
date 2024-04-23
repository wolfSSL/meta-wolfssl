SUMMARY = "Test program for custom OpenSSL provider 'libwolfprov'"
DESCRIPTION = "Compiles and runs a test program to verify the functionality of the custom OpenSSL provider libwolfprov."
HOMEPAGE = "https://www.wolfssl.com"
SECTION = "examples"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

DEPENDS = "openssl pkgconfig-native wolfssl wolfprovider"
PROVIDES += "wolfprovidertest"
RPROVIDES_${PN} = "wolfprovidertest"


SRC_URI = "file://wolfprovidertest.c \
           file://wolfproviderenv.sh \
          "

S = "${WORKDIR}"

inherit pkgconfig

do_compile() {
    ${CC} ${WORKDIR}/wolfprovidertest.c -o wolfprovidertest \
        ${CFLAGS} ${LDFLAGS} $(pkg-config --cflags --libs openssl) -ldl -lwolfssl -lwolfprov
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfprovidertest ${D}${bindir}/wolfprovidertest
    install -m 0755 ${WORKDIR}/wolfproviderenv.sh ${D}${bindir}/wolfproviderenv
}

FILES_${PN} += "${bindir}/wolfprovidertest \
                ${bindir}/wolfproviderenv \
               "

# Dynamic RDEPENDS adjustment for bash
python() {
    distro_version = d.getVar('DISTRO_VERSION', True)
    pn = d.getVar('PN', True)

    rdepends_var_name = 'RDEPENDS_' + pn if (distro_version.startswith('2.') or distro_version.startswith('3.')) else 'RDEPENDS:' + pn

    current_rdepends = d.getVar(rdepends_var_name, True) or ""
    new_rdepends = current_rdepends + " bash"
    d.setVar(rdepends_var_name, new_rdepends)
}
