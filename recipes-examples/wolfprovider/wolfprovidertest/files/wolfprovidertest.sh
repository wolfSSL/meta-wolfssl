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
    # Create .libs symlink structure in /tmp so the test can find the provider
    mkdir -p /tmp/.libs
    ln -sf /usr/lib/libwolfprov.so.0.0.0 /tmp/.libs/libwolfprov.so 2>/dev/null || true
    
    # Run the test from /tmp where .libs is available
    # The test looks for .libs/libwolfprov.so relative to current directory
    (
        cd /tmp
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

