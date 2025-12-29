inherit wolfssl-compatibility

PV = "3.10"
SUMMARY = "A low level cryptographic library"
DESCRIPTION = "Nettle is a cryptographic library that is designed to fit easily in more or less any context: In crypto toolkits for object-oriented languages (C++, Python, Pike, ...), in applications like LSH or GNUPG, or even in kernel space."
HOMEPAGE = "http://www.lysator.liu.se/~nisse/nettle/"
DESCRIPTION = "It tries to solve a problem of providing a common set of \
cryptographic algorithms for higher-level applications by implementing a \
context-independent set of cryptographic algorithms"
SECTION = "libs"
LICENSE = "LGPL-3.0-or-later | GPL-2.0-or-later"

LIC_FILES_CHKSUM = "file://COPYING.LESSERv3;md5=6a6a8e020838b23406c81b19c1d46df6 \
                    file://COPYINGv2;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
                    file://serpent-decrypt.c;beginline=14;endline=36;md5=ca0d220bc413e1842ecc507690ce416e \
                    file://serpent-set-key.c;beginline=14;endline=36;md5=ca0d220bc413e1842ecc507690ce416e"

DEPENDS += "gmp"

SRC_URI = "${GNU_MIRROR}/${BPN}/${BP}.tar.gz \
           file://run-ptest \
           "

SRC_URI[sha256sum] = "b4c518adb174e484cb4acea54118f02380c7133771e7e9beb98a0787194ee47c"

UPSTREAM_CHECK_REGEX = "nettle-(?P<pver>\d+(\.\d+)+)\.tar"

inherit autotools ptest multilib_header lib_package

EXTRA_AUTORECONF += "--exclude=aclocal"

EXTRA_OECONF = "--disable-openssl"

python __anonymous() {
    # Handle ARM NEON settings
    if bb.utils.contains('TUNE_FEATURES', 'neon', False, True, d):
        if d.getVar('TARGET_ARCH') in ['armv7a', 'armv7ve']:
            wolfssl_varAppendNonOverride(d, 'EXTRA_OECONF', ' --disable-arm-neon --disable-fat')

    wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/files:')
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}-ptest', ' ${PN}-bin')
}

do_compile_ptest() {
    oe_runmake -C testsuite
}

# Note: Removed do_install:append() with oe_multilib_header
# nettle 3.10's version.h has no arch-specific content and doesn't need multilib handling

do_install_ptest() {
        install -d ${D}${PTEST_PATH}/testsuite/
        install ${B}/testsuite/*-test ${D}${PTEST_PATH}/testsuite/
        install ${S}/testsuite/*-test ${D}${PTEST_PATH}/testsuite/
        install ${S}/testsuite/gold-bug.txt ${D}${PTEST_PATH}/testsuite/
        install ${S}/testsuite/sc-valgrind.sh ${D}${PTEST_PATH}/testsuite/

        # Install a symlink for dlopen-test
        ln -sr ${D}${libdir}/libnettle.so.*.* ${D}${PTEST_PATH}/libnettle.so
        # These examples are needed for pkcs1-conv-test
        install ${B}/examples/rsa-sign ${B}/examples/rsa-verify ${D}${PTEST_PATH}/testsuite/
        # Fix build-time relative paths
        sed -i -e 's|../tools/|${bindir}/|g' ${D}${PTEST_PATH}/testsuite/*-test
        sed -i -e 's|../examples/|./|g' ${D}${PTEST_PATH}/testsuite/*-test
}

BBCLASSEXTEND = "native nativesdk"
