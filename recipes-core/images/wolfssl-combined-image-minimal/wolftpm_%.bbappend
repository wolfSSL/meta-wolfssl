# Disable feature check and enable devtpm for wolftpm in combined image
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-manual-config.inc

EXTRA_OECONF += "--enable-devtpm"

