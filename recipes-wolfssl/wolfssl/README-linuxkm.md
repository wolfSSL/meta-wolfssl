# 📘 **wolfSSL LinuxKM Integration Guide**

This document describes how to build and integrate the wolfSSL Linux Kernel Module (LinuxKM) into standard Yocto images and initramfs images, including a complete example for **NVIDIA Tegra-based systems**.

---

# 🧩 1. Building the wolfSSL Linux Kernel Module

The non-FIPS wolfSSL kernel module can be built directly:

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

The module will load automatically during systemd boot — even without an initramfs.

---

# 🧩 2. Adding wolfSSL LinuxKM to an Initramfs Image

Some systems require wolfSSL to be available **before** the root filesystem is mounted.

For that, this layer provides:

```
classes/wolfssl-initramfs.bbclass
```

To add wolfSSL LinuxKM to *any* initramfs:

### In your distro or BSP layer:

Create:

```
recipes-core/images/<your-initramfs>.bbappend
```

Add:

```bitbake
inherit wolfssl-initramfs
```

This ensures:

* `wolfssl-linuxkm` is added to `PACKAGE_INSTALL`
* libwolfssl.ko is included in the initramfs filesystem
* `/etc/modules-load.d/wolfssl.conf` is available inside the initramfs

---

# 🐧 **3. Example: Integrating wolfSSL LinuxKM into Tegra Initramfs **

NVIDIA Tegra boards (Jetson Orin, Xavier, Nano, etc.) often use:

```
tegra-minimal-initramfs
```

as the early-boot initramfs.

To include wolfSSL LinuxKM into the Tegra initramfs, create this file in your BSP overrides layer:

```
meta-<project-name>-overrides/recipes-core/images/tegra-minimal-initramfs.bbappend
```

Contents:

```bitbake
inherit wolfssl-initramfs
```

That’s it.

### After building:

```sh
bitbake tegra-minimal-initramfs
```

You will find inside `rootfs/`:

```
lib/modules/<kernel>/extra/libwolfssl.ko
etc/modules-load.d/wolfssl.conf
```

The module is now embedded into the initramfs and will load *before* systemd, which is required for early-boot scenarios.

---

# ✨ **4. How LinuxKM behaves on Tegra (with and without initramfs)**

### ✔ Case A — *Without* initramfs integration

* wolfssl-linuxkm is installed into the main rootfs
* systemd loads it automatically after initramfs
* Suitable for most applications

### ✔ Case B — *With* wolfssl-initramfs

* libwolfssl.ko included in initramfs
* Loaded **before the root filesystem is mounted**
* Required if:

  * Early-boot crypto is needed
  * Early kernel services need wolfSSL
  * Tegra BSP requires modules during initramfs stage
  * FIPS-enabled systems need early module loading

### 💡 Tegra benefit

Tegra platforms (especially automotive/industrial builds) load many modules early; placing wolfSSL in initramfs avoids dependency failures or load-order issues.

---

# 🚀 **5. Summary**

| Use Case                            | Recommended Method                                                    |
| ----------------------------------- | --------------------------------------------------------------------- |
| Normal Linux systems                | Simply include `wolfssl-linuxkm` in `IMAGE_INSTALL`                   |
| Systems requiring early-boot crypto | Inherit `wolfssl-initramfs` in initramfs image                        |
| Tegra (meta-tegra)                  | Add `inherit wolfssl-initramfs` in `tegra-minimal-initramfs.bbappend` |

The kernel module loads cleanly in both scenarios.