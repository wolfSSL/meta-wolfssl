SUMMARY = "wolfSSL FIPS 140-3 Validated Cryptography"
DESCRIPTION = "wolfSSL is a lightweight SSL/TLS library with FIPS 140-3 validated cryptography module. This recipe provides the FIPS-validated version of wolfSSL."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl-fips/"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "libs"

# Commercial/FIPS license - Update when using commercial bundle
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${WOLFSSL_LICENSE};md5=${WOLFSSL_LICENSE_MD5}"

DEPENDS += "util-linux-native"

# This recipe provides:
# - wolfssl-fips (automatic from recipe name)
# - virtual/wolfssl (build-time interface for switching implementations)
# At runtime, the wolfssl-fips package provides wolfssl to satisfy package dependencies
PROVIDES += "wolfssl-fips virtual/wolfssl"
RPROVIDES:${PN} += "wolfssl"

# Lower preference so regular wolfssl is default
# Users must explicitly set PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"
DEFAULT_PREFERENCE = "-1"

# FIPS bundle source - expects commercial bundle in files/ directory
# User must set these in local.conf:
#   WOLFSSL_VERSION = "x.x.x"
#   WOLFSSL_SRC = "wolfssl-x.x.x-commercial-fips-linux"
#   WOLFSSL_SRC_SHA = "sha256sum of bundle"
#   WOLFSSL_SRC_PASS = "password for bundle"
#   WOLFSSL_LICENSE = "${S}/LICENSING"  (or path to license file relative to source code)
#   WOLFSSL_LICENSE_MD5 = "md5sum of license"
#   FIPS_HASH = "hash value after first build" (for FIPS validation)

# Commercial bundle configuration
# Users can set WOLFSSL_SRC_DIR in local.conf to specify bundle location
WOLFSSL_SRC_DIR ?= "${@os.path.dirname(d.getVar('FILE', True))}/commercial/files"

# Enable commercial bundle extraction only when WOLFSSL_SRC is configured
COMMERCIAL_BUNDLE_ENABLED = "${@'1' if d.getVar('WOLFSSL_SRC') else '0'}"

# Map to commercial class variables
COMMERCIAL_BUNDLE_DIR = "${WOLFSSL_SRC_DIR}"
COMMERCIAL_BUNDLE_NAME = "${WOLFSSL_SRC}"
COMMERCIAL_BUNDLE_PASS = "${WOLFSSL_SRC_PASS}"
COMMERCIAL_BUNDLE_SHA = "${WOLFSSL_SRC_SHA}"
COMMERCIAL_BUNDLE_TARGET = "${WORKDIR}"

# Use helper functions from wolfssl-commercial.bbclass for conditional configuration
SRC_URI = "${@get_commercial_src_uri(d)}"
S = "${@get_commercial_source_dir(d)}"

inherit autotools pkgconfig wolfssl-helper wolfssl-commercial wolfssl-fips-helper

# Skip the package check for wolfssl-fips itself (it's the base library)
deltask do_wolfssl_check_package

# Conditionally enable native/nativesdk variants only when FIPS is configured
python __anonymous() {
    wolfssl_src = d.getVar('WOLFSSL_SRC')
    if wolfssl_src and wolfssl_src.strip():
        d.setVar('BBCLASSEXTEND', 'native nativesdk')
}

# FIPS-specific configuration
# Note: FIPS hash is handled by wolfssl-fips-helper.bbclass
TARGET_CFLAGS += "-DFP_MAX_BITS=16384"
EXTRA_OECONF += " \
    --enable-fips=v5 \
    --enable-reproducible-build \
"

