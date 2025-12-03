# classes/wolfssl-initramfs.bbclass
#
# Purpose:
#   Provide reusable functions that allow initramfs images to:
#     - include wolfssl-linuxkm
#     - run depmod inside the initramfs rootfs
#     - optionally inject `modprobe libwolfssl` into /init
#
# IMPORTANT:
#   This class does *not* automatically modify ROOTFS_POSTPROCESS_COMMAND.
#   The consuming image recipe must explicitly opt-in:
#
#     inherit wolfssl-initramfs
#     PACKAGE_INSTALL:append = " wolfssl-linuxkm"
#     ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_run_depmod; "
#     ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_inject_after_modalias; "
#
# Available injection functions are documented below.

### ─────────────────────────────────────────────────────────────
### 0. Common helper
### ─────────────────────────────────────────────────────────────

wolfssl_initramfs_has_module() {
    find "${IMAGE_ROOTFS}/lib/modules" -name 'libwolfssl.ko' >/dev/null 2>&1
}

wolfssl_initramfs_has_init() {
    [ -f "${IMAGE_ROOTFS}/init" ]
}

### ─────────────────────────────────────────────────────────────
### 1. Run depmod inside the initramfs
### ─────────────────────────────────────────────────────────────

wolfssl_initramfs_run_depmod() {
    echo "wolfssl-initramfs: running depmod" >&2

    if [ ! -d "${IMAGE_ROOTFS}/lib/modules" ]; then
        echo "wolfssl-initramfs: no modules directory found; skipping depmod" >&2
        return 0
    fi

    if ! command -v depmod >/dev/null 2>&1; then
        echo "wolfssl-initramfs: depmod not available; skipping" >&2
        return 0
    fi

    for kdir in "${IMAGE_ROOTFS}"/lib/modules/*; do
        [ -d "$kdir" ] || continue

        kver=$(basename "$kdir")
        echo "wolfssl-initramfs: depmod -a -b ${IMAGE_ROOTFS} ${kver}" >&2

        depmod -a -b "${IMAGE_ROOTFS}" "${kver}" || \
            echo "wolfssl-initramfs: WARNING: depmod failed for ${kver}" >&2
    done
}

### ─────────────────────────────────────────────────────────────
### 2. Injection methods for /init
### ─────────────────────────────────────────────────────────────

# Common injection wrapper
wolfssl_initramfs_try_inject() {
    local anchor="$1"
    local sed_expr="$2"
    local desc="$3"

    if grep -q "$anchor" "${IMAGE_ROOTFS}/init"; then
        echo "wolfssl-initramfs: injecting modprobe at: $desc" >&2
        sed -i "$sed_expr" "${IMAGE_ROOTFS}/init" || \
            echo "wolfssl-initramfs: WARNING: failed to inject at $desc" >&2
    fi
}

### 2A: Inject after modalias scan loop
wolfssl_initramfs_inject_after_modalias() {
    echo "wolfssl-initramfs: checking modalias injection" >&2

    wolfssl_initramfs_has_init     || { echo "… no /init, skip"; return 0; }
    wolfssl_initramfs_has_module   || { echo "… module missing, skip"; return 0; }

    wolfssl_initramfs_try_inject \
        "find /sys -name modalias" \
        '/find \/sys -name modalias/a\
modprobe libwolfssl || echo "wolfssl-initramfs: failed to load libwolfssl" >&2' \
        "modalias section"
}

### 2B: Inject after '# Load and run modules'
wolfssl_initramfs_inject_after_loadmodules() {
    echo "wolfssl-initramfs: checking loadmodules injection" >&2

    wolfssl_initramfs_has_init     || { echo "… no /init, skip"; return 0; }
    wolfssl_initramfs_has_module   || { echo "… module missing, skip"; return 0; }

    wolfssl_initramfs_try_inject \
        '^# Load and run modules' \
        '/^# Load and run modules/a\
modprobe libwolfssl || echo "wolfssl-initramfs: failed to load libwolfssl" >&2' \
        "Load-and-run-modules section"
}

### 2C: Last-resort: Inject after kmsg redirect
wolfssl_initramfs_inject_after_kmsg() {
    echo "wolfssl-initramfs: checking kmsg injection" >&2

    wolfssl_initramfs_has_init     || { echo "… no /init, skip"; return 0; }
    wolfssl_initramfs_has_module   || { echo "… module missing, skip"; return 0; }

    wolfssl_initramfs_try_inject \
        'exec > /dev/kmsg' \
        '/exec > \/dev\/kmsg 2>&1/a\
modprobe libwolfssl || echo "wolfssl-initramfs: failed to load libwolfssl" >&2' \
        "kmsg redirection section"
}

### ─────────────────────────────────────────────────────────────
### 3. Documentation (shown in bitbake -e or debugging)
### ─────────────────────────────────────────────────────────────

WOLFSSL_INITRAMFS_FUNCTIONS = "\
    wolfssl_initramfs_run_depmod \
    wolfssl_initramfs_inject_after_modalias \
    wolfssl_initramfs_inject_after_loadmodules \
    wolfssl_initramfs_inject_after_kmsg \
"
