SUMMARY = "wolfCrypt Benchmark Application"
DESCRIPTION = "wolfCrypt benchmark application used to benchmark crypto \
               algorithms included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://benchmark.c;beginline=1;endline=20;md5=aca0c406899b7421c67598ba3f55d1a5"
S = "${WORKDIR}/git/wolfcrypt/benchmark"
DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfSSL/wolfssl.git;nobranch=1;protocol=https;rev=66596ad9e1d7efa8479656872cf09c9c1870a02e"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

WOLFCRYPT_BENCHMARK_DIR = "${datadir}/wolfcrypt-benchmark"
WOLFCRYPT_BENCHMARK_INSTALL_DIR = "${D}${WOLFCRYPT_BENCHMARK_DIR}"
WOLFCRYPT_BENCHMARK_README = "README.txt"
WOLFCRYPT_BENCHMARK_README_DIR = "${WOLFCRYPT_BENCHMARK_INSTALL_DIR}/${WOLFCRYPT_BENCHMARK_README}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolfcrypt_benchmark_dir = d.getVar('WOLFCRYPT_BENCHMARK_DIR', True)
    wolfcrypt_benchmark_install_dir = d.getVar('WOLFCRYPT_BENCHMARK_INSTALL_DIR', True)
    wolfcrypt_benchmark_readme_dir = d.getVar('WOLFCRYPT_BENCHMARK_README_DIR', True)

    bb.note("Installing dummy file for wolfCrypt benchmark example")
    installDir = 'install -m 0755 -d "%s"\n' % wolfcrypt_benchmark_install_dir
    makeDummy = 'echo "This is a dummy package" > "%s"\n' % wolfcrypt_benchmark_readme_dir

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', makeDummy)

    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn

    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolfcrypt_benchmark_dir + '/*'
    d.setVar(files_var_name, new_files)
}
