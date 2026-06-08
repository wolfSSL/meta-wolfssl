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

# file:// sources unpack into UNPACKDIR on newer releases (styhead+) and into
# WORKDIR on Scarthgap and older (which don't define UNPACKDIR). Track that
# location in our own INSTALL_TEST var rather than overriding S.
#
# Do NOT set S = "${WORKDIR}": base.bbclass appends ${S} and ${B} to
# PSEUDO_IGNORE_PATHS, so an S that equals WORKDIR makes pseudo ignore the whole
# work tree -- including ${WORKDIR}/package -- and do_package's chown-to-root
# then fails with "Operation not permitted" (EPERM) on package/usr. Leaving S at
# its default subdir keeps the package dir under pseudo's fakeroot.
python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('INSTALL_TEST', '${UNPACKDIR}')
    else:
        d.setVar('INSTALL_TEST', '${WORKDIR}')
}

do_compile() {
    # Compile from the source dir with a relative filename so the absolute
    # TMPDIR path is not baked into the binary's debug info ([buildpaths] QA).
    cd ${INSTALL_TEST}
    ${CC} wolfenginetest.c -o wolfenginetest \
        ${CFLAGS} ${LDFLAGS} $(pkg-config --cflags --libs openssl) -ldl -lwolfssl -lwolfengine
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${INSTALL_TEST}/wolfenginetest ${D}${bindir}/wolfenginetest
    install -m 0755 ${INSTALL_TEST}/wolfengineenv.sh ${D}${bindir}/wolfengineenv

}

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFENGINE_TEST} ${WOLFENGINE_ENV}')
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' bash')
}
