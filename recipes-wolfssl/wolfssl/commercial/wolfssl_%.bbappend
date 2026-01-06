BBFILE_PRIORITY = "2"

COMMERCIAL_CONFIG_DIR := "${@os.path.dirname(d.getVar('FILE', True))}"
WOLFSSL_SRC_DIR ?= "${COMMERCIAL_CONFIG_DIR}/files"
WOLFSSL_BUNDLE_FILE ?= ""
WOLFSSL_BUNDLE_GCS_URI ?= ""
WOLFSSL_BUNDLE_GCS_TOOL ?= ""

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WOLFSSL_LICENSE};md5=${WOLFSSL_LICENSE_MD5}"

COMMERCIAL_BUNDLE_ENABLED = "1"
COMMERCIAL_BUNDLE_DIR = "${WOLFSSL_SRC_DIR}"
COMMERCIAL_BUNDLE_NAME = "${WOLFSSL_SRC}"
COMMERCIAL_BUNDLE_FILE = "${WOLFSSL_BUNDLE_FILE}"
COMMERCIAL_BUNDLE_PASS = "${WOLFSSL_SRC_PASS}"
COMMERCIAL_BUNDLE_SHA = "${WOLFSSL_SRC_SHA}"
COMMERCIAL_BUNDLE_TARGET = "${WORKDIR}"
COMMERCIAL_BUNDLE_GCS_URI = "${WOLFSSL_BUNDLE_GCS_URI}"
COMMERCIAL_BUNDLE_GCS_TOOL = "${@d.getVar('WOLFSSL_BUNDLE_GCS_TOOL') or 'auto'}"

SRC_URI = "${@get_commercial_src_uri(d)}"
S = "${@get_commercial_source_dir(d)}"

inherit wolfssl-commercial wolfssl-compatibility

# Ensure autogen.sh never runs for commercial bundles
do_configure_disable_autogen() {
    echo -e "#!/bin/sh\nexit 0" > ${S}/autogen.sh
    chmod +x ${S}/autogen.sh
}

addtask do_configure_disable_autogen after do_unpack before do_configure
