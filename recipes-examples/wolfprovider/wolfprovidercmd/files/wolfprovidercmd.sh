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
echo "wolfProvider Command-Line Tests"
echo "=========================================="
if [ -f /usr/share/wolfprovider-cmd-tests/scripts/cmd_test/do-cmd-tests.sh ]; then
    echo "Running command-line test suite..."
    echo ""

    # Set environment for cmd tests - use system-wide installations
    export WOLFSSL_ISFIPS=1 # openssl built without cfb which fips also is
    export OPENSSL_BIN=$(which openssl)
    export WOLFPROV_PATH=/usr/lib/ssl-3/modules
    export WOLFPROV_CONFIG=/opt/wolfprovider-configs/wolfprovider.conf

    # Set library paths for system-wide OpenSSL/wolfSSL
    export LD_LIBRARY_PATH=/usr/lib:/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/share/pkgconfig:$PKG_CONFIG_PATH

    # Prevent env-setup from trying to find build directories
    export OPENSSL_DIR=/usr
    export WOLFSSL_DIR=/usr

    # Change to test directory and run
    (
        cd /usr/share/wolfprovider-cmd-tests/scripts/cmd_test
        bash ./do-cmd-tests.sh
    )
    CMD_TEST_RESULT=$?

    echo ""
    echo "=========================================="
    if [ $CMD_TEST_RESULT -eq 0 ]; then
        echo "✓ Command-line tests PASSED!"
    else
        echo "✗ Command-line tests FAILED! (exit code: $CMD_TEST_RESULT)"
        exit $CMD_TEST_RESULT
    fi
else
    echo "Command-line test suite not found at
    /usr/share/wolfprovider-cmd-tests/scripts/cmd_test/do-cmd-tests.sh"
    exit 1
fi

echo "=========================================="
