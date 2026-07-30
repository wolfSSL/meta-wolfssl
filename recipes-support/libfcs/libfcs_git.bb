SUMMARY = "Altera FPGA Crypto Services library"
DESCRIPTION = "Userspace library for the FPGA Crypto Services of Altera \
SoCFPGA devices, exposing the Secure Device Manager crypto mailbox through \
/sys/kernel/fcs_sysfs."
HOMEPAGE = "https://github.com/altera-fpga/libfcs"
LICENSE = "MIT-0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=6f25b4c3a6d23285f956387ab54830ad"

SRC_URI = "git://github.com/altera-fpga/libfcs.git;protocol=https;branch=main"
SRCREV = "87b4b726f4981be102fc8f09feab051fe3578334"
PV = "3.01+git"

DEPENDS = "dtc"

COMPATIBLE_HOST = "aarch64.*-linux"

python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}

inherit cmake

EXTRA_OECMAKE = "-DARCH=linux_aarch64"

# upstream install() destinations are relative, so they nest under ${prefix}
wolfssl_fcs_fixup_install() {
    if [ -d ${D}${prefix}${prefix} ]; then
        cp -a ${D}${prefix}${prefix}/. ${D}${prefix}/
        rm -rf ${D}${prefix}${prefix}
    fi

    # libfcs hardcodes /usr/lib. Move the library to Yocto's configured libdir,
    # then supply the linker name expected by consumers such as wolfSSL.
    if [ "${prefix}/lib" != "${libdir}" ] && \
       [ -e ${D}${prefix}/lib/libFCS.so.3 ]; then
        install -d ${D}${libdir}
        mv ${D}${prefix}/lib/libFCS.so.3 ${D}${libdir}/
        rmdir ${D}${prefix}/lib
    fi
    if [ -e ${D}${libdir}/libFCS.so.3 ]; then
        ln -sfn libFCS.so.3 ${D}${libdir}/libFCS.so
    fi
}

do_install[postfuncs] += "wolfssl_fcs_fixup_install"
