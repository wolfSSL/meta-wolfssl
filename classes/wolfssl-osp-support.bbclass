# wolfSSL Open Source Package Support Class
#
# This class provides helper functions for conditionally enabling wolfSSL backends
# in open source packages (like libgcrypt, OpenSSH, etc.)
#
# Usage Examples:
#
# Example 1: Package that only works with FIPS (like libgcrypt)
#   inherit wolfssl-osp-support
#   
#   python __anonymous() {
#       wolfssl_osp_conditional_include(
#           d,
#           feature_name='libgcrypt',
#           inc_file='recipes-support/libgcrypt/libgcrypt-enable-wolfssl.inc',
#           allowed_providers=['wolfssl-fips']  # FIPS only
#       )
#   }
#
# Example 2: Package that works with both standard and FIPS (hypothetical)
#   inherit wolfssl-osp-support
#   
#   python __anonymous() {
#       wolfssl_osp_conditional_include(
#           d,
#           feature_name='openssh',
#           inc_file='recipes-connectivity/openssh/openssh-enable-wolfssl.inc',
#           allowed_providers=['wolfssl', 'wolfssl-fips']  # Both supported
#       )
#   }
#
# Example 3: Package that only works with standard wolfSSL (hypothetical)
#   inherit wolfssl-osp-support
#   
#   python __anonymous() {
#       wolfssl_osp_conditional_include(
#           d,
#           feature_name='curl',
#           inc_file='recipes-support/curl/curl-enable-wolfssl.inc',
#           allowed_providers=['wolfssl']  # Standard only
#       )
#   }

def wolfssl_osp_conditional_include(d, feature_name, inc_file, allowed_providers=None):
    """
    Conditionally include a configuration file based on WOLFSSL_FEATURES and provider.
    
    Args:
        d: BitBake datastore
        feature_name: Name to check in WOLFSSL_FEATURES (e.g., 'libgcrypt')
        inc_file: Relative path to .inc file from layer root
        allowed_providers: List of allowed providers (e.g., ['wolfssl', 'wolfssl-fips'])
                          If None, defaults to ['wolfssl', 'wolfssl-fips']
    
    Returns:
        True if configuration was included, False otherwise
    """
    import os
    
    # Default to allowing both providers if not specified
    if allowed_providers is None:
        allowed_providers = ['wolfssl', 'wolfssl-fips']
    
    # Check if feature is explicitly enabled in WOLFSSL_FEATURES
    wolfssl_features = d.getVar('WOLFSSL_FEATURES') or ''
    feature_enabled = feature_name in wolfssl_features.split()
    
    if not feature_enabled:
        bb.debug(2, f"{feature_name} not in WOLFSSL_FEATURES - skipping wolfSSL backend")
        return False
    
    # Check current provider
    current_provider = d.getVar('PREFERRED_PROVIDER_virtual/wolfssl') or 'wolfssl'
    
    # Check if current provider is in the allowed list
    if current_provider not in allowed_providers:
        bb.note(f"{feature_name}: PREFERRED_PROVIDER is '{current_provider}', but only {allowed_providers} are supported - skipping wolfSSL backend")
        return False
    
    # Both conditions met - include the configuration
    bb.note(f"{feature_name}: WOLFSSL_FEATURES enabled + provider '{current_provider}' allowed - enabling wolfSSL backend")
    
    # Resolve full path to include file
    layer_dir = d.getVar('WOLFSSL_LAYERDIR')
    if not layer_dir:
        bb.fatal("WOLFSSL_LAYERDIR not set - ensure meta-wolfssl layer is properly configured")
    
    full_inc_file = os.path.join(layer_dir, inc_file)
    
    # Include the configuration file
    try:
        bb.parse.handle(full_inc_file, d, include=True)
        bb.debug(1, f"Successfully included {full_inc_file}")
        return True
    except FileNotFoundError:
        bb.fatal(f"Configuration file not found: {full_inc_file}")
    except Exception as e:
        bb.fatal(f"Failed to include {full_inc_file}: {e}")
    
    return False

def wolfssl_osp_check_provider(d, allowed_providers=None):
    """
    Check if the current wolfSSL provider is in the allowed list.
    
    Args:
        d: BitBake datastore
        allowed_providers: List of allowed providers
    
    Returns:
        Current provider if allowed, None otherwise
    """
    if allowed_providers is None:
        allowed_providers = ['wolfssl', 'wolfssl-fips']
    
    current_provider = d.getVar('PREFERRED_PROVIDER_virtual/wolfssl') or 'wolfssl'
    
    if current_provider in allowed_providers:
        return current_provider
    
    return None

def wolfssl_osp_check_feature(d, feature_name):
    """
    Check if a feature is enabled in WOLFSSL_FEATURES.
    
    Args:
        d: BitBake datastore
        feature_name: Name to check in WOLFSSL_FEATURES
    
    Returns:
        True if enabled, False otherwise
    """
    wolfssl_features = d.getVar('WOLFSSL_FEATURES') or ''
    return feature_name in wolfssl_features.split()

def wolfssl_osp_include_if_provider(d, inc_file, allowed_providers):
    """
    Include a configuration file if the current provider is in the allowed list.
    Used for image-specific configurations without WOLFSSL_FEATURES check.
    
    Args:
        d: BitBake datastore
        inc_file: Relative path to .inc file from layer root
        allowed_providers: List of allowed providers (e.g., ['wolfssl-fips'])
    
    Returns:
        True if configuration was included, False otherwise
    """
    import os
    
    # Check current provider
    current_provider = d.getVar('PREFERRED_PROVIDER_virtual/wolfssl') or 'wolfssl'
    
    # Check if current provider is in the allowed list
    if current_provider not in allowed_providers:
        bb.debug(2, f"Current provider '{current_provider}' not in {allowed_providers} - skipping configuration")
        return False
    
    bb.note(f"Provider '{current_provider}' matches - including {inc_file}")
    
    # Resolve full path to include file
    layer_dir = d.getVar('WOLFSSL_LAYERDIR')
    if not layer_dir:
        bb.fatal("WOLFSSL_LAYERDIR not set - ensure meta-wolfssl layer is properly configured")
    
    full_inc_file = os.path.join(layer_dir, inc_file)
    
    # Include the configuration file
    try:
        bb.parse.handle(full_inc_file, d, include=True)
        bb.debug(1, f"Successfully included {full_inc_file}")
        return True
    except FileNotFoundError:
        bb.fatal(f"Configuration file not found: {full_inc_file}")
    except Exception as e:
        bb.fatal(f"Failed to include {full_inc_file}: {e}")
    
    return False

