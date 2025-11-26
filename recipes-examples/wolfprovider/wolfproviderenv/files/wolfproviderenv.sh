#!/bin/bash

# This script can be both executed and sourced
# When sourced: Sets up environment variables for other scripts to use
# When executed: Also runs verification tests

REPLACE_DEFAULT_MODE=0
WOLFSSL_FIPS_MODE=0

# Method 1: Check build-time configuration file
if [ -f /etc/wolfprovider/replace-default-mode ]; then
    MODE=$(cat /etc/wolfprovider/replace-default-mode)
    if [ "$MODE" = "1" ]; then
        REPLACE_DEFAULT_MODE=1
        echo "Detected replace-default mode (from config file)"
    else
        echo "Detected normal wolfprovider mode (from config file)"
    fi
else
    # Method 2: Runtime detection by checking default provider
    DEFAULT_PROVIDER=$(openssl list -providers 2>/dev/null | grep -A1 "^  default$" | grep "name:" | grep -i "wolfSSL Provider")
    if [ -n "$DEFAULT_PROVIDER" ]; then
        REPLACE_DEFAULT_MODE=1
        echo "Detected replace-default mode (runtime detection)"
    else
        echo "Detected normal wolfprovider mode (runtime detection)"
    fi
fi

# Setup for libwolfprov.so
mkdir -p /usr/lib/ssl-3/modules
if [ ! -L /usr/lib/ssl-3/modules/libwolfprov.so ]; then
    ln -s /usr/lib/libwolfprov.so.0.0.0 /usr/lib/ssl-3/modules/libwolfprov.so
fi

# Environment variables
export OPENSSL_MODULES=/usr/lib/ssl-3/modules
export LD_LIBRARY_PATH=/usr/lib:/lib:$LD_LIBRARY_PATH

# Method 1: Check build-time configuration file
if [ -f /etc/wolfssl/fips-enabled ]; then
    FIPS_VALUE=$(cat /etc/wolfssl/fips-enabled)
    if [ "$FIPS_VALUE" = "1" ]; then
        WOLFSSL_FIPS_MODE=1
        echo "Detected wolfSSL FIPS build (from config file)"
    else
        echo "Detected wolfSSL non-FIPS build (from config file)"
    fi
else
    # Method 2: Runtime detection (Replace default and FIPS mode)
    DEFAULT_PROVIDER=$(openssl list -providers 2>/dev/null | grep -A1 "^  default$" | grep "name:" | grep -i "wolfSSL Provider FIPS")
    if [ -n "$DEFAULT_PROVIDER" ]; then
        WOLFSSL_FIPS_MODE=1
        echo "Detected wolfSSL FIPS build (runtime detection)"
    else
        echo "Detected wolfSSL non-FIPS build (runtime detection)"
    fi
fi

# Add provider config to openssl.cnf (following Debian convention)
# This allows OpenSSL to automatically load the wolfProvider configuration
if [ "$REPLACE_DEFAULT_MODE" -eq 0 ]; then
    # Only needed in explicit load mode
    OPENSSL_CNF="/etc/ssl/openssl.cnf"
    PROVIDER_INCLUDE=""
    
    if [ "$WOLFSSL_FIPS_MODE" -eq 1 ]; then
        PROVIDER_INCLUDE="/etc/ssl/openssl.cnf.d/wolfprovider-fips.conf"
    else
        PROVIDER_INCLUDE="/etc/ssl/openssl.cnf.d/wolfprovider.conf"
    fi
    
    if [ -f "$OPENSSL_CNF" ] && [ -f "$PROVIDER_INCLUDE" ]; then
        # Check if the include is already present
        if ! grep -q ".include $PROVIDER_INCLUDE" "$OPENSSL_CNF"; then
            echo ".include $PROVIDER_INCLUDE" >> "$OPENSSL_CNF"
            echo "Added provider configuration to $OPENSSL_CNF"
        fi
    fi
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
