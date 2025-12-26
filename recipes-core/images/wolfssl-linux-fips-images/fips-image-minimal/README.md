# FIPS Image Minimal - Comprehensive FIPS Demonstration Image

This image demonstrates a complete FIPS-validated Linux system using wolfSSL FIPS 140-3 certified cryptography across multiple layers:

- **User-space libraries**: libgcrypt and gnutls backed by wolfSSL FIPS
- **OpenSSL replacement**: wolfProvider in replace-default mode
- **Kernel module**: wolfSSL FIPS kernel module loaded via initramfs (optional)

## Features

- wolfSSL FIPS 140-3 validated cryptography
- libgcrypt with wolfSSL backend
- GnuTLS with wolfSSL backend
- wolfProvider (OpenSSL 3.x provider) in replace-default mode
- OpenSSH, curl, and other applications using FIPS crypto
- Optional: wolfSSL FIPS kernel module loaded before rootfs mount
- Comprehensive test suite with ptest support

## Requirements

### Mandatory Configuration

Add to your `local.conf`:

```bitbake
# Enable FIPS image
WOLFSSL_DEMOS = "fips-image-minimal"

# Include FIPS configuration
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

### Optional: Early Kernel Module Loading

To load the wolfSSL FIPS kernel module in initramfs (before rootfs mounts), add to `local.conf`:

```bitbake
# FIPS initramfs configuration
INITRAMFS_IMAGE = "fips-initramfs"
INITRAMFS_IMAGE_BUNDLE = "1"
```

**Why in local.conf?**
- The kernel must see `INITRAMFS_IMAGE` at its build time
- Setting it only in the image recipe doesn't work because the kernel builds before the image
- This ensures the kernel bundles the initramfs with the wolfSSL FIPS kernel module

**When is this needed?**
- Systems requiring crypto operations before rootfs mount
- Early boot security requirements
- Kernel-space crypto dependencies on wolfSSL
- FIPS compliance requirements for kernel crypto

## FIPS Configuration

Your `wolfssl-fips.conf` should include:

```bitbake
# wolfSSL FIPS providers (user-space)
PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"
PREFERRED_PROVIDER_wolfssl = "wolfssl-fips"

# wolfSSL FIPS kernel module (optional, for initramfs)
PREFERRED_PROVIDER_virtual/wolfssl-linuxkm = "wolfssl-linuxkm-fips"
PREFERRED_PROVIDER_wolfssl-linuxkm = "wolfssl-linuxkm-fips"

# FIPS bundle details
WOLFSSL_VERSION = "x.x.x"
WOLFSSL_SRC = "wolfssl-x.x.x-commercial-fips-linux"
# ... (see conf/wolfssl-fips.conf.sample for full configuration)
```

## Building

### Standard Build (No Initramfs)

```bash
cd /path/to/poky
source oe-init-build-env
bitbake fips-image-minimal
```

### With Initramfs (Kernel Module in Early Boot)

```bash
cd /path/to/poky
source oe-init-build-env

# First build: Build initramfs and kernel with it bundled
bitbake fips-initramfs
bitbake virtual/kernel -c cleansstate
bitbake fips-image-minimal

# Subsequent builds: Just rebuild the image
bitbake fips-image-minimal
```

**Note**: Only rebuild the kernel (`cleansstate`) when:
- First time enabling initramfs
- Changing `INITRAMFS_IMAGE` setting
- Updating the kernel module in `fips-initramfs`

## Running in QEMU

Use the provided script:

```bash
source oe-init-build-env
./run-fips-qemu.sh [MACHINE]
```

Supported machines:
- `qemux86-64` (default)
- `qemuarm64`
- `qemuarm`

## Verification

### Check User-Space FIPS

```bash
# On target system
openssl version
wolfssl-fips-check
libgcrypt-config --version
gnutls-cli --version
```

### Check Kernel Module (if using initramfs)

```bash
# On target system
lsmod | grep wolfssl
dmesg | grep wolfssl
```

The kernel module should show as loaded early in `dmesg` output, before the rootfs mount message.

### Run Test Suites

```bash
# libgcrypt tests
ptest-runner libgcrypt

# GnuTLS tests
ptest-runner gnutls

# wolfProvider tests
wolfprovidertest
```

## Package Contents

The image includes:

**Core FIPS Libraries:**
- `wolfssl-fips` - FIPS 140-3 validated crypto library
- `libgcrypt` - With wolfSSL backend
- `gnutls` - With wolfSSL backend
- `wolfprovider` - OpenSSL 3.x provider (replace-default mode)

**Applications:**
- `openssh` - SSH client/server
- `curl` - HTTP client with FIPS crypto
- `openssl-bin` - OpenSSL command-line tools

**Testing Tools:**
- `ptest-runner` - Run package tests
- `wolfprovidercmd` - wolfProvider command-line tests
- `wolfproviderenv` - Environment setup/verification
- Various ptest packages for validation

**Optional (with initramfs):**
- `wolfssl-linuxkm-fips` - Kernel module loaded via initramfs

## Architecture

### Without Initramfs
```
┌─────────────────────────────────────┐
│  Applications (SSH, curl, etc.)     │
├─────────────────────────────────────┤
│  OpenSSL API (wolfProvider)         │
│  GnuTLS API                          │
│  libgcrypt API                       │
├─────────────────────────────────────┤
│  wolfSSL FIPS (User-space)          │
└─────────────────────────────────────┘
```

### With Initramfs
```
Boot Sequence:
  1. Kernel starts
  2. Initramfs mounts
  3. wolfssl-linuxkm-fips loads  ← FIPS module in kernel
  4. Root filesystem mounts
  5. Applications start with user-space wolfSSL FIPS

┌─────────────────────────────────────┐
│  Applications (SSH, curl, etc.)     │
├─────────────────────────────────────┤
│  OpenSSL API (wolfProvider)         │
│  GnuTLS API                          │
│  libgcrypt API                       │
├─────────────────────────────────────┤
│  wolfSSL FIPS (User-space)          │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│  wolfSSL FIPS (Kernel-space)        │
│  libwolfssl.ko                      │
└─────────────────────────────────────┘
```

## Troubleshooting

### Initramfs Not Loading

**Symptom**: Kernel boots directly to rootfs, no initramfs messages in dmesg

**Solution**:
1. Check `INITRAMFS_IMAGE` is set in `local.conf` (not just image recipe)
2. Rebuild kernel: `bitbake virtual/kernel -c cleansstate && bitbake fips-image-minimal`
3. Verify initramfs exists: `ls tmp/deploy/images/*/fips-initramfs*.cpio*`

### Kernel Module Not Loading

**Symptom**: `lsmod | grep wolfssl` shows nothing

**Solution**:
1. Check initramfs was built: `bitbake fips-initramfs -e | grep PACKAGE_INSTALL`
2. Verify module is in initramfs: Extract and check the .cpio.gz file
3. Check kernel messages: `dmesg | grep -i wolf`

### FIPS Validation Errors

**Symptom**: FIPS self-tests fail or crypto operations fail

**Solution**:
1. Verify FIPS hash is correct in `wolfssl-fips.conf`
2. Check license file matches bundle
3. Ensure `WOLFSSL_SRC_DIRECTORY` or bundle extraction is correct
4. Rebuild everything: `bitbake wolfssl-fips -c cleansstate && bitbake fips-image-minimal`

## See Also

- `recipes-core/images/wolfssl-linux-fips-images/fips-initramfs.bb` - Initramfs recipe
- `conf/wolfssl-fips.conf.sample` - FIPS configuration template
- `recipes-wolfssl/wolfssl/README-fips.md` - wolfSSL FIPS recipe documentation
- `recipes-wolfssl/wolfssl/README-linuxkm.md` - Kernel module documentation
- `classes/wolfssl-initramfs.bbclass` - Initramfs integration helpers
