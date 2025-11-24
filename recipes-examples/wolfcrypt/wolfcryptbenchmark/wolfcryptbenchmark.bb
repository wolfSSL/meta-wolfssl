SUMMARY = "wolfCrypt Benchmark Application"
DESCRIPTION = "wolfCrypt benchmark application used to benchmark crypto \
               algorithms included in the wolfSSL embedded SSL/TLS library."
HOMEPAGE = "https://www.wolfssl.com"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "x11/applications"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://benchmark.c;beginline=1;endline=20;md5=6a14f1f3bfbb40d2c3b7d0f3a1f98ffc"
S = "${WORKDIR}/git/wolfcrypt/benchmark"
DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfSSL/wolfssl.git;nobranch=1;protocol=https;rev=59f4fa568615396fbf381b073b220d1e8d61e4c2"

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
