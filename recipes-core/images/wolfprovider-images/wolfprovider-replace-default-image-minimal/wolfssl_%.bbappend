# Configure wolfSSL (to enable FIPS standalone mode) for wolfprovider-images
#
# This bbappend directly configures wolfSSL to use FIPS wolfProvider
# when wolfssl-fips is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider.inc

# Fix for commercial bundle missing stamp-h.in required by automake
do_configure:prepend() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}


