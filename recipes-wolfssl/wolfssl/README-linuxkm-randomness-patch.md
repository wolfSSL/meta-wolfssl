# wolfSSL Kernel Randomness Patch

This bbclass allows you to apply wolfSSL random callback patches to the Linux kernel, enabling wolfSSL's DRBG to integrate with the kernel's random subsystem.

## Overview

The patches add callback hooks to `drivers/char/random.c` and `include/linux/random.h`, allowing the wolfSSL kernel module (`libwolfssl.ko`) to register its DRBG implementation with the kernel.

This is useful for:
- FIPS 140-2/140-3 compliance requiring certified DRBG
- Hardware security module (HSM) integration
- Custom entropy sources

## Available Patches

See all available patches at:
**https://github.com/wolfSSL/wolfssl/tree/master/linuxkm/patches**

Common patch directories:

| Patch Directory             | Target Kernel                        |
|-----------------------------|--------------------------------------|
| `5.10.17`                   | Linux 5.10.17                        |
| `5.10.236`                  | Linux 5.10.236 LTS                   |
| `5.15`                      | Linux 5.15.x (vanilla)               |
| `5.17`                      | Linux 5.17.x (vanilla)               |
| `5.17-ubuntu-jammy-tegra`   | NVIDIA Tegra L4T (Jetson platforms)  |
| `6.1.73`                    | Linux 6.1.73 LTS                     |
| `6.12`                      | Linux 6.12.x                         |
| `6.15`                      | Linux 6.15.x                         |

## Usage

### 1. Create a kernel bbappend

Create a bbappend for your kernel recipe in your layer:

```
meta-mylayer/
└── recipes-kernel/
    └── linux/
        └── linux-jammy-nvidia-tegra.bbappend   # or your kernel recipe name
```

### 2. Inherit the bbclass and set the patch

```bitbake
inherit wolfssl-kernel-random
WOLFSSL_KERNEL_RANDOM_PATCH = "5.17-ubuntu-jammy-tegra"
```

### 3. Build the kernel

```bash
bitbake virtual/kernel
```

The patches will be automatically fetched from the wolfSSL GitHub repository and applied during the kernel build.

## Examples

### NVIDIA Tegra (Jetson Orin, Xavier, AGX, Nano)

```bitbake
# linux-jammy-nvidia-tegra.bbappend
inherit wolfssl-kernel-random
WOLFSSL_KERNEL_RANDOM_PATCH = "5.17-ubuntu-jammy-tegra"
```

### Standard Yocto linux-yocto 6.12

```bitbake
# linux-yocto_%.bbappend
inherit wolfssl-kernel-random
WOLFSSL_KERNEL_RANDOM_PATCH = "6.12"
```

### Older LTS Kernel 5.10

```bitbake
# linux-yocto_5.10.bbappend
inherit wolfssl-kernel-random
WOLFSSL_KERNEL_RANDOM_PATCH = "5.10.236"
```

## Configuration Options

| Variable                     | Description                                      | Default      |
|------------------------------|--------------------------------------------------|--------------|
| `WOLFSSL_KERNEL_RANDOM_PATCH`| Patch directory name from wolfSSL repo           | `""` (none)  |
| `WOLFSSL_PATCHES_REPO`       | wolfSSL Git repository URL                       | GitHub master|
| `WOLFSSL_PATCHES_SRCREV`     | Git revision to fetch patches from               | `AUTOREV`    |

### Pin to a specific wolfSSL release

```bitbake
inherit wolfssl-kernel-random
WOLFSSL_KERNEL_RANDOM_PATCH = "6.12"
WOLFSSL_PATCHES_SRCREV = "v5.7.0-stable"
```

## How It Works

1. The bbclass adds wolfSSL Git repo to `SRC_URI`
2. During `do_patch`, it locates the specified patch directory
3. All `.patch` files in that directory are applied to the kernel source
4. If a patch is already applied, it is skipped

## Verifying the Patch

After building, verify the patch was applied:

```bash
grep -r "WOLFSSL_LINUXKM" /path/to/kernel-source/drivers/char/random.c
grep -r "WOLFSSL_LINUXKM" /path/to/kernel-source/include/linux/random.h
```

You should see `WOLFSSL_LINUXKM_HAVE_GET_RANDOM_CALLBACKS` definitions.

## Using with wolfSSL Kernel Module

After patching the kernel, build the wolfSSL kernel module:

```bash
bitbake wolfssl-linuxkm
```

Or for FIPS:

```bash
bitbake wolfssl-linuxkm-fips
```

The module will automatically use the callback hooks if the kernel was patched.

## Troubleshooting

### Patch fails to apply

```
wolfSSL: Failed to apply patch: ...
```

The patch may not be compatible with your kernel version. Check:
1. Your kernel version matches the patch directory
2. Available patches at https://github.com/wolfSSL/wolfssl/tree/master/linuxkm/patches

### Patch directory not found

```
wolfSSL: Patch directory not found: ...
```

Verify `WOLFSSL_KERNEL_RANDOM_PATCH` matches a directory name in the wolfSSL repo.

### Patch already applied

```
wolfSSL: Patch already applied, skipping: ...
```

This is normal - the bbclass detects previously applied patches and skips them.

## Security Note

Enabling these patches allows wolfSSL to provide cryptographic random numbers to the kernel. Ensure your wolfSSL configuration meets your security requirements, especially for FIPS compliance.