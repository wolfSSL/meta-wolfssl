BBFILE_PRIORITY='2'

LICENSE = "GPL-3.0-only"
FIPSREADY_CONFIG_DIR := "${@os.path.dirname(d.getVar('FILE', True))}"

SRC_URI = "file://${FIPSREADY_CONFIG_DIR}/files/${WOLF_SRC}.zip"
SRC_URI[sha256sum] = "${WOLF_SRC_SHA}"

S = "${WORKDIR}/${WOLF_SRC}"

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

TARGET_CFLAGS += "-DWOLFCRYPT_FIPS_CORE_HASH_VALUE=${FIPS_HASH} -DFP_MAX_BITS=16384"
EXTRA_OECONF += "--enable-fips=ready "
