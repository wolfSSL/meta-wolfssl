BBFILE_PRIORITY='2'
COMMERCIAL_CONFIG_DIR := "${@os.path.dirname(d.getVar('FILE', True))}"
LICENSE="Proprietary"
LIC_FILES_CHKSUM="file://${WOLFMQTT_LICENSE};md5=${WOLFMQTT_LICENSE_MD5}"

SRC_URI="file://${COMMERCIAL_CONFIG_DIR}/files/${WOLFMQTT_SRC}.7z"
SRC_URI[sha256sum]="${WOLFMQTT_SRC_SHA}"

DEPENDS += "p7zip-native"

inherit wolfssl-compatibility

S = "${WORKDIR}/${WOLFMQTT_SRC}"

do_unpack[depends] += "p7zip-native:do_populate_sysroot"

do_unpack() {
    cp -f "${COMMERCIAL_CONFIG_DIR}/files/${WOLFMQTT_SRC}.7z" "${WORKDIR}"
    7za x "${WORKDIR}/${WOLFMQTT_SRC}.7z" -p"${WOLFMQTT_SRC_PASS}" -o"${WORKDIR}" -aoa
}

do_configure_disable_autogen() {
    echo -e "#!/bin/sh\nexit 0" > ${S}/autogen.sh
    chmod +x ${S}/autogen.sh
}

addtask do_configure_disable_autogen after do_unpack before do_configure
