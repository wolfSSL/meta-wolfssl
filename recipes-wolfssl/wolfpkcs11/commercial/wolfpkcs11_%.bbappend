BBFILE_PRIORITY='2'
COMMERCIAL_CONFIG_DIR := "${@os.path.dirname(d.getVar('FILE', True))}"
LICENSE="Proprietary"                                                           
LIC_FILES_CHKSUM="file://${WOLFPKCS11_LICENSE};md5=${WOLFPKCS11_LICENSE_MD5}"

SRC_URI="file://${COMMERCIAL_CONFIG_DIR}/files/${WOLFPKCS11_SRC}.7z"
SRC_URI[sha256sum]="${WOLFPKCS11_SRC_SHA}"

DEPENDS += "p7zip-native"

S = "${WORKDIR}/${WOLFPKCS11_SRC}"

do_unpack[depends] += "p7zip-native:do_populate_sysroot"

do_unpack() {
    cp -f "${COMMERCIAL_CONFIG_DIR}/files/${WOLFPKCS11_SRC}.7z" "${WORKDIR}"
    7za x "${WORKDIR}/${WOLFPKCS11_SRC}.7z" -p"${WOLFPKCS11_SRC_PASS}" -o"${WORKDIR}" -aoa
}


python() {
    distro_version = d.getVar('DISTRO_VERSION', True)
    autogen_create = 'echo -e "#!/bin/sh\nexit 0" > ${S}/autogen.sh && chmod +x ${S}/autogen.sh'
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        # For Dunfell and earlier
        d.appendVar('do_configure_prepend', autogen_create)
    else:
        # For Kirkstone and later
        d.appendVar('do_configure:prepend', autogen_create)
}
