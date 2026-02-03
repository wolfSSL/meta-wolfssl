#!/bin/bash

# This script can be both executed and sourced
# When sourced: Sets up environment variables for other scripts to use
# When executed: Also runs verification tests

REPLACE_DEFAULT_MODE=0
WOLFSSL_FIPS_MODE=0

# Environment variables (needed before runtime detection)
export OPENSSL_MODULES=/usr/lib/ssl-3/modules
export LD_LIBRARY_PATH=/usr/lib:/lib:$LD_LIBRARY_PATH

# Method 1: Check config file for replace-default mode
CONFIG_REPLACE_DEFAULT=-1
if [ -f /etc/openssl/replace-default-enabled ]; then
    MODE=$(cat /etc/openssl/replace-default-enabled)
    if [ "$MODE" = "1" ]; then
        CONFIG_REPLACE_DEFAULT=1
        echo "Detected replace-default mode (from config file)"
    else
        CONFIG_REPLACE_DEFAULT=0
        echo "Detected normal wolfprovider mode (from config file)"
    fi
fi
# Method 2: Check runtime detection for replace-default mode
RUNTIME_REPLACE_DEFAULT=-1
DEFAULT_PROVIDER_RD=$(openssl list -providers 2>/dev/null | grep -A1 "^  default$" \
| grep "name:" | grep -i "wolfSSL Provider")
if [ -n "$DEFAULT_PROVIDER_RD" ]; then
    RUNTIME_REPLACE_DEFAULT=1
    echo "Detected replace-default mode (runtime detection)"
else
    RUNTIME_REPLACE_DEFAULT=0
    echo "Detected normal wolfprovider mode (runtime detection)"
fi

# Verify both config file and runtime detection for replace-default mode
if [ "$CONFIG_REPLACE_DEFAULT" -ne -1 ] && [ "$RUNTIME_REPLACE_DEFAULT" -ne -1 ]; then
    if [ "$CONFIG_REPLACE_DEFAULT" -eq "$RUNTIME_REPLACE_DEFAULT" ]; then
        REPLACE_DEFAULT_MODE=$CONFIG_REPLACE_DEFAULT
        if [ "$REPLACE_DEFAULT_MODE" -eq 1 ]; then
            echo "Detected replace-default mode (config and runtime agree)"
        else
            echo "Detected normal wolfprovider mode (config and runtime agree)"
        fi
    else
        echo "WARNING: Config file and runtime detection are inconsistent!"
        echo "  Config file: $([ "$CONFIG_REPLACE_DEFAULT" -eq 1 ] && echo 'replace-default' || echo 'normal')"
        echo "  Runtime: $([ "$RUNTIME_REPLACE_DEFAULT" -eq 1 ] && echo 'replace-default' || echo 'normal')"
        echo "  Using runtime detection as source of truth"
        REPLACE_DEFAULT_MODE=$RUNTIME_REPLACE_DEFAULT
    fi
elif [ "$CONFIG_REPLACE_DEFAULT" -ne -1 ]; then
    REPLACE_DEFAULT_MODE=$CONFIG_REPLACE_DEFAULT
    if [ "$REPLACE_DEFAULT_MODE" -eq 1 ]; then
        echo "Detected replace-default mode (from config file only)"
    else
        echo "Detected normal wolfprovider mode (from config file only)"
    fi
elif [ "$RUNTIME_REPLACE_DEFAULT" -ne -1 ]; then
    REPLACE_DEFAULT_MODE=$RUNTIME_REPLACE_DEFAULT
    if [ "$REPLACE_DEFAULT_MODE" -eq 1 ]; then
        echo "Detected replace-default mode (from runtime detection only)"
    else
        echo "Detected normal wolfprovider mode (from runtime detection only)"
    fi
fi

# Method 1: Check config file for FIPS mode
CONFIG_FIPS=-1
if [ -f /etc/wolfssl/fips-enabled ]; then
    FIPS_VALUE=$(cat /etc/wolfssl/fips-enabled)
    if [ "$FIPS_VALUE" = "1" ]; then
        CONFIG_FIPS=1
        echo "Detected wolfSSL FIPS build (from config file)"
    else
        CONFIG_FIPS=0
        echo "Detected wolfSSL non-FIPS build (from config file)"
    fi
fi
# Method 2: Check runtime detection for FIPS mode
RUNTIME_FIPS=-1
PROVIDER_FIPS=$(openssl list -providers 2>/dev/null | grep "name:" | grep -i "wolfSSL Provider FIPS")
if [ -n "$PROVIDER_FIPS" ]; then
    RUNTIME_FIPS=1
    echo "Detected wolfSSL FIPS build (runtime detection)"
else
    RUNTIME_FIPS=0
    echo "Detected wolfSSL non-FIPS build (runtime detection)"
fi

# Verify both config file and runtime detection for FIPS mode
if [ "$CONFIG_FIPS" -ne -1 ] && [ "$RUNTIME_FIPS" -ne -1 ]; then
    if [ "$CONFIG_FIPS" -eq "$RUNTIME_FIPS" ]; then
        WOLFSSL_FIPS_MODE=$CONFIG_FIPS
        if [ "$WOLFSSL_FIPS_MODE" -eq 1 ]; then
            echo "Detected wolfSSL FIPS build (config and runtime agree)"
        else
            echo "Detected wolfSSL non-FIPS build (config and runtime agree)"
        fi
    else
        echo "WARNING: Config file and runtime detection are inconsistent for FIPS!"
        echo "  Config file: $([ "$CONFIG_FIPS" -eq 1 ] && echo 'FIPS' || echo 'non-FIPS')"
        echo "  Runtime: $([ "$RUNTIME_FIPS" -eq 1 ] && echo 'FIPS' || echo 'non-FIPS')"
        echo "  Using runtime detection as source of truth"
        WOLFSSL_FIPS_MODE=$RUNTIME_FIPS
    fi
elif [ "$CONFIG_FIPS" -ne -1 ]; then
    WOLFSSL_FIPS_MODE=$CONFIG_FIPS
    if [ "$WOLFSSL_FIPS_MODE" -eq 1 ]; then
        echo "Detected wolfSSL FIPS build (from config file only)"
    else
        echo "Detected wolfSSL non-FIPS build (from config file only)"
    fi
elif [ "$RUNTIME_FIPS" -ne -1 ]; then
    WOLFSSL_FIPS_MODE=$RUNTIME_FIPS
    if [ "$WOLFSSL_FIPS_MODE" -eq 1 ]; then
        echo "Detected wolfSSL FIPS build (from runtime detection only)"
    else
        echo "Detected wolfSSL non-FIPS build (from runtime detection only)"
    fi
fi

# Determine the provider config file to use
if [ "$WOLFSSL_FIPS_MODE" -eq 1 ]; then
    PROVIDER_CONF="/etc/ssl/openssl.cnf.d/wolfprovider-fips.conf"
else
    PROVIDER_CONF="/etc/ssl/openssl.cnf.d/wolfprovider.conf"
fi

# In standalone mode, we need to load the provider config
if [ "$REPLACE_DEFAULT_MODE" -eq 0 ]; then
    # Determine the OpenSSL config file path
    if [ -n "$OPENSSL_CONF" ]; then
        OPENSSL_CNF="$OPENSSL_CONF"
    elif [ -f "/etc/ssl/openssl.cnf" ]; then
        OPENSSL_CNF="/etc/ssl/openssl.cnf"
    elif [ -f "/usr/lib/ssl-3/openssl.cnf" ]; then
        OPENSSL_CNF="/usr/lib/ssl-3/openssl.cnf"
    else
        OPENSSL_CNF="/etc/ssl/openssl.cnf"
    fi

    # Copy provider config to openssl.cnf if both files exist and are different
    if [ -f "$PROVIDER_CONF" ] && [ -f "$OPENSSL_CNF" ]; then
        if ! cmp -s "$PROVIDER_CONF" "$OPENSSL_CNF"; then
            cp "$PROVIDER_CONF" "$OPENSSL_CNF"
            echo "Replaced $OPENSSL_CNF with wolfProvider configuration ($PROVIDER_CONF)"
        fi
    elif [ -f "$PROVIDER_CONF" ] && [ ! -f "$OPENSSL_CNF" ]; then
        echo "Warning: $OPENSSL_CNF not found, cannot load wolfProvider configuration"
    fi

    # Export OPENSSL_CONF to ensure OpenSSL uses the correct config
    export OPENSSL_CONF="$OPENSSL_CNF"
fi

echo "=========================================="
echo "wolfProvider Environment Setup"
echo "=========================================="
echo ""
if [ "$REPLACE_DEFAULT_MODE" -eq 1 ]; then
    echo "Mode: Replace-Default (wolfProvider is the default provider)"
else
    echo "Mode: Explicit Load (provider config included in openssl.cnf)"
fi
echo ""
if [ "$WOLFSSL_FIPS_MODE" -eq 1 ]; then
    echo "FIPS Mode: Enabled (wolfSSL FIPS)"
else
    echo "FIPS Mode: Disabled (wolfSSL non-FIPS)"
fi
echo ""
echo "Environment Variables:"
echo "  OPENSSL_MODULES: $OPENSSL_MODULES"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo ""

# Test 1: Provider Verification
echo "=========================================="
echo "Test 1: Provider Load Verification"
echo "=========================================="
if [ "$REPLACE_DEFAULT_MODE" -eq 1 ]; then
    # In replace-default mode, just verify the default provider is wolfSSL
    if openssl list -providers | grep -q "wolfSSL Provider"; then
        echo "Default provider is wolfSSL Provider"
        echo "Passed!"
    else
        echo "Failed - default provider is not wolfSSL Provider"
        return 1 2>/dev/null || exit 1
    fi
else
    # In explicit load mode, test explicit provider loading
    if wolfproviderverify; then
        echo "Passed!"
    else
        echo "Failed!"
        return 1 2>/dev/null || exit 1
    fi
fi

# Test 2: Provider List
echo ""
echo "=========================================="
echo "Test 2: OpenSSL Provider List"
echo "=========================================="
openssl list -providers -verbose

# Test 3: OpenSSL Version
echo ""
echo "=========================================="
echo "Test 3: OpenSSL Version"
echo "=========================================="
openssl version -a

echo ""
echo "=========================================="
echo "Environment setup completed."
echo "=========================================="
