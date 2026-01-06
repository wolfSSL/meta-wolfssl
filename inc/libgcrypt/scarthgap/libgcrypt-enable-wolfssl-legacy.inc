# libgcrypt with wolfSSL FIPS backend
#
# This include file configures libgcrypt to use wolfSSL/wolfCrypt as the crypto backend.
# Only applied when wolfssl-fips is the active provider.

# Override to use custom git repo and version - TARGET ONLY

# Set your desired version
PV_class-target = "1.11.0"

# Update license checksums for version 1.11.0
LIC_FILES_CHKSUM_class-target = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.LIB;md5=4fbd65380cdd255951079008b364516c \
                    file://LICENSES;md5=034b4e369944ad4b52a68368f1cf98b8 \
                    "

# Override source to use wolfSSL-enabled git repo
SRC_URI_class-target = "git://github.com/wolfSSL/libgcrypt-wolfssl.git;protocol=https;branch=libgcrypt-1.11.0-wolfCrypt \
                        file://run-ptest \
                        file://wc_ptest-fixes.patch \
                        "

# Set to specific commit hash or use "${AUTOREV}" for latest
SRCREV_class-target = "${AUTOREV}"

# Source directory for git checkouts
S_class-target = "${WORKDIR}/git"

# Add patch directory to file search path
# Patches are in files/ subdirectory relative to this .inc file
FILESEXTRAPATHS_prepend_class-target := "${WOLFSSL_LAYERDIR}/inc/libgcrypt/files:"

# Add wolfssl as dependency
DEPENDS_append_class-target = " virtual/wolfssl"
RDEPENDS_${PN}_append_class-target = " wolfssl"

# Add wolfSSL FIPS configuration flag
EXTRA_OECONF_append_class-target = " --enable-wolfssl-fips --with-wolfssl=${STAGING_EXECPREFIXDIR} --disable-jent-support --disable-doc"

# In FIPS mode, some tests are excluded - install only tests that were actually built
do_install_ptest_class-target() {
    cd ${B}/tests
    oe_runmake testdrv-build testdrv
    for f in testdrv $(srcdir=${S}/tests ./testdrv-build --files | sort | uniq); do
        if [ -f "$f" ]; then
            install "$f" ${D}${PTEST_PATH}
        fi
    done
    # Install the run-ptest script from the base recipe
    if [ -f ${WORKDIR}/run-ptest ]; then
        install -m 0755 ${WORKDIR}/run-ptest ${D}${PTEST_PATH}
    fi
}
