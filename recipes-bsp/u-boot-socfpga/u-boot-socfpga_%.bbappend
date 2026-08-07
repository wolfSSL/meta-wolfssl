# Use wolfBoot as BL33 in the SoCFPGA TF-A FIT when explicitly enabled.
#
# The Altera BSP still builds U-Boot SPL so DDR, clocks, pinmux and the SD
# controller are initialized by the supported platform first stage. Only the
# U-Boot-proper blob in u-boot.itb is replaced. TF-A BL31 and the board DTB
# remain in their existing FIT nodes.

WOLFBOOT_ENABLE ??= "0"

python __anonymous() {
    if (d.getVar('WOLFBOOT_ENABLE') or '') != '1':
        return

    d.appendVar('DEPENDS', ' wolfboot')
    depends = d.getVarFlag('do_compile', 'depends') or ''
    d.setVarFlag('do_compile', 'depends',
                 depends + ' wolfboot:do_deploy')
}

do_compile:prepend() {
    if [ "${WOLFBOOT_ENABLE}" = "1" ]; then
        fit_dtsi="${S}/arch/arm/dts/socfpga_soc64_fit-u-boot.dtsi"
        if [ ! -f "$fit_dtsi" ]; then
            bbfatal "SoCFPGA FIT description not found: $fit_dtsi"
        fi

        # Keep the source tree pristine. The backup/trap covers both normal
        # completion and compile failures, including workdirs reused from
        # sstate, while still letting U-Boot's normal FIT build consume the
        # generated description.
        fit_dtsi_backup="${B}/socfpga_soc64_fit-u-boot.dtsi.orig"
        install -m 0644 "$fit_dtsi" "$fit_dtsi_backup"
        trap 'install -m 0644 "$fit_dtsi_backup" "$fit_dtsi"; rm -f "$fit_dtsi_backup"' EXIT
        sed -i \
            -e 's/description = "U-Boot SoC64";/description = "wolfBoot secure boot";/' \
            -e 's/filename = "u-boot-nodtb.bin";/filename = "wolfboot.bin";/' \
            "$fit_dtsi"
        wolfboot_payload="${DEPLOY_DIR_IMAGE}/wolfboot.bin"
        if [ ! -f "$wolfboot_payload" ]; then
            bbfatal "wolfBoot BL33 payload not found: $wolfboot_payload"
        fi

        install -m 0644 "$wolfboot_payload" "${S}/wolfboot.bin"
        install -d "${B}/${UBOOT_DEFCONFIG}"
        install -m 0644 "$wolfboot_payload" \
            "${B}/${UBOOT_DEFCONFIG}/wolfboot.bin"
    fi
}
