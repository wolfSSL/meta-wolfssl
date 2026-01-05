# Enable FIPS-compliant encryption configuration for rsyslog
# This keeps libgcrypt for log file encryption while using wolfSSL for TLS/SSL

inherit wolfssl-compatibility

SRC_URI += "file://rsyslog-libgcrypt-wolfssl-fips.conf"

python __anonymous() {
    wolfssl_varPrepend(d, 'FILESEXTRAPATHS', '${THISDIR}/files:')
    wolfssl_varAppendNonOverride(d, 'PACKAGECONFIG', ' libgcrypt')
    wolfssl_varAppend(d, 'FILES', '${PN}', ' ${sysconfdir}/rsyslog.d/rsyslog-libgcrypt-wolfssl-fips.conf')
}

# Install FIPS crypto configuration
do_install_rsyslog_fips_config() {
    install -d ${D}${sysconfdir}/rsyslog.d
    install -m 0644 ${WORKDIR}/rsyslog-libgcrypt-wolfssl-fips.conf ${D}${sysconfdir}/rsyslog.d/
}

addtask do_install_rsyslog_fips_config after do_install before do_package
do_install_rsyslog_fips_config[fakeroot] = "1"
