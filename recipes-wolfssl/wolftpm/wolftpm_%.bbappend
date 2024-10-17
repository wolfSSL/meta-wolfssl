# For wolfTPM Examples
WOLFTPM_TEST_DIR = "${S}/examples"
WOLFTPM_DIR = "/home/root/wolftpm/examples"
WOLFTPM_TEST_TARGET_DIR = "${D}${WOLFTPM_DIR}"

python () {
    enable_wolftpm_examples = d.getVar('ENABLE_WOLFTPM_EXAMPLES', True)

    if enable_wolftpm_examples == "1":
        distro_version = d.getVar('DISTRO_VERSION', True)
        wolftpm_test_dir = d.getVar('WOLFTPM_TEST_DIR', True)
        wolftpm_test_target_dir = d.getVar('WOLFTPM_TEST_TARGET_DIR', True)

        bb.note("Installing Examples Directory for wolfTPM")
        installDir = 'install -m 0755 -d "%s"\n' % (wolftpm_test_target_dir)
        cpWolftpmExamples = 'cp -r %s/* %s\n' % (wolftpm_test_dir, wolftpm_test_target_dir)

        d.appendVar('do_install', installDir)
        d.appendVar('do_install', cpWolftpmExamples)

        # Remove the unwanted file
        d.appendVar('do_install', 'rm -f %s/run_examples.sh\n' % wolftpm_test_target_dir)

        # Append to FILES:${PN} within the Python function
        files_var = 'FILES:' + d.getVar('PN', True)
        wolftpm_example_files = wolftpm_test_target_dir + '/*'

        pn = d.getVar('PN', True)
        wolftpm_dir = d.getVar('WOLFTPM_DIR', True)
        if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
            files_var_name = 'FILES_' + pn
        else:
            files_var_name = 'FILES:' + pn    
        
        current_files = d.getVar(files_var_name, True) or ""
        new_files = current_files + ' ' + wolftpm_dir + '/*'
        d.setVar(files_var_name, new_files)
}

# Python Specific option                                                        
export PYTHONDONTWRITEBYTECODE = "1"
