# OpenSSL standalone wolfProvider mode configuration
# Include this file for standard wolfProvider integration as a provider plugin

EXTRA_OECONF += " no-fips shared "

do_install:append() {
    install -d ${D}${sysconfdir}/openssl
    echo "0" > ${D}${sysconfdir}/openssl/replace-default-enabled
}


