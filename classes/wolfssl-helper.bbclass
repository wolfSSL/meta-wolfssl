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


def wolfssl_conditional_require_mode(d, package_name, mode, inc_file=None):
    """
    Conditionally include one or more .inc files based on a mode variable and
    WOLFSSL_FEATURES. Supports space-separated modes (e.g., "replace-default
    enable-tests") and a mapping of mode->inc_file so callers can configure
    multiple modes in a single invocation.

    Args:
        d: BitBake datastore
        package_name: Name of the package to check for (e.g., 'wolfprovider')
        mode: Either a string mode name or a dict mapping mode names to
              inc-file paths.
        inc_file: Relative path from layer root to the .inc file (required when
                  'mode' is a single string)

    Returns:
        True if configuration was included, False otherwise

    Example:
        wolfssl_conditional_require_mode(
            d,
            package_name='wolfprovider',
            mode='standalone',
            inc_file='inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc'
        )

        # Multiple modes in one call:
        wolfssl_conditional_require_mode(
            d,
            package_name='wolfprovider',
            mode={
                'standalone': 'inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc',
                'replace-default': 'inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc',
            }
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

    # Normalise callers passing a mapping vs a single mode
    if isinstance(mode, dict):
        mode_map = mode
    else:
        if inc_file is None:
            bb.fatal(f"{package_name}: wolfssl_conditional_require_mode called without inc_file for mode '{mode}'")
        mode_map = {mode: inc_file}

    included_any = False

    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if not layerdir:
        bb.fatal("WOLFSSL_LAYERDIR not set - ensure meta-wolfssl layer is properly configured")

    for single_mode, single_inc in mode_map.items():
        if single_mode not in current_modes:
            bb.debug(2, f"{package_name}: {mode_var_name}='{current_mode_str}' does not contain '{single_mode}' - skipping")
            continue

        bb.note(f"{package_name}: {mode_var_name}='{current_mode_str}' contains '{single_mode}' mode - including {single_inc}")
        full_inc_file = os.path.join(layerdir, single_inc)
        bb.parse.mark_dependency(d, full_inc_file)
        try:
            bb.parse.handle(full_inc_file, d, True)
            included_any = True
        except Exception as e:
            bb.fatal(f"Failed to include {full_inc_file}: {e}")

    return included_any


def wolfssl_conditional_require_flag(d, flag_name, inc_file):
    """
    Conditionally include an .inc file based solely on the current recipe's flags
    variable (derived from PN). Flags are separate from modes - use for opt-in
    features like tests, not OpenSSL configuration.

    Args:
        d: BitBake datastore
        flag_name: The flag to check for (e.g., 'enable-tests')
        inc_file: Relative path from layer root to the .inc file

    Returns:
        True if configuration was included, False otherwise

    Example:
        wolfssl_conditional_require_flag(
            d,
            flag_name='enable-tests',
            inc_file='inc/wolfprovider/wolfprovider-enable-test.inc'
        )

        # Usage in local.conf:
        # WOLFPROVIDER_FLAGS = "enable-tests"  # PN=wolfprovider -> WOLFPROVIDER_FLAGS
    """
    import os
    import bb.parse

    package_name = d.getVar('PN')
    if not package_name:
        bb.fatal("wolfssl_conditional_require_flag called without PN set")

    # Build the flags variable name from the current package name (e.g., wolfprovider -> WOLFPROVIDER_FLAGS)
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
