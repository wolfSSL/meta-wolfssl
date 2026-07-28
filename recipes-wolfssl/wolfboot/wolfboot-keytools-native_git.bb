SUMMARY = "wolfBoot signing and key generation tools (native)"
DESCRIPTION = "Host-side keygen and sign utilities for wolfBoot secure-boot \
image signing. Builds RSA4096 signing keys and signs firmware images with \
SHA3-384 hashes. Uses wolfBoot's bundled wolfCrypt (under lib/wolfssl) by \
default, or the tree named by WOLFBOOT_WOLFSSL_SRC when that is set."

require wolfboot.inc

inherit native

do_configure[noexec] = "1"

do_compile() {
    # Build the keytools (host-side signing/keygen utilities).
    #
    # Track wolfboot_git.bb's choice of wolfCrypt: the keytools produce the
    # keystore and the image signatures that wolfboot.elf then verifies, so
    # building the two halves from different wolfSSL versions risks a format
    # mismatch that only shows up as a failed verification on the target.
    # tools/keytools/Makefile also emits its objects under
    # $(WOLFBOOT_LIB_WOLFSSL)/wolfcrypt/src, hence the staged copy here too.
    WOLFSSL_DIR="${S}/lib/wolfssl"
    if [ -n "${WOLFBOOT_WOLFSSL_SRC}" ]; then
        WOLFSSL_DIR="${WOLFBOOT_WOLFSSL_STAGED_SRC}"
    fi

    oe_runmake -C tools/keytools \
        CC="${CC}" \
        LD="${CC}" \
        WOLFBOOTDIR=${S} \
        WOLFBOOT_LIB_WOLFSSL="$WOLFSSL_DIR" \
        V=1
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/tools/keytools/sign ${D}${bindir}/wolfboot-sign
    install -m 0755 ${S}/tools/keytools/keygen ${D}${bindir}/wolfboot-keygen
}
