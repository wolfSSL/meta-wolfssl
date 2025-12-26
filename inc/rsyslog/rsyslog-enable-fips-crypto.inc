# Enable FIPS-compliant encryption configuration for rsyslog
# This keeps libgcrypt for log file encryption while using wolfSSL for TLS/SSL

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://rsyslog-libgcrypt-wolfssl-fips.conf"

# Keep libgcrypt for log file encryption
PACKAGECONFIG:append = " libgcrypt"

# Install FIPS crypto configuration
do_install:append() {
    install -d ${D}${sysconfdir}/rsyslog.d
    install -m 0644 ${WORKDIR}/rsyslog-libgcrypt-wolfssl-fips.conf ${D}${sysconfdir}/rsyslog.d/
}

FILES:${PN} += "${sysconfdir}/rsyslog.d/rsyslog-libgcrypt-wolfssl-fips.conf"

