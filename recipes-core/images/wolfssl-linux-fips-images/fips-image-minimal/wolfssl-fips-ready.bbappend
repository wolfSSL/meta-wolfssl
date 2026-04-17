# Configure wolfSSL FIPS Ready for fips-image-minimal
#
# This bbappend configures wolfSSL FIPS Ready with libgcrypt, gnutls, and wolfProvider support

require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips-ready/wolfssl-enable-libgcrypt.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips-ready/wolfssl-enable-gnutls.inc
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider-fips-ready.inc

# Fix for bundle missing stamp-h.in required by automake
do_configure_create_stamph() {
    if [ ! -f ${S}/stamp-h.in ]; then
        touch ${S}/stamp-h.in
    fi
}

addtask do_configure_create_stamph after do_patch before do_configure
