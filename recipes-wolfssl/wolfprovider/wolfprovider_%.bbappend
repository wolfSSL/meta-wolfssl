# Conditionally configure wolfProvider with unit tests
# 
# This bbappend automatically enables wolfProvider unit tests when 
# WOLFPROVIDER_FLAGS contains "enable-tests"

require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfprovider-enable-unittest.inc

