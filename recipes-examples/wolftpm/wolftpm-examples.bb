SUMMARY = "wolfTPM Examples Directory"
DESCRIPTION = "wolfTPM examples directory used to demonstrate \
               features of a TPM 2.0 module"
HOMEPAGE = "https://www.wolfssl.com/products/wolftpm"
BUGTRACKER =  "https://github.com/wolfssl/wolftpm/issues"
SECTION = "libs"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"
S = "${WORKDIR}/git"
DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfTPM.git;nobranch=1;protocol=https;rev=1fa15951eb91a8fe89b3326077b9be6fb105edeb"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFTPM_EXAMPLES_DIR = "${datadir}/wolftpm-examples"
WOLFTPM_EXAMPLES_INSTALL_DIR = "${D}${WOLFTPM_EXAMPLES_DIR}"
WOLFTPM_EXAMPLES_README = "README.txt"
WOLFTPM_EXAMPLES_README_DIR = "${WOLFTPM_EXAMPLES_INSTALL_DIR}/${WOLFTPM_EXAMPLES_README}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wofltpm_examples_dir = d.getVar('WOLFTPM_EXAMPLES_DIR', True)
    wolftpm_examples_install_dir = d.getVar('WOLFTPM_EXAMPLES_INSTALL_DIR', True)
    wolftpm_examples_readme_dir = d.getVar('WOLFTPM_EXAMPLES_README_DIR', True)

    bb.note("Installing dummy file for wolfTPM examples")
    installDir = 'install -m 0755 -d "%s"\n' % wolftpm_examples_install_dir
    makeDummy = 'echo "This is a dummy package" > "%s"\n' % wolftpm_examples_readme_dir

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', makeDummy)

    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn

    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wofltpm_examples_dir + '/*'
    d.setVar(files_var_name, new_files)
}
