SUMMARY = "Test program for custom OpenSSL engine "
DESCRIPTION = "Compiles and runs a test program to verify the functionality of the custom OpenSSL engine."
HOMEPAGE = "https://www.wolfssl.com"
SECTION = "examples"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

DEPENDS = "openssl pkgconfig-native virtual/wolfssl wolfengine"
PROVIDES += "wolfenginetest"

inherit pkgconfig wolfssl-compatibility

WOLFENGINE_TEST = "${bindir}/wolfenginetest"
WOLFENGINE_ENV = "${bindir}/wolfenginetest"

SRC_URI = "file://wolfenginetest.c \
           file://wolfengineenv.sh \
          "

# wrynose+ bitbake forbids S = "${WORKDIR}"; use UNPACKDIR (where file:// unpacks)
# and fall back to WORKDIR on older releases that don't define it.
python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}')
    else:
        d.setVar('S', '${WORKDIR}')
}

do_compile() {
    ${CC} ${S}/wolfenginetest.c -o wolfenginetest \
        ${CFLAGS} ${LDFLAGS} $(pkg-config --cflags --libs openssl) -ldl -lwolfssl -lwolfengine
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/wolfenginetest ${D}${bindir}/wolfenginetest
    install -m 0755 ${S}/wolfengineenv.sh ${D}${bindir}/wolfengineenv

}

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFENGINE_TEST} ${WOLFENGINE_ENV}')
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' bash')
}
