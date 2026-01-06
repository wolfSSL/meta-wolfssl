# Configure wolfSSL (to enable FIPS standalone mode) for wolfprovider-images
#
# This bbappend directly configures wolfSSL to use FIPS wolfProvider
# when wolfssl-fips is the preferred provider.

require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc

# Fix for commercial bundle missing stamp-h.in required by automake
do_configure_create_stamph() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}

addtask do_configure_create_stamph after do_patch before do_configure
