# libgcrypt with wolfSSL FIPS backend
#
# This include file configures libgcrypt to use wolfSSL/wolfCrypt as the crypto backend.
# Only applied when wolfssl-fips is the active provider.

inherit wolfssl-compatibility

# Override to use custom git repo and version - TARGET ONLY

# Set your desired version
PV_class-target = "1.11.0"

# Update license checksums for version 1.11.0
LIC_FILES_CHKSUM_class-target = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://COPYING.LIB;md5=4fbd65380cdd255951079008b364516c \
                    file://LICENSES;md5=034b4e369944ad4b52a68368f1cf98b8 \
                    "

# Source directory for git checkouts
S_class-target = "${WORKDIR}/git"
SRCREV_class-target = "${AUTOREV}"

python __anonymous() {
    if bb.data.inherits_class('target', d):
        # Override source to use wolfSSL-enabled git repo
        d.setVar('SRC_URI', 'git://github.com/wolfSSL/libgcrypt-wolfssl.git;protocol=https;branch=libgcrypt-1.11.0-wolfCrypt file://run-ptest file://wc_ptest-fixes.patch')

        # Add patch directory to file search path
        wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${WOLFSSL_LAYERDIR}/inc/libgcrypt/files:')

        # Add wolfssl as dependency
        wolfssl_varAppendNonOverride(d, 'DEPENDS', ' virtual/wolfssl')
        wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl')

        # Add wolfSSL FIPS configuration flag
        wolfssl_varAppendNonOverride(d, 'EXTRA_OECONF', ' --enable-wolfssl-fips --with-wolfssl=${STAGING_EXECPREFIXDIR} --disable-jent-support --disable-doc')
}

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
