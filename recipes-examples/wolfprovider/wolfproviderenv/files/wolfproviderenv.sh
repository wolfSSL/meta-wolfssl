#!/bin/bash

# This script can be both executed and sourced
# When sourced: Sets up environment variables for other scripts to use
# When executed: Also runs verification tests

# Setup for libwolfprov.so
mkdir -p /usr/lib/ssl-3/modules
if [ ! -L /usr/lib/ssl-3/modules/libwolfprov.so ]; then
    ln -s /usr/lib/libwolfprov.so.0.0.0 /usr/lib/ssl-3/modules/libwolfprov.so
fi

# Environment variables
export OPENSSL_MODULES=/usr/lib/ssl-3/modules
export LD_LIBRARY_PATH=/usr/lib:/lib:$LD_LIBRARY_PATH

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

echo "=========================================="
echo "wolfProvider Environment Setup"
echo "=========================================="
echo ""
echo "Environment Variables:"
echo "  OPENSSL_MODULES: $OPENSSL_MODULES"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "  OPENSSL_CONF: $OPENSSL_CONF"
echo ""

# Test 1: Provider Verification
echo "=========================================="
echo "Test 1: Provider Load Verification"
echo "=========================================="
if wolfproviderverify; then
    echo "Passed!"
else
    echo "Failed!"
    return 1 2>/dev/null || exit 1
fi

# Test 2: Provider List
echo ""
echo "=========================================="
echo "Test 2: OpenSSL Provider List"
echo "=========================================="
openssl list -providers -verbose

echo ""
echo "=========================================="
echo "Environment setup completed."
echo "=========================================="
