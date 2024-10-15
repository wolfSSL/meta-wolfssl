# For wolfTPM Examples
WOLFTPM_DIR = "${S}/examples"
WOLFTPM_TARGET_DIR = "/home/root/wolftpm/examples"
WOLFTPM_TEST_TARGET_DIR = "${D}${WOLFTPM_TARGET_DIR}"

python () {
    distro_version = d.getVar('DISTRO_VERSION', True)
    wolftpm_dir = d.getVar('WOLFTPM_DIR', True)
    wolftpm_test_target_dir = d.getVar('WOLFTPM_TEST_TARGET_DIR', True)

    bb.note("Installing Examples Directory for wolfTPM")
    installDir = 'install -m 0755 -d "%s"\n' % (wolftpm_test_target_dir)
    cpWolftpmExamples = 'cp -r %s/* %s\n' % (wolftpm_dir, wolftpm_test_target_dir)

    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpWolftpmExamples)

    # Append to FILES:${PN} within the Python function
    files_var = 'FILES:' + d.getVar('PN', True)
    wolftpm_example_files = wolftpm_test_target_dir + '/*'

    pn = d.getVar('PN', True)
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        files_var_name = 'FILES_' + pn
    else:
        files_var_name = 'FILES:' + pn    
    
    current_files = d.getVar(files_var_name, True) or ""
    new_files = current_files + ' ' + wolftpm_example_files
    d.setVar(files_var_name, new_files)
}

# Python Specific option                                                        
export PYTHONDONTWRITEBYTECODE = "1"
