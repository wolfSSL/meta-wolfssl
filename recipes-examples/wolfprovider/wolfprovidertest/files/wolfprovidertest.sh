#!/bin/bash

echo "Setting up environment..."
if [ -f /usr/bin/wolfproviderenv ]; then
    source /usr/bin/wolfproviderenv
    if [ $? -ne 0 ]; then
        echo "✗ Failed to source environment setup!"
        exit 1
    fi
else
    echo "✗ wolfproviderenv not found!"
    exit 1
fi

if [ -f /etc/openssl/replace-default-enabled ]; then
    MODE=$(cat /etc/openssl/replace-default-enabled)
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

if [ "${REPLACE_DEFAULT_MODE:-0}" -eq 1 ]; then
    echo "wolfProvider unit tests are disabled in replace-default mode."
    echo "Skipping test execution until Replace Default mode is supported."
    exit 0
fi

echo "=========================================="
echo "Running wolfProvider Unit Test"
echo "=========================================="
if [ -f /usr/bin/unit.test ]; then
    # Create .libs symlink structure in /tmp so the test can find the provider
    mkdir -p /tmp/.libs
    ln -sf /usr/lib/libwolfprov.so.0.0.0 /tmp/.libs/libwolfprov.so 2>/dev/null || true
    
    # Verify certificates are installed (CERTS_DIR is compiled to point here)
    echo "Verifying test certificates..."
    if [ -d /usr/share/wolfprovider-test/certs ]; then
        echo "Certificates found at /usr/share/wolfprovider-test/certs:"
        ls -la /usr/share/wolfprovider-test/certs/
    else
        echo "Warning: Certificate directory not found at /usr/share/wolfprovider-test/certs"
    fi
    echo ""
    
    # Run the test from /tmp where .libs is available
    # CERTS_DIR is compiled to point to /usr/share/wolfprovider-test/certs
    (
        cd /tmp
        echo "Running unit tests from: $(pwd)"
        echo "Checking for .libs directory:"
        ls -la .libs/ 2>/dev/null || echo "ERROR: .libs directory not found!"
        echo ""
        unit.test
    )
    TEST_RESULT=$?
    
    echo ""
    echo "=========================================="
    if [ $TEST_RESULT -eq 0 ]; then
        echo "✓ Unit tests PASSED!"
    else
        echo "✗ Unit tests FAILED! (exit code: $TEST_RESULT)"
        exit $TEST_RESULT
    fi
else
    echo "Unit test binary not found at /usr/bin/unit.test"
    exit 1
fi

echo "=========================================="
