#!/bin/bash

# This script can be both executed and sourced
# When sourced: Sets up environment variables for other scripts to use
# When executed: Also runs verification tests

# Detect if wolfProvider is in replace-default mode
REPLACE_DEFAULT_MODE=0

# Method 1: Check build-time configuration file
if [ -f /etc/wolfprovider/replace-default-mode ]; then
    MODE=$(cat /etc/wolfprovider/replace-default-mode)
    if [ "$MODE" = "1" ]; then
        REPLACE_DEFAULT_MODE=1
        echo "Detected replace-default mode (from config file)"
    fi
else
    # Method 2: Runtime detection by checking default provider
    DEFAULT_PROVIDER=$(openssl list -providers 2>/dev/null | grep -A1 "^  default$" | grep "name:" | grep -i "wolfSSL Provider")
    if [ -n "$DEFAULT_PROVIDER" ]; then
        REPLACE_DEFAULT_MODE=1
        echo "Detected replace-default mode (runtime detection)"
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

# Only create explicit provider config if NOT in replace-default mode
if [ "$REPLACE_DEFAULT_MODE" -eq 0 ]; then
    # Configuration for wolfprovider
    mkdir -p /opt/wolfprovider-configs
    cat > /opt/wolfprovider-configs/wolfprovider.conf <<EOF
openssl_conf = openssl_init

[openssl_init]
providers = provider_sect

[provider_sect]
libwolfprov = libwolfprov_sect

[libwolfprov_sect]
activate = 1
EOF

    export OPENSSL_CONF="/opt/wolfprovider-configs/wolfprovider.conf"
else
    echo "Skipping explicit provider load (replace-default mode active)"
fi

echo "=========================================="
echo "wolfProvider Environment Setup"
echo "=========================================="
echo ""
if [ "$REPLACE_DEFAULT_MODE" -eq 1 ]; then
    echo "Mode: Replace-Default (wolfProvider is the default provider)"
else
    echo "Mode: Explicit Load (using OPENSSL_CONF)"
fi
echo ""
echo "Environment Variables:"
echo "  OPENSSL_MODULES: $OPENSSL_MODULES"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "  OPENSSL_CONF: ${OPENSSL_CONF:-(unset - using system default)}"
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
