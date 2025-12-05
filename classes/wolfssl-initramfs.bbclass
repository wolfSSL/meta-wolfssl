# classes/wolfssl-initramfs.bbclass
#
# Purpose:
#   - Automatically pull in wolfssl-linuxkm into any *initramfs* image
#     that inherits this class.
#   - Run depmod inside the initramfs rootfs.
#   - Try to inject 'modprobe libwolfssl' into /init in a best-effort,
#     portable way without assuming a specific init layout.
#
# Usage (in an image recipe or bbappend):
#   inherit wolfssl-initramfs
#
# Requirements:
#   - wolfssl-linuxkm recipe builds libwolfssl.ko into:
#       /lib/modules/${KERNEL_VERSION}/extra/libwolfssl.ko
#   - depmod is available in the rootfs postprocess environment.


PACKAGE_INSTALL:append = " wolfssl-linuxkm"

# Ensure modules directory exists
ROOTFS_POSTPROCESS_COMMAND += "wolfssl_initramfs_postprocess;"


wolfssl_initramfs_postprocess() {
    echo "wolfssl-initramfs: running postprocess hook" >&2

    # 1 - Ensure module dependency info is generated inside the initramfs
    if [ -d "${IMAGE_ROOTFS}/lib/modules" ]; then
        if command -v depmod >/dev/null 2>&1; then
            for kver in "${IMAGE_ROOTFS}"/lib/modules/*; do
                if [ -d "$kver" ]; then
                    echo "wolfssl-initramfs: running depmod for $(basename "$kver")" >&2
                    depmod -a -b "${IMAGE_ROOTFS}" "$(basename "$kver")" || \
                        echo "wolfssl-initramfs: WARNING: depmod failed for $(basename "$kver")" >&2
                fi
            done
        else
            echo "wolfssl-initramfs: WARNING: depmod not found, skipping depmod step" >&2
        fi
    else
        echo "wolfssl-initramfs: NOTE: no /lib/modules in initramfs, nothing to depmod" >&2
    fi

    # 2 - Try to inject 'modprobe libwolfssl' into /init (best effort)
    if [ ! -f "${IMAGE_ROOTFS}/init" ]; then
        echo "wolfssl-initramfs: NOTE: initramfs has no /init, skip wolfSSL autoload injection" >&2
        return 0
    fi

    # Only inject if libwolfssl.ko is actually present
    if ! find "${IMAGE_ROOTFS}/lib/modules" -name 'libwolfssl.ko' >/dev/null 2>&1; then
        echo "wolfssl-initramfs: NOTE: libwolfssl.ko not found in initramfs, skip modprobe injection" >&2
        return 0
    fi

    # Prefer to inject right after the modalias loop if present
    if grep -q 'find /sys -name modalias' "${IMAGE_ROOTFS}/init"; then
        echo "wolfssl-initramfs: injecting modprobe libwolfssl after modalias loop" >&2
        sed -i '/find \/sys -name modalias/{
a\
modprobe libwolfssl || echo "wolfssl-initramfs: failed to load libwolfssl" >&2
}' "${IMAGE_ROOTFS}/init" || \
        echo "wolfssl-initramfs: WARNING: sed injection after modalias loop failed" >&2
        return 0
    fi

    # 3 - Fallback: inject after a generic module-load comment if present
    if grep -q '^# Load and run modules' "${IMAGE_ROOTFS}/init"; then
        echo "wolfssl-initramfs: injecting modprobe libwolfssl after \"# Load and run modules\" anchor" >&2
        sed -i '/^# Load and run modules/a\
modprobe libwolfssl || echo "wolfssl-initramfs: failed to load libwolfssl" >&2
' "${IMAGE_ROOTFS}/init" || \
        echo "wolfssl-initramfs: WARNING: sed injection after Load-and-run-modules anchor failed" >&2
        return 0
    fi

    # 4 - Last resort: inject just after the /dev/kmsg redirection (very early)
    if grep -q 'exec > /dev/kmsg' "${IMAGE_ROOTFS}/init"; then
        echo "wolfssl-initramfs: injecting modprobe libwolfssl after kmsg redirect" >&2
        sed -i '/exec > \/dev\/kmsg 2>&1/a\
modprobe libwolfssl || echo "wolfssl-initramfs: failed to load libwolfssl" >&2
' "${IMAGE_ROOTFS}/init" || \
        echo "wolfssl-initramfs: WARNING: sed injection after kmsg anchor failed" >&2
        return 0
    fi

    # If we reach here, we didn't find a safe anchor
    echo "wolfssl-initramfs: NOTE: no known init anchor found, not injecting modprobe. Manual initramfs integration may be required." >&2
}