# Manual configuration for wolfprovider-image-minimal
# Enable wolfProvider support in wolfSSL

# WARNING: need to specify non-FIPS or FIPS mode not both
# Uncomment this to use wolfProvider non-FIPS
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider.inc
# Uncomment this to use wolfProvider FIPS
# require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc

