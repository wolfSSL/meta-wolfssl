#wolftpm-wrap-test.bb
SUMMARY = "wolfTPM Examples Directory"
DESCRIPTION = "wolfTPM examples directory used to demonstrate \
               features of a TPM 2.0 module"
HOMEPAGE = "https://www.wolfssl.com/products/wolftpm"
BUGTRACKER =  "https://github.com/wolfssl/wolftpm/issues"
SECTION = "libs"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"
S = "${WORKDIR}/git"
DEPENDS += "virtual/wolfssl"

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolftpm wolfssl')
}

SRC_URI = "git://github.com/wolfssl/wolfTPM.git;nobranch=1;protocol=https;rev=bcf2647ebcf76e76a75cefc46f7187d213eb1fcd"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFTPM_EXAMPLES_DIR = "${datadir}/wolftpm-test"
WOLFTPM_EXAMPLES_INSTALL_DIR = "${D}${WOLFTPM_EXAMPLES_DIR}"
WOLFTPM_EXAMPLES_README = "README.txt"
WOLFTPM_EXAMPLES_README_DIR = "${WOLFTPM_EXAMPLES_INSTALL_DIR}/${WOLFTPM_EXAMPLES_README}"

do_install_wolftpm_dummy() {
    bbnote "Installing dummy file for wolfTPM test example"
    install -m 0755 -d "${WOLFTPM_EXAMPLES_INSTALL_DIR}"
    echo "This is a dummy package" > "${WOLFTPM_EXAMPLES_README_DIR}"
}

addtask do_install_wolftpm_dummy after do_install before do_package
do_install_wolftpm_dummy[fakeroot] = "1"

python __anonymous() {
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${WOLFTPM_EXAMPLES_DIR}/*')
}
