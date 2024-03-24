#!/bin/bash

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

# Execute the test program, assuming it's located in the same directory as this script
# Adjust the path as necessary depending on where the binary ends up
echo "Programmatic Test"
if wolfprovidertest; then
    echo "Passed!"
else
    echo "Failed!"
    exit 1
fi

echo "OpenSSL Conf Test"
openssl list -providers -verbose 

echo "Environment and configuration setup is complete. Tests executed."
