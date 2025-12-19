# Configuration to enable wolfProvider unit tests
# Modeled exactly after wolfcrypttest approach - simple and clean

# Set FILESEXTRAPATHS and SRC_URI early using Python to ensure correct evaluation order
python __anonymous() {
    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if not layerdir:
        bb.fatal("WOLFSSL_LAYERDIR not set - ensure meta-wolfssl layer is properly configured")
    
    # Set FILESEXTRAPATHS first, then SRC_URI
    filespath = layerdir + "/recipes-examples/wolfprovider/wolfprovidertest/files:"
    existing_paths = d.getVar('FILESEXTRAPATHS') or ''
    d.setVar('FILESEXTRAPATHS', filespath + existing_paths)
    
    # Add SRC_URI entry
    d.appendVar('SRC_URI', ' file://wolfprovidertest.sh')
}

# Unit test directory and binary names
WOLFPROVIDER_TEST_DIR = "${B}/test/.libs"
WOLFPROVIDER_TEST = "unit.test"
WOLFPROVIDER_TEST_YOCTO = "unit.test"
WOLFPROVIDER_INSTALL_DIR = "${D}${bindir}"
WOLFPROVIDER_CERTS_DIR = "${S}/certs"
WOLFPROVIDER_CERTS_INSTALL_DIR = "${D}${datadir}/wolfprovider-test/certs"

# Override CERTS_DIR to point to the installed location instead of build directory
# First undefine CERTS_DIR (in case autotools defined it), then redefine it
CFLAGS:append = ' -UCERTS_DIR -DCERTS_DIR=\\"/usr/share/wolfprovider-test/certs\\"'
CXXFLAGS:append = ' -UCERTS_DIR -DCERTS_DIR=\\"/usr/share/wolfprovider-test/certs\\"'

# Simple installation using Python function, exactly like wolfcrypttest
python () {
    # Get the environment variables
    test_dir = d.getVar('WOLFPROVIDER_TEST_DIR', True)
    test_bin = d.getVar('WOLFPROVIDER_TEST', True)
    test_yocto = d.getVar('WOLFPROVIDER_TEST_YOCTO', True)
    install_dir = d.getVar('WOLFPROVIDER_INSTALL_DIR', True)
    certs_dir = d.getVar('WOLFPROVIDER_CERTS_DIR', True)
    certs_install_dir = d.getVar('WOLFPROVIDER_CERTS_INSTALL_DIR', True)

    bbnote = 'bbnote "Installing wolfProvider Tests"\n'
    installDir = 'install -m 0755 -d "%s"\n' % (install_dir)
    
    # Try multiple locations for the test binary (exactly like wolfcrypttest)
    cpTest = 'if [ -f "%s/%s" ]; then cp "%s/%s" "%s/%s"; ' % (test_dir, test_bin, test_dir, test_bin, install_dir, test_yocto)
    cpTest += 'elif [ -f "${B}/test/%s" ]; then cp "${B}/test/%s" "%s/%s"; ' % (test_bin, test_bin, install_dir, test_yocto)
    cpTest += 'elif [ -f "${B}/%s" ]; then cp "${B}/%s" "%s/%s"; fi\n' % (test_bin, test_bin, install_dir, test_yocto)
    
    # Install wrapper script
    installScript = 'cp "${WORKDIR}/wolfprovidertest.sh" "%s/wolfprovidertest"\n' % (install_dir)
    installScript += 'chmod 755 "%s/wolfprovidertest"\n' % (install_dir)
    
    # Install certificates
    installCerts = 'bbnote "Installing wolfProvider Certificates"\n'
    installCerts += 'install -m 0755 -d "%s"\n' % (certs_install_dir)
    installCerts += 'if [ -d "%s" ]; then cp -r %s/*.pem %s/ 2>/dev/null || true; fi\n' % (certs_dir, certs_dir, certs_install_dir)

    d.appendVar('do_install', bbnote)
    d.appendVar('do_install', installDir)
    d.appendVar('do_install', cpTest)
    d.appendVar('do_install', installScript)
    d.appendVar('do_install', installCerts)
}

# Append test files and library files to FILES using Python
python __anonymous() {
    pn = d.getVar('PN')
    
    # Get existing FILES value (set by autotools class and base recipe)
    existing_files = d.getVar('FILES:' + pn) or ''
    
    # Append our test files (don't re-add library files - they're in base recipe FILES)
    new_files = existing_files + ' ' + ' '.join([
        '${bindir}/wolfprovidertest',
        '${bindir}/unit.test',
        '${datadir}/wolfprovider-test/certs/*'
    ])
    
    # Set the combined value (this avoids the "replaces original key" warning)
    d.setVar('FILES:' + pn, new_files)
    
    # Same approach for RDEPENDS
    existing_rdepends = d.getVar('RDEPENDS:' + pn) or ''
    new_rdepends = existing_rdepends + ' bash wolfproviderenv'
    d.setVar('RDEPENDS:' + pn, new_rdepends)
    
    # Same approach for INSANE_SKIP
    existing_skip = d.getVar('INSANE_SKIP:' + pn) or ''
    new_skip = existing_skip + ' dev-so build-deps'
    d.setVar('INSANE_SKIP:' + pn, new_skip)
}


