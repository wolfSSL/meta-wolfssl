#!/bin/bash

# Setup for libwolfprov.so
mkdir -p /usr/lib/ssl-1.1/engines
if [ ! -L /usr/lib/ssl-1.1/engines/libwolfprov.so ]; then
    ln -s /usr/lib/libwolfengine.so.1.0.4 /usr/lib/ssl-1.1/engines/libwolfengine.so
fi

# Environment variables
export OPENSSL_ENGINES=/usr/lib/ssl-1.1/engines
export LD_LIBRARY_PATH=/usr/lib:/lib:$LD_LIBRARY_PATH

echo "Programmatic Test"
if wolfenginetest; then
    echo "Passed!"
else
    echo "Failed!"
    exit 1
fi

echo "Environment and configuration setup is complete. Tests executed."