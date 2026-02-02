# wolfSSL Yocto Compatibility Helper Class
# Provides functions to work with both old (underscore) and new (colon) Yocto syntax

def wolfssl_uses_colon_syntax(d):
    """
    Detect if this Yocto version uses colon syntax (Honister 3.4+ / LAYERVERSION_core >= 14).
    Falls back to checking DISTRO_VERSION if LAYERVERSION_core unavailable.
    """
    try:
        # Check OE-Core layer version (most reliable)
        layer_version = d.getVar('LAYERVERSION_core') or d.getVar('LAYERVERSION_core', True)
        if layer_version:
            return int(layer_version) >= 14
    except:
        pass

    # Fallback: check DISTRO_VERSION
    try:
        distro_version = d.getVar('DISTRO_VERSION') or d.getVar('DISTRO_VERSION', True)
        if distro_version:
            # Versions 2.x and 3.x before 3.4 use underscore
            if distro_version.startswith('2.') or distro_version.startswith('3.0') or \
               distro_version.startswith('3.1') or distro_version.startswith('3.2') or \
               distro_version.startswith('3.3'):
                return False
    except:
        pass

    # Default to colon syntax for unknown/newer versions
    return True

def wolfssl_varAppend(d, base_var, package_name, value):
    """
    Appends a value to a package-specific variable, handling both old and new Yocto syntax.

    Args:
        d: BitBake data store
        base_var: Base variable name (e.g., 'RDEPENDS', 'FILES', 'RRECOMMENDS')
        package_name: Package name (e.g., '${PN}')
        value: Value to append
    """
    import bb

    package_name_expanded = d.expand(package_name)

    if wolfssl_uses_colon_syntax(d):
        var_name = base_var + ':' + package_name_expanded
    else:
        var_name = base_var + '_' + package_name_expanded

    d.appendVar(var_name, value)

def wolfssl_varSet(d, base_var, package_name, value):
    """
    Sets a package-specific variable, handling both old and new Yocto syntax.

    Args:
        d: BitBake data store
        base_var: Base variable name (e.g., 'RDEPENDS', 'FILES', 'RRECOMMENDS')
        package_name: Package name (e.g., '${PN}')
        value: Value to set
    """
    import bb

    package_name_expanded = d.expand(package_name)

    if wolfssl_uses_colon_syntax(d):
        var_name = base_var + ':' + package_name_expanded
    else:
        var_name = base_var + '_' + package_name_expanded

    d.setVar(var_name, value)

def wolfssl_varGet(d, base_var, package_name):
    """
    Gets a package-specific variable, handling both old and new Yocto syntax.

    Args:
        d: BitBake data store
        base_var: Base variable name (e.g., 'RDEPENDS', 'FILES', 'RRECOMMENDS')
        package_name: Package name (e.g., '${PN}')

    Returns:
        Variable value or None
    """
    import bb

    package_name_expanded = d.expand(package_name)

    if wolfssl_uses_colon_syntax(d):
        var_name = base_var + ':' + package_name_expanded
    else:
        var_name = base_var + '_' + package_name_expanded

    return d.getVar(var_name) or d.getVar(var_name, True)

def wolfssl_varPrepend(d, var_name, value):
    """
    Prepends a value to a variable (for things like FILESEXTRAPATHS, PACKAGECONFIG).

    Args:
        d: BitBake data store
        var_name: Variable name (e.g., 'FILESEXTRAPATHS', 'PACKAGECONFIG')
        value: Value to prepend
    """
    d.prependVar(var_name, value)

def wolfssl_varAppendNonOverride(d, var_name, value):
    """
    Appends a value to a variable (for things like PACKAGECONFIG, EXTRA_OECONF).

    Args:
        d: BitBake data store
        var_name: Variable name (e.g., 'PACKAGECONFIG', 'EXTRA_OECONF')
        value: Value to append
    """
    d.appendVar(var_name, value)
