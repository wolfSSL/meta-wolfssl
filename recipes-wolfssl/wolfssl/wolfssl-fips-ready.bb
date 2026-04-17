SUMMARY = "wolfSSL FIPS Ready Cryptography"
DESCRIPTION = "wolfSSL is a lightweight SSL/TLS library with FIPS Ready cryptography module. This recipe provides the FIPS Ready version of wolfSSL."

# Default to a placeholder; users should set WOLFSSL_VERSION to their bundle version
WOLFSSL_VERSION ?= "0.0.0"
PV = "${WOLFSSL_VERSION}"
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl-fips/"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "libs"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=${WOLFSSL_LICENSE_MD5}"

DEPENDS += "util-linux-native unzip-native"

# This recipe provides:
# - wolfssl-fips-ready (automatic from recipe name)
# - virtual/wolfssl (build-time interface for switching implementations)
# At runtime, the wolfssl-fips-ready package provides wolfssl to satisfy package dependencies
PROVIDES += "wolfssl-fips-ready virtual/wolfssl"

inherit autotools pkgconfig wolfssl-helper wolfssl-commercial wolfssl-fips-helper wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RPROVIDES', '${PN}', ' wolfssl')
}

# Lower preference so regular wolfssl is default
# Users must explicitly set PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips-ready"
DEFAULT_PREFERENCE = "-1"

# FIPS Ready bundle source - user must set these in local.conf:
#   WOLFSSL_VERSION = "x.x.x"
#   WOLFSSL_SRC = "wolfssl-x.x.x-commercial-fips-ready"
#   WOLFSSL_SRC_SHA = "sha256sum of bundle"
#   WOLFSSL_SRC_DIR = "/path/to/directory/containing/zip"
#   WOLFSSL_BUNDLE_FILE = "wolfssl-x.x.x-commercial-fips-ready.zip"
#   WOLFSSL_LICENSE_MD5 = "md5sum of COPYING file"
#   FIPS_HASH = "hash value after first build" (for FIPS validation, if using manual mode)

# Commercial bundle configuration
# WOLFSSL_SRC_DIR must be set in local.conf to the directory containing the .zip bundle
# Optionally set WOLFSSL_SRC_DIRECTORY to point directly to already-extracted source
WOLFSSL_SRC_DIR ?= ""
WOLFSSL_SRC_DIRECTORY ?= ""
WOLFSSL_BUNDLE_FILE ?= ""

# Map to commercial class variables
COMMERCIAL_BUNDLE_DIR = "${WOLFSSL_SRC_DIR}"
COMMERCIAL_BUNDLE_NAME = "${WOLFSSL_SRC}"
COMMERCIAL_BUNDLE_FILE = "${WOLFSSL_BUNDLE_FILE}"
COMMERCIAL_BUNDLE_PASS = ""
COMMERCIAL_BUNDLE_SHA = "${WOLFSSL_SRC_SHA}"
COMMERCIAL_BUNDLE_TARGET = "${WORKDIR}"
COMMERCIAL_BUNDLE_GCS_URI = ""
COMMERCIAL_BUNDLE_GCS_TOOL = ""
COMMERCIAL_BUNDLE_SRC_DIR = "${WOLFSSL_SRC_DIRECTORY}"

# Use helper functions from wolfssl-commercial.bbclass for conditional configuration
SRC_URI = "${@get_commercial_src_uri(d)}"
S = "${@get_commercial_source_dir(d)}"

# Skip the package check for wolfssl-fips-ready itself (it's the base library)
deltask do_wolfssl_check_package

# Enable native/nativesdk variants when FIPS Ready is configured
BBCLASSEXTEND = "${@'native nativesdk' if (d.getVar('WOLFSSL_SRC') or '').strip() else ''}"

# FIPS Ready configuration
# Note: FIPS hash is handled by wolfssl-fips-helper.bbclass
TARGET_CFLAGS += "-DFP_MAX_BITS=16384"
EXTRA_OECONF += " \
    --enable-fips=ready \
    --enable-reproducible-build \
"
