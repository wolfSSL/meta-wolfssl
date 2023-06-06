SUMMARY = "wolfSSL Lightweight Embedded SSL/TLS Library"
DESCRIPTION = "wolfSSL is a lightweight SSL/TLS library written in C and \
               optimized for embedded and RTOS environments. It can be up \
               to 20 times smaller than OpenSSL while still supporting \
               a full TLS client and server, up to TLS 1.3"
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl"
BUGTRACKER = "https://github.com/wolfssl/wolfssl/issues"
SECTION = "libs"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"



PROVIDES += "cyassl"
RPROVIDES_${PN} = "cyassl"
PROVIDES += "wolfssl"
RPROVIDES_${PN} = "wolfssl"

SRC_URI = "git://github.com/night1rider/wolfssl.git;protocol=https;branch=wolfssl-wolfcrypttest-statickeys;rev=259b1186f69213038c0c740f50c57173eddbd0b4"

#SRC_URI += "file://6247.patch"

S = "${WORKDIR}/git"

#S = "${WORKDIR}"

inherit autotools pkgconfig

do_configure:prepend() {
    (cd ${S}; cd .; ./autogen.sh; cd -)
}
do_install:prepend(){
    install -m 0755 -d ${D}/usr/bin/certs
    cp -r ${S}/certs/statickeys ${D}/usr/bin/certs
}



BBCLASSEXTEND += "native nativesdk"
