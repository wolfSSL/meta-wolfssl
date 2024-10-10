SUMMARY = "Examples for wolfTPM"
DESCRIPTION = "This recipe provides examples for wolfTPM"
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b234ee4d69f5fce4486a80fdaf4a4263"
SRC_URI = "git://github.com/wolfSSL/wolfTPM/examples.git;nobranch=1;protocol=https;rev=a5f6c912ac6903872d9666238440a76bc9f92517"

DEPENDS += "wolfssl wolftpm"

S = "${WORKDIR}/git/wolfTPM/examples"

do_compile() {
    # Iterate through each directory and compile C files
    for dir in attestation \
               gpio \
               pcr \
               tls \
               bench \
               boot \
               keygen \
               csr \
               endorsement \
               firmware \
               nvram \
               management \
               native \
               pkcs7 \
               seal \
               wrap \
               timestamp; do
        for src in ${S}/$dir/*.c; do
            exe_name=$(basename $src .c)
            ${CC} $src -o ${D}/usr/bin/$exe_name ${CFLAGS} ${LDFLAGS} -lwolfssl -lwolfTPM -ldl
        done
    done
}

do_install() {
    install -d ${D}/usr/bin
    for dir in attestation \
               gpio \
               pcr \
               tls \
               bench \
               boot \
               keygen \
               csr \
               endorsement \
               firmware \
               nvram \
               management \
               native \
               pkcs7 \
               seal \
               wrap \
               timestamp; do
        for src in ${S}/$dir/*.c; do
            exe_name=$(basename $src .c)
            install -m 0755 ${D}/usr/bin/$exe_name ${D}/usr/bin/
        done
    done

    install -d ${D}/usr/include/wolftpm
    install -m 0644 ${S}/tpm_test_keys.h ${D}/usr/include/wolftpm/
    install -m 0644 ${S}/tpm_test.h ${D}/usr/include/wolftpm/
}

PACKAGES = "${PN} ${PN}-dev"
