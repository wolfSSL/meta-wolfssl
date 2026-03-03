# Use the linuxkm Makefile's native signing target to produce libwolfssl.ko.signed,
# then install it in place of the unsigned libwolfssl.ko.

do_compile() {
    if [ "${WOLFSSL_FIPS_HASH_MODE_LINUXKM}" = "auto" ]; then
        bbnote "Auto FIPS hash mode: running 'make module-with-matching-fips-hash'"
        bbnote "This will build the .ko, compute the FIPS hash, patch it in-place, and sign it."
        unset LDFLAGS
        unset CPPFLAGS
        oe_runmake module-with-matching-fips-hash HOSTCC=$(which ${BUILD_CC})
    else
        oe_runmake
    fi
}

do_install() {
    install -d ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra
    KO_SIGNED="${S}/linuxkm/libwolfssl.ko.signed"
    KO_UNSIGNED="${S}/linuxkm/libwolfssl.ko"
    if [ -f "${KO_SIGNED}" ]; then
        bbnote "Installing libwolfssl.ko.signed (signed by linuxkm Makefile)"
        install -m 0644 "${KO_SIGNED}" \
            ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/libwolfssl.ko
    else
        bbwarn "libwolfssl.ko.signed not found - installing unsigned libwolfssl.ko"
        install -m 0644 "${KO_UNSIGNED}" \
            ${D}${nonarch_base_libdir}/modules/${KERNEL_VERSION}/extra/
    fi
}
