# Use wolfBoot as BL33 in the SoCFPGA TF-A FIT when explicitly enabled.
#
# The Altera BSP still builds U-Boot SPL so DDR, clocks, pinmux and the SD
# controller are initialized by the supported platform first stage. Only the
# U-Boot-proper blob in u-boot.itb is replaced. TF-A BL31 and the board DTB
# remain in their existing FIT nodes.

WOLFBOOT_ENABLE ??= "0"

# do_unpack cleans ${S}, so toggling wolfBoot re-unpacks a pristine tree.
do_unpack[vardeps] += "WOLFBOOT_ENABLE"

python __anonymous() {
    if (d.getVar('WOLFBOOT_ENABLE') or '') != '1':
        return

    d.appendVar('DEPENDS', ' wolfboot')
    depends = d.getVarFlag('do_compile', 'depends') or ''
    d.setVarFlag('do_compile', 'depends',
                 depends + ' wolfboot:do_deploy')
}

do_wolfboot_fit_dtsi() {
    if [ "${WOLFBOOT_ENABLE}" != "1" ]; then
        return
    fi

    fit_dtsi="${S}/arch/arm/dts/socfpga_soc64_fit-u-boot.dtsi"
    if [ ! -f "$fit_dtsi" ]; then
        bbfatal "SoCFPGA FIT description not found: $fit_dtsi"
    fi

    sed -i \
        -e 's/description = "U-Boot SoC64";/description = "wolfBoot secure boot";/' \
        -e 's/filename = "u-boot-nodtb.bin";/filename = "wolfboot.bin";/' \
        "$fit_dtsi"
    if ! grep -q 'filename = "wolfboot.bin";' "$fit_dtsi"; then
        bbfatal "Could not set wolfboot.bin as BL33 in $fit_dtsi"
    fi
}
addtask wolfboot_fit_dtsi after do_patch before do_configure

do_compile:prepend() {
    if [ "${WOLFBOOT_ENABLE}" = "1" ]; then
        wolfboot_payload="${DEPLOY_DIR_IMAGE}/wolfboot.bin"
        if [ ! -f "$wolfboot_payload" ]; then
            bbfatal "wolfBoot BL33 payload not found: $wolfboot_payload"
        fi

        # binman searches the source tree for FIT blob-ext files.
        install -m 0644 "$wolfboot_payload" "${S}/wolfboot.bin"
    fi
}
