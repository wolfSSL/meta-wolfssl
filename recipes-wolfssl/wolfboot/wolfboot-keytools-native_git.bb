SUMMARY = "wolfBoot signing and key generation tools (native)"
DESCRIPTION = "Host-side keygen and sign utilities for wolfBoot secure-boot \
image signing. Builds RSA4096 signing keys and signs firmware images with \
SHA3-384 hashes. Uses wolfBoot's bundled wolfCrypt (under lib/wolfssl) -- \
no external wolfSSL dependency."

require wolfboot.inc

inherit native

do_configure[noexec] = "1"

do_compile() {
    # Build the keytools (host-side signing/keygen utilities).
    oe_runmake -C tools/keytools \
        CC="${CC}" \
        LD="${CC}" \
        WOLFBOOTDIR=${S} \
        WOLFBOOT_LIB_WOLFSSL=${S}/lib/wolfssl \
        V=1
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/tools/keytools/sign ${D}${bindir}/wolfboot-sign
    install -m 0755 ${S}/tools/keytools/keygen ${D}${bindir}/wolfboot-keygen
}
