SUMMARY = "wolfProvider Command-Line Test Suite"
DESCRIPTION = "Command-line test scripts for wolfProvider - tests hash, AES, RSA, ECC, and certificate operations"
HOMEPAGE = "https://github.com/wolfssl/wolfProvider"
BUGTRACKER = "https://github.com/wolfssl/wolfProvider/issues"
SECTION = "examples"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

DEPENDS = "openssl virtual/wolfssl wolfprovider"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varSet(d, 'RDEPENDS', '${PN}', 'bash openssl wolfprovider')
}

SRC_URI = "git://github.com/wolfssl/wolfProvider.git;nobranch=1;protocol=https;rev=a8223f5707a9c4460d89f4cbe7b3a129c4e85c6a \
           file://wolfprovidercmd.sh"


S = "${WORKDIR}/git"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFPROV_CMD_TEST_DIR = "${datadir}/wolfprovider-cmd-tests"
WOLFPROV_CMD_TEST_INSTALL_DIR = "${D}${WOLFPROV_CMD_TEST_DIR}"

do_install() {
    # Create directory structure that do-cmd-tests.sh expects
    install -d ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test

    # Copy main cmd-test scripts to scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/do-cmd-tests.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/cmd-test-common.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/clean-cmd-test.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/hash-cmd-test.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/aes-cmd-test.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/rsa-cmd-test.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/ecc-cmd-test.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/
    install -m 0755 ${S}/scripts/cmd_test/req-cmd-test.sh ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/cmd_test/

    # Copy env setup script to scripts/
    install -m 0755 ${S}/scripts/env-setup ${WOLFPROV_CMD_TEST_INSTALL_DIR}/scripts/

    # Copy provider configuration files to root of test dir
    install -m 0644 ${S}/provider.conf ${WOLFPROV_CMD_TEST_INSTALL_DIR}/
    install -m 0644 ${S}/provider-fips.conf ${WOLFPROV_CMD_TEST_INSTALL_DIR}/ || true

    # Install wrapper script to bindir
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/wolfprovidercmd.sh ${D}${bindir}/wolfprovidercmd
}

python __anonymous() {
    wolfssl_varSet(d, 'FILES', '${PN}', '${WOLFPROV_CMD_TEST_DIR}/* ${bindir}/wolfprovidercmd')
}
