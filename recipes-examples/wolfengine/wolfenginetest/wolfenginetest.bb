SUMMARY = "Test program for custom OpenSSL engine "
DESCRIPTION = "Compiles and runs a test program to verify the functionality of the custom OpenSSL engine."
HOMEPAGE = "https://www.wolfssl.com"
SECTION = "examples"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

DEPENDS = "openssl pkgconfig-native wolfssl wolfengine"
PROVIDES += "wolfenginetest"

WOLFENGINE_TEST = "${bindir}/wolfenginetest"
WOLFENGINE_ENV = "${bindir}/wolfenginetest"

SRC_URI = "file://wolfenginetest.c \
           file://wolfengineenv.sh \
          "

S = "${WORKDIR}"

inherit pkgconfig

do_compile() {
    ${CC} ${WORKDIR}/wolfenginetest.c -o wolfenginetest \
        ${CFLAGS} ${LDFLAGS} $(pkg-config --cflags --libs openssl) -ldl -lwolfssl -lwolfengine
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfenginetest ${D}${bindir}/wolfenginetest
    install -m 0755 ${WORKDIR}/wolfengineenv.sh ${D}${bindir}/wolfengineenv
    
}


python() {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfengine_test = d.getVar('WOLFENGINE_TEST', True)    
    wolfengine_env = d.getVar('WOLFENGINE_ENV', True)    
    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn
    
       
    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfengine_test + ' ' + wolfengine_env
    d.setVar(files_var_name, new_files)

    rdepends_var_name = 'RDEPENDS_' + pn if (distro_version.startswith('2.') or distro_version.startswith('3.')) else 'RDEPENDS:' + pn

    current_rdepends = d.getVar(rdepends_var_name, True) or ""
    new_rdepends = current_rdepends + " bash"
    d.setVar(rdepends_var_name, new_rdepends) 

}
