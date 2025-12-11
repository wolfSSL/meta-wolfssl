#!/bin/bash

# This script can be both executed and sourced
# When sourced: Sets up environment variables for other scripts to use
# When executed: Also runs verification tests

REPLACE_DEFAULT_MODE=0
STANDALONE_MODE=0
WOLFSSL_FIPS_MODE=0
NON_FIPS_MODE=0

# Setup for libwolfprov.so (needed before runtime detection)
mkdir -p /usr/lib/ssl-3/modules
if [ ! -L /usr/lib/ssl-3/modules/libwolfprov.so ]; then
    ln -s /usr/lib/libwolfprov.so.0.0.0 /usr/lib/ssl-3/modules/libwolfprov.so
fi

# Environment variables (needed before runtime detection)
export OPENSSL_MODULES=/usr/lib/ssl-3/modules
export LD_LIBRARY_PATH=/usr/lib:/lib:$LD_LIBRARY_PATH

# Method 1: Runtime detection by checking default provider
DEFAULT_PROVIDER=$(openssl list -providers 2>/dev/null | grep -A1 "^  default$" \
| grep "name:" | grep -i "wolfSSL Provider")
if [ -n "$DEFAULT_PROVIDER" ]; then
    REPLACE_DEFAULT_MODE=$((REPLACE_DEFAULT_MODE + 1))
    echo "Detected replace-default mode (runtime detection)"
else
    STANDALONE_MODE=$((STANDALONE_MODE + 1))
    echo "Detected normal wolfprovider mode (runtime detection)"
fi
# Method 2: Check build-time configuration file
if [ -f /etc/openssl/replace-default-enabled ]; then
    MODE=$(cat /etc/openssl/replace-default-enabled)
    if [ "$MODE" = "1" ]; then
        REPLACE_DEFAULT_MODE=$((REPLACE_DEFAULT_MODE + 1))
        echo "Detected replace-default mode (from config file)"
    else
        STANDALONE_MODE=$((STANDALONE_MODE + 1))
        echo "Detected normal wolfprovider mode (from config file)"
    fi
else
    echo "No config file found, using runtime detection"
fi
# Verify consistency and report
if [ "$REPLACE_DEFAULT_MODE" -eq 2 ]; then
    REPLACE_DEFAULT_MODE=1
    echo "Detected replace-default mode"
elif [ "$STANDALONE_MODE" -eq 2 ]; then
    REPLACE_DEFAULT_MODE=0
    echo "Detected normal wolfprovider mode"
elif [ "$REPLACE_DEFAULT_MODE" -eq 1 ] && [ "$STANDALONE_MODE" -eq 1 ]; then
    echo "WARNING: Config file and runtime detection are inconsistent!"
    echo "  Runtime: $([ "$REPLACE_DEFAULT_MODE" -eq 1 ] && echo 'replace-default' || echo 'normal')"
    echo "  Config file: $([ "$STANDALONE_MODE" -eq 1 ] && echo 'normal' || echo 'replace-default')"
    echo "  Using runtime detection"
    REPLACE_DEFAULT_MODE=1
    STANDALONE_MODE=0
fi

# Method 1: Runtime detection (Replace default and FIPS mode)
DEFAULT_PROVIDER=$(openssl list -providers 2>/dev/null | grep -A1 "^  default$" \
| grep "name:" | grep -i "wolfSSL Provider FIPS")
if [ -n "$DEFAULT_PROVIDER" ]; then
    WOLFSSL_FIPS_MODE=$((WOLFSSL_FIPS_MODE + 1))
    echo "Detected wolfSSL FIPS build (runtime detection)"
else
    NON_FIPS_MODE=$((NON_FIPS_MODE + 1))
    echo "Detected wolfSSL non-FIPS build (runtime detection)"
fi
# Method 2: Check build-time configuration file
if [ -f /etc/wolfssl/fips-enabled ]; then
    FIPS_VALUE=$(cat /etc/wolfssl/fips-enabled)
    if [ "$FIPS_VALUE" = "1" ]; then
        WOLFSSL_FIPS_MODE=$((WOLFSSL_FIPS_MODE + 1))
        echo "Detected wolfSSL FIPS build (from config file)"
    else
        NON_FIPS_MODE=$((NON_FIPS_MODE + 1))
        echo "Detected wolfSSL non-FIPS build (from config file)"
    fi
else
    echo "No config file found, using runtime detection"
fi
# Verify consistency and report
if [ "$WOLFSSL_FIPS_MODE" -eq 2 ]; then
    WOLFSSL_FIPS_MODE=1
    echo "Detected wolfSSL FIPS build"
elif [ "$NON_FIPS_MODE" -eq 2 ]; then
    WOLFSSL_FIPS_MODE=0
    echo "Detected wolfSSL non-FIPS build"
elif [ "$WOLFSSL_FIPS_MODE" -eq 1 ] && [ "$NON_FIPS_MODE" -eq 1 ]; then
    echo "WARNING: Config file and runtime detection are inconsistent!"
    echo "  Runtime: $([ "$WOLFSSL_FIPS_MODE" -eq 1 ] && echo 'wolfSSL FIPS' || echo 'wolfSSL non-FIPS')"
    echo "  Config file: $([ "$NON_FIPS_MODE" -eq 1 ] && echo 'wolfSSL non-FIPS' || echo 'wolfSSL FIPS')"
    echo "  Using runtime detection"
    WOLFSSL_FIPS_MODE=1
    NON_FIPS_MODE=0
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
