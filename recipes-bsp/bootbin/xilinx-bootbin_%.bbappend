# Replace U-Boot with wolfBoot as second-stage bootloader in BOOT.BIN
#
# Only activates when WOLFBOOT_ENABLE = "1" is set in configuration (e.g.
# local.conf or a machine .conf). Without that flag this bbappend is a
# no-op and xilinx-bootbin keeps using U-Boot.
#
# A dedicated variable is used here instead of inspecting EXTRA_IMAGEDEPENDS:
# EXTRA_IMAGEDEPENDS is frequently set inside image recipes, which are
# parsed in a different context than xilinx-bootbin, so the anonymous
# python() below would see an empty value and silently stay inert.
#
# Boot chain with wolfBoot:
#   FSBL -> PMU FW -> (bitstream) -> ATF (EL3) -> wolfBoot (EL2) -> signed FIT
#
# Default ZynqMP BIF order (machine-xilinx-zynqmp.inc):
#   FSBL -> PMU FW -> bitstream (optional) -> ATF -> DTB -> U-Boot
#
# wolfBoot BIF order:
#   FSBL -> PMU FW -> bitstream (optional) -> ATF -> wolfBoot
#   (DTB is inside the signed FIT image, loaded by wolfBoot at runtime.)

python () {
    if (d.getVar('WOLFBOOT_ENABLE') or '') != '1':
        # wolfBoot not requested -- this bbappend is inert.
        return
    # Apply wolfBoot BIF overrides below.
    d.setVar('BIF_SSBL_ATTR', 'wolfboot')
    d.setVarFlag('BIF_PARTITION_ATTR', 'wolfboot',
                 'destination_cpu=a53-0,exception_level=el-2')
    d.setVarFlag('BIF_PARTITION_IMAGE', 'wolfboot',
                 d.expand('${RECIPE_SYSROOT}/boot/wolfboot.elf'))
    d.setVar('BIF_DEVICETREE_ATTR', '')
    # BIF_PARTITION_IMAGE[wolfboot] points at ${RECIPE_SYSROOT}/boot/wolfboot.elf,
    # which is populated by do_populate_sysroot, not do_deploy. Depend on
    # the right task so xilinx-bootbin blocks until wolfboot.elf is staged.
    d.appendVar('DEPENDS', ' wolfboot')
    existing = d.getVarFlag('do_compile', 'depends') or ''
    d.setVarFlag('do_compile', 'depends', existing + ' wolfboot:do_populate_sysroot')
}

# Only meaningful on ZynqMP (Versal has its own PLM-based flow; not handled here)
COMPATIBLE_MACHINE:append = "|xilinx-zynqmp.*"
