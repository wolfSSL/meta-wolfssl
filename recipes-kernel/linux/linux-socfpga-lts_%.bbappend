# wolfBoot's Agilex 5 FIT loader accepts an uncompressed kernel image. The
# GSRD kernel append creates Image.lzma unconditionally even though the machine
# configuration requests FIT_KERNEL_COMP_ALG = "none". Rebuild only the FIT
# payload after the GSRD deploy task when wolfBoot is enabled.

do_deploy:append() {
    if [ "${WOLFBOOT_ENABLE}" = "1" ]; then
        fit_its="${B}/fit_${MACHINE_STRIP}_kernel.its"
        if [ "${FPGA_CORE_PGM_ENABLE}" != "1" ]; then
            fit_its="${B}/fit_${MACHINE_STRIP}_kernel_no_rbf.its"
        fi

        if [ -f "${LINUXDEPLOYDIR}/Image" ] && [ -f "$fit_its" ]; then
            cp "${LINUXDEPLOYDIR}/Image" "${B}/Image"
            sed -i \
                -e 's#Image\.lzma#Image#g' \
                -e 's/compression = "lzma"/compression = "none"/g' \
                "$fit_its"
            (cd "${B}" && mkimage -f "$(basename "$fit_its")" "${B}/kernel.itb")
            install -m 0644 "${B}/kernel.itb" "${DEPLOYDIR}/kernel.itb"
        else
            bbfatal "wolfBoot FIT rebuild requires ${LINUXDEPLOYDIR}/Image and $fit_its"
        fi
    fi
}
