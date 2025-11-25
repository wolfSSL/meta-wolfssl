# wolfssl-helper.bbclass
#
# This class provides reusable helper functions for wolfSSL packages
# including verification that packages are properly configured
#
# Usage in recipe:
#   inherit wolfssl-helper

def wolfssl_conditional_require(d, package_name, inc_path):
    """
    Conditionally include an .inc file if package is in IMAGE_INSTALL or WOLFSSL_FEATURES
    
    Args:
        d: BitBake datastore
        package_name: Name of the package to check for
        inc_path: Relative path from layer root to the .inc file (e.g., 'inc/wolfclu/wolfssl-enable-wolfclu.inc')
    """
    import os
    import bb.parse
    
    if bb.utils.contains('WOLFSSL_FEATURES', package_name, True, False, d) or \
       bb.utils.contains('IMAGE_INSTALL', package_name, True, False, d):
        # Get the meta-wolfssl layer directory from variable set in layer.conf
        layerdir = d.getVar('WOLFSSL_LAYERDIR')
        inc_file = os.path.join(layerdir, inc_path)
        bb.parse.mark_dependency(d, inc_file)
        bb.parse.handle(inc_file, d, True)


def wolfssl_conditional_require_mode(d, package_name, mode, inc_file):
    """
    Conditionally include an .inc file based on a mode variable and WOLFSSL_FEATURES.
    Supports space-separated modes (e.g., "replace-default enable-tests").
    
    Args:
        d: BitBake datastore
        package_name: Name of the package to check for (e.g., 'wolfprovider')
        mode: The expected mode (e.g., 'standalone' or 'replace-default')
        inc_file: Relative path from layer root to the .inc file
    
    Returns:
        True if configuration was included, False otherwise
    
    Example:
        wolfssl_conditional_require_mode(
            d,
            package_name='wolfprovider',
            mode='standalone',
            inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc'
        )
        
        # Supports multiple modes in WOLFPROVIDER_MODE:
        # WOLFPROVIDER_MODE = "replace-default enable-tests"
    """
    import os
    import bb.parse
    
    # Check if package is enabled
    if not (bb.utils.contains('WOLFSSL_FEATURES', package_name, True, False, d) or \
            bb.utils.contains('IMAGE_INSTALL', package_name, True, False, d)):
        bb.debug(2, f"{package_name} not in WOLFSSL_FEATURES or IMAGE_INSTALL - skipping")
        return False
    
    # Build the mode variable name from package name (e.g., 'wolfprovider' -> 'WOLFPROVIDER_MODE')
    mode_var_name = f"{package_name.upper()}_MODE"
    current_mode_str = d.getVar(mode_var_name) or 'standalone'  # Default to standalone
    
    # Support space-separated modes: split into list and check if expected mode is in the list
    current_modes = [m.strip() for m in current_mode_str.split() if m.strip()]
    
    # Check if expected mode is in the current modes list
    if mode not in current_modes:
        bb.debug(2, f"{package_name}: {mode_var_name}='{current_mode_str}' does not contain '{mode}' - skipping")
        return False
    
    # Mode found in list - include the configuration
    # Show all detected modes for clarity
    bb.note(f"{package_name}: {mode_var_name}='{current_mode_str}' contains '{mode}' mode - including {inc_file}")
    
    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if not layerdir:
        bb.fatal("WOLFSSL_LAYERDIR not set - ensure meta-wolfssl layer is properly configured")
    
    full_inc_file = os.path.join(layerdir, inc_file)
    bb.parse.mark_dependency(d, full_inc_file)
    try:
        bb.parse.handle(full_inc_file, d, True)
        return True
    except Exception as e:
        bb.fatal(f"Failed to include {full_inc_file}: {e}")


def wolfssl_conditional_require_flag(d, package_name, flag_name, inc_file):
    """
    Conditionally include an .inc file based on a flags variable and WOLFSSL_FEATURES.
    Flags are separate from modes - use for features like tests, not OpenSSL configuration.
    
    Args:
        d: BitBake datastore
        package_name: Name of the package to check for (e.g., 'wolfprovider')
        flag_name: The flag to check for (e.g., 'enable-tests')
        inc_file: Relative path from layer root to the .inc file
    
    Returns:
        True if configuration was included, False otherwise
    
    Example:
        wolfssl_conditional_require_flag(
            d,
            package_name='wolfprovider',
            flag_name='enable-tests',
            inc_file='inc/wolfprovider/wolfprovider-enable-test.inc'
        )
        
        # Usage in local.conf:
        # WOLFPROVIDER_FLAGS = "enable-tests"  # Can be space-separated: "enable-tests other-flag"
    """
    import os
    import bb.parse
    
    # Check if package is enabled
    if not (bb.utils.contains('WOLFSSL_FEATURES', package_name, True, False, d) or \
            bb.utils.contains('IMAGE_INSTALL', package_name, True, False, d)):
        bb.debug(2, f"{package_name} not in WOLFSSL_FEATURES or IMAGE_INSTALL - skipping")
        return False
    
    # Build the flags variable name from package name (e.g., 'wolfprovider' -> 'WOLFPROVIDER_FLAGS')
    flags_var_name = f"{package_name.upper()}_FLAGS"
    current_flags_str = d.getVar(flags_var_name) or ''
    
    # Support space-separated flags: split into list and check if expected flag is in the list
    current_flags = [f.strip() for f in current_flags_str.split() if f.strip()]
    
    # Check if expected flag is in the current flags list
    if flag_name not in current_flags:
        bb.debug(2, f"{package_name}: {flags_var_name}='{current_flags_str}' does not contain '{flag_name}' - skipping")
        return False
    
    # Flag found in list - include the configuration
    bb.note(f"{package_name}: {flags_var_name}='{current_flags_str}' contains '{flag_name}' flag - including {inc_file}")
    
    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if not layerdir:
        bb.fatal("WOLFSSL_LAYERDIR not set - ensure meta-wolfssl layer is properly configured")
    
    full_inc_file = os.path.join(layerdir, inc_file)
    bb.parse.mark_dependency(d, full_inc_file)
    try:
        bb.parse.handle(full_inc_file, d, True)
        return True
    except Exception as e:
        bb.fatal(f"Failed to include {full_inc_file}: {e}")

python do_wolfssl_check_package() {
    """
    Task to check if package is enabled via IMAGE_INSTALL or WOLFSSL_FEATURES
    Only runs when recipe is actually being built
    """
    package_name = d.getVar('PN')
    image_install = d.getVar('IMAGE_INSTALL') or ''
    wolfssl_features = d.getVar('WOLFSSL_FEATURES') or ''
    
    # Check if this package is in either IMAGE_INSTALL or WOLFSSL_FEATURES
    if package_name not in image_install and package_name not in wolfssl_features:
        bb.fatal("%s requires either:\n" \
                 "  - '%s' in IMAGE_INSTALL, or\n" \
                 "  - 'WOLFSSL_FEATURES = \"%s\"' in local.conf\n" \
                 "to ensure wolfSSL is built with proper support." % (package_name, package_name, package_name))
}

# Add the check task before configure
addtask wolfssl_check_package before do_configure after do_fetch

python() {
    distro_version = d.getVar('DISTRO_VERSION', True)
    autogen_command = 'cd ${S}; if [ -f ${S}/autogen.sh ]; then ./autogen.sh; fi'
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        # For Dunfell and earlier
        d.appendVar('do_configure_prepend', autogen_command)
    else:
        # For Kirkstone and later
        d.appendVar('do_configure:prepend', autogen_command)
}
