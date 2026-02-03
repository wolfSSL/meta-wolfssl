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

echo "=========================================="
echo "Running wolfProvider Unit Test"
echo "=========================================="
if [ -f /usr/bin/unit.test ]; then
    # Use a temp directory for the tests because they expect .libs to be present
    mkdir -p /tmp/.libs

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
