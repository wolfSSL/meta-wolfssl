# 📘 **wolfSSL LinuxKM Integration Guide (Updated for New Initramfs API)**

This document describes how to build and integrate the wolfSSL Linux Kernel Module (LinuxKM) into standard Yocto images and initramfs images, including a complete example for **NVIDIA Tegra-based systems**.

---

# 🧩 1. Building the wolfSSL Linux Kernel Module

Build the non-FIPS kernel module:

```sh
bitbake wolfssl-linuxkm
```

This produces:

```
libwolfssl.ko → /lib/modules/<kernel>/extra/
```

and installs an autoload entry:

```
/etc/modules-load.d/wolfssl.conf
```

This ensures wolfSSL loads automatically during systemd boot on standard rootfs images — even without an initramfs.

---

# 🧩 2. Adding wolfSSL LinuxKM to an Initramfs Image

Some systems require wolfSSL to be available **before** the root filesystem is mounted.
For that purpose, this layer provides:

```
classes/wolfssl-initramfs.bbclass
```

Unlike earlier versions, this class **does not automatically install wolfssl-linuxkm** or modify `/init`.
Instead, it provides **a set of opt-in helper functions** that the initramfs recipe can call explicitly.

---

## **2.1. Include wolfSSL LinuxKM (or FIPS) in the initramfs**

In your initramfs recipe or `.bbappend`:

```bitbake
inherit wolfssl-initramfs
PACKAGE_INSTALL:append = " wolfssl-linuxkm"
```

**Automatic FIPS Selection:**

If you have configured `wolfssl-fips.conf` with:
```bitbake
# Use wolfSSL FIPS Linux kernel module (FIPS-validated kernel module)
PREFERRED_PROVIDER_virtual/wolfssl-linuxkm = "wolfssl-linuxkm-fips"
PREFERRED_PROVIDER_wolfssl-linuxkm = "wolfssl-linuxkm-fips"
```

**Note:** Both lines are required:
- `virtual/wolfssl-linuxkm` - Controls build-time dependencies
- `wolfssl-linuxkm` - Controls runtime package installation

Then `wolfssl-linuxkm` will automatically resolve to the FIPS-validated version (`wolfssl-linuxkm-fips`).
No code changes needed - the virtual provider system handles the switch automatically.

**Manual FIPS Selection (alternative):**

You can also explicitly specify the FIPS version:
```bitbake
PACKAGE_INSTALL:append = " wolfssl-linuxkm-fips"
```

This ensures the selected kernel module is included inside the initramfs filesystem.

---

## **2.2. Optional: Generate module dependencies inside the initramfs**

If your initramfs uses `modprobe`, you should generate dependency metadata:

```bitbake
ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_run_depmod; "
```

---

## **2.3. Optional: Auto-load wolfSSL during initramfs boot**

The class exposes the following injection methods, letting you choose how `/init` gets modified:

| Function                                     | Injection Point                               |
| -------------------------------------------- | --------------------------------------------- |
| `wolfssl_initramfs_inject_after_modalias`    | After modalias scan loop                      |
| `wolfssl_initramfs_inject_after_loadmodules` | After the “Load and run modules” section      |
| `wolfssl_initramfs_inject_after_kmsg`        | Early injection after `/dev/kmsg` redirection |

Example (recommended for Tegra):

```bitbake
ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_run_depmod; "
ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_inject_after_modalias; "
```

Fallback for simpler initramfs layouts:

```bitbake
ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_inject_after_kmsg; "
```

---

# 🐧 **3. Example: Integrating wolfSSL LinuxKM into Tegra Initramfs**

NVIDIA Tegra boards (Jetson Orin, Xavier, Nano, AGX, etc.) commonly use:

```
tegra-minimal-initramfs
```

To integrate wolfSSL LinuxKM into the Tegra initramfs, create this file:

```
meta-<project-name>-overrides/recipes-core/images/tegra-minimal-initramfs.bbappend
```

Contents:

```bitbake
inherit wolfssl-initramfs

PACKAGE_INSTALL:append = " wolfssl-linuxkm"

ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_run_depmod; "
ROOTFS_POSTPROCESS_COMMAND += " wolfssl_initramfs_inject_after_modalias; "
```

### After building:

```sh
bitbake tegra-minimal-initramfs
```

Inside the generated rootfs you will find:

```
lib/modules/<kernel>/extra/libwolfssl.ko
etc/modules-load.d/wolfssl.conf
init  (modified to auto-load wolfSSL)
```

wolfSSL now loads **before** the root filesystem is mounted — required for early-boot crypto or dependencies in Tegra BSPs.

---

# ✨ 4. How LinuxKM behaves on Tegra (with and without initramfs)

### ✔ Case A — *Without* initramfs integration

* wolfssl-linuxkm is installed into the main rootfs
* systemd loads it automatically
* Suitable for most Linux systems

---

### ✔ Case B — *With* `wolfssl-initramfs`

* libwolfssl.ko included inside initramfs
* `modprobe libwolfssl` runs before mount of rootfs
* Required if:

  * Early boot crypto operations need wolfSSL
  * Kernel services in initramfs depend on wolfSSL
  * Tegra BSP loads cryptography-related modules early
  * FIPS-certified environments require early module availability

---

### 💡 Why this matters on Tegra

Tegra platforms (especially industrial/robotics/ADAS) rely heavily on initramfs-stage drivers and may need wolfSSL *before userspace starts*.
Placing wolfSSL in initramfs avoids failures due to:

* module load ordering
* missing crypto backends
* delayed rootfs mounts

---

# 🚀 **5. Summary**

| Use Case                                       | Recommended Method                                                |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| Normal Linux systems                           | Include `wolfssl-linuxkm` in `IMAGE_INSTALL`                      |
| Early-boot crypto or initramfs crypto services | Use `wolfssl-initramfs` helpers                                   |
| Tegra or meta-tegra BSP                        | Add `inherit wolfssl-initramfs` and explicit postprocess commands |

`wolfssl-initramfs.bbclass` now acts as a **modular, opt-in integration toolkit**, supporting both standard and FIPS kernel modules cleanly.