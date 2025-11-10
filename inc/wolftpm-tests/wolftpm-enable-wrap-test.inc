# Enable wrap_test installation for wolfTPM
#
# This include file configures wolfTPM to build and install the wrap_test
# example to the target system for testing.

WOLFTPM_TEST_DIR = "${B}/examples/wrap/.libs"
WOLFTPM_TEST = "wrap_test"
WOLFTPM_TEST_YOCTO = "wolftpm-wrap-test"
WOLFTPM_INSTALL_DIR = "${D}${bindir}"

# Configurations (--enable-devtpm is required for the TPM simulator to work)
EXTRA_OECONF += "--enable-devtpm"

python () {
    # Get the environment variables WOLFTPM_TEST_DIR, WOLFTPM_TEST,
    # WOLFTPM_TEST_YOCTO, and WOLFTPM_INSTALL_DIR
    wolftpm_test_dir = d.getVar('WOLFTPM_TEST_DIR', True)
    wolftpm_test = d.getVar('WOLFTPM_TEST', True)
    wolftpm_test_yocto = d.getVar('WOLFTPM_TEST_YOCTO', True)
    wolftpm_install_dir = d.getVar('WOLFTPM_INSTALL_DIR', True)

    installDir = 'install -m 0755 -d "%s"\n' % (wolftpm_install_dir)
    cpWrapTest = 'cp "%s/%s" "%s/%s"\n' % (wolftpm_test_dir, wolftpm_test,
        wolftpm_install_dir, wolftpm_test_yocto)

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpWrapTest)
}

