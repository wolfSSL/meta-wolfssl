BBFILE_PRIORITY='2'

LICENSE = "GPL-3.0-only"
FIPSREADY_CONFIG_DIR := "${@os.path.dirname(d.getVar('FILE', True))}"

SRC_URI = "file://${FIPSREADY_CONFIG_DIR}/files/${WOLFSSL_SRC}.zip"
SRC_URI[sha256sum] = "${WOLFSSL_SRC_SHA}"

inherit wolfssl-compatibility

S = "${WORKDIR}/${WOLFSSL_SRC}"

do_configure_disable_autogen() {
    echo -e "#!/bin/sh\nexit 0" > ${S}/autogen.sh
    chmod +x ${S}/autogen.sh
}

addtask do_configure_disable_autogen after do_unpack before do_configure

TARGET_CFLAGS += "-DWOLFCRYPT_FIPS_CORE_HASH_VALUE=${FIPS_HASH} -DFP_MAX_BITS=16384"
EXTRA_OECONF += "--enable-fips=ready "
