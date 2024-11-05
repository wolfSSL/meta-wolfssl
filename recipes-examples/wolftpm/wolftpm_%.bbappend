#wolfTPM Examples
WOLFTPM_EXAMPLES_DIR = "${B}/examples"
WOLFTPM_INSTALL_DIR = "${D}${bindir}"

# Bash dependency for .sh
RDEPENDS:${PN} += "bash"

python () {
    # Get the environment variables
    wolftpm_examples_dir = d.getVar('WOLFTPM_EXAMPLES_DIR', True)
    wolftpm_install_dir = d.getVar('WOLFTPM_INSTALL_DIR', True)

    bbnote = 'bbnote "Installing wolfTPM Examples"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (wolftpm_install_dir)
    cpExamples = 'cp -r "%s/" "%s/"\n' % (wolftpm_examples_dir, wolftpm_install_dir)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpExamples)
}

# Ensure consistent locale                                   
export LC_ALL = "C"
