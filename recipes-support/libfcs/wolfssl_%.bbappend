# Altera Agilex 5 SDM crypto offload; needs an FCS provisioned device at
# runtime. GSRD stacks that already build the library can point this at
# their own recipe, e.g. WOLFSSL_FCS_PROVIDER = "gsrd-intel-fcs-lib".

def wolfssl_fcs_is_target(d):
    return (d.getVar('CLASSOVERRIDE') == 'class-target' and
            (d.getVar('HOST_SYS') or '').startswith('aarch64-'))

WOLFSSL_FCS_CONFIGURE = "${@'--enable-alterafcs --enable-aesctr' if wolfssl_fcs_is_target(d) else ''}"
WOLFSSL_FCS_DEPENDS = "${@d.getVar('WOLFSSL_FCS_PROVIDER') if wolfssl_fcs_is_target(d) else ''}"

EXTRA_OECONF += "${WOLFSSL_FCS_CONFIGURE}"
DEPENDS += "${WOLFSSL_FCS_DEPENDS}"

python () {
    if (d.getVar('CLASSOVERRIDE') == 'class-target' and
            not d.getVar('MLPREFIX') and
            not (d.getVar('HOST_SYS') or '').startswith('aarch64-')):
        bb.fatal('WOLFSSL_ALTERA_FCS requires an AArch64 target')
}
