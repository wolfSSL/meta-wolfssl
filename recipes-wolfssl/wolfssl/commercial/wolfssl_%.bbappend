BBFILE_PRIORITY='2'
COMMERCIAL_CONFIG_DIR := "${@os.path.dirname(d.getVar('FILE', True))}"
LICENSE="Proprietary"                                                           
LIC_FILES_CHKSUM="file://${WOLF_LICENSE};md5=${WOLF_LICENSE_MD5}"

SRC_URI="file://${COMMERCIAL_CONFIG_DIR}/files/${WOLFSSL_SRC}.7z"
SRC_URI[sha256sum]="${WOLFSSL_SRC_SHA}"

DEPENDS += "p7zip-native"

S = "${WORKDIR}/${WOLFSSL_SRC}"

do_unpack[depends] += "p7zip-native:do_populate_sysroot"

do_unpack() {
    cp -f "${COMMERCIAL_CONFIG_DIR}/files/${WOLFSSL_SRC}.7z" "${WORKDIR}"
    7za x "${WORKDIR}/${WOLFSSL_SRC}.7z" -p"${WOLFSSL_SRC_PASS}" -o"${WORKDIR}" -aoa
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

    # Install wolfcrypttest binary
    wolfcrypt_test_dir = '${B}/wolfcrypt/test/.libs'
    wolfcrypt_test = 'testwolfcrypt'
    wolfcrypt_test_yocto = 'wolfcrypttest'
    wolfcrypt_install_dir = '${D}${bindir}'

    bbnote = 'bbnote "Installing wolfCrypt Tests"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolfcrypt_install_dir)
    cpTest = 'if [ -f "%s/%s" ]; then cp "%s/%s" "%s/%s"; fi\n' % (wolfcrypt_test_dir, wolfcrypt_test, wolfcrypt_test_dir, wolfcrypt_test, wolfcrypt_install_dir, wolfcrypt_test_yocto)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpTest)
}

TARGET_CFLAGS += "-DUSE_CERT_BUFFERS_2048 -DUSE_CERT_BUFFERS_256 -DWOLFSSL_RSA_KEY_CHECK -DNO_WRITE_TEMP_FILES"
