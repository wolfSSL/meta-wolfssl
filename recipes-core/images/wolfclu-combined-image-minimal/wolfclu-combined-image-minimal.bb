SUMMARY = "Minimal image with wolfSSL, wolfCLU, and Python bindings"
DESCRIPTION = "A combined demonstration image including wolfclu, wolfssl-py, and wolfcrypt-py with networking support"

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

inherit wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppendNonOverride(d, 'IMAGE_INSTALL', ' wolfclu wolfssl-py wolfcrypt-py wolf-py-tests python3 python3-cffi python3-pytest ca-certificates')
    wolfssl_varAppendNonOverride(d, 'ROOTFS_POSTPROCESS_COMMAND', ' setup_dns_config; ')
}

IMAGE_FEATURES += "package-management"

# Configure DNS at boot time
setup_dns_config() {
    # Create init script to configure DNS
    mkdir -p ${IMAGE_ROOTFS}/etc/init.d
    cat > ${IMAGE_ROOTFS}/etc/init.d/dns-config << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          dns-config
# Required-Start:    $local_fs
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: Configure DNS resolvers
### END INIT INFO

case "$1" in
    start)
        echo "Configuring DNS..."
        cat > /etc/resolv.conf << 'RESOLV'
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 8.8.4.4
RESOLV
        chmod 644 /etc/resolv.conf
        chattr +i /etc/resolv.conf 2>/dev/null || true
        ;;
    *)
        echo "Usage: $0 start"
        exit 1
        ;;
esac

exit 0
EOF
    chmod 755 ${IMAGE_ROOTFS}/etc/init.d/dns-config
    ln -sf ../init.d/dns-config ${IMAGE_ROOTFS}/etc/rcS.d/S99dns-config
}
