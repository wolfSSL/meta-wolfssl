# libgcrypt with wolfSSL Backend

This directory provides integration for running libgcrypt with wolfSSL/wolfCrypt as the cryptographic backend, enabling FIPS-validated cryptography through libgcrypt's standard API.

## Overview

libgcrypt is a general-purpose cryptographic library used by many Linux applications (GnuPG, systemd, etc.). By configuring it to use wolfSSL's FIPS-validated wolfCrypt as the backend, you can provide FIPS 140-3 validated cryptography to all applications using libgcrypt.

## Files

### `libgcrypt_%.bbappend`
Conditionally enables wolfSSL backend when:
- `libgcrypt` is in `WOLFSSL_FEATURES`, AND
- `wolfssl-fips` is the `PREFERRED_PROVIDER`

Uses the `wolfssl-osp-support` class for conditional configuration.

### `wolfssl-fips_%.bbappend`
Configures wolfssl-fips with additional features needed by libgcrypt when `libgcrypt` is in `WOLFSSL_FEATURES`.

## Configuration Files

### `inc/libgcrypt/libgcrypt-enable-wolfssl.inc`
Configures libgcrypt to use the wolfSSL-enabled fork:
- Changes source to `github.com/wolfSSL/libgcrypt-wolfssl`
- Updates to version 1.11.0
- Adds wolfSSL dependencies
- Configures with `--enable-wolfssl-fips`

### `inc/wolfssl-fips/wolfssl-enable-libgcrypt.inc`
Configures wolfssl-fips with features required by libgcrypt:
- `--enable-fips=v5` - FIPS 140-3 validation
- `--enable-keygen` - Key generation support
- Additional compile flags for libgcrypt compatibility

## Usage

### Method 1: Using WOLFSSL_FEATURES (Recommended)

```bitbake
# In build/conf/local.conf
WOLFSSL_FEATURES = "libgcrypt"
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf

# Add to your image
IMAGE_INSTALL:append = " libgcrypt"
```

### Method 2: Using Demo Image

```bitbake
# In build/conf/local.conf
WOLFSSL_DEMOS = "wolfssl-image-minimal libgcrypt-image-minimal"
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf

# Build the demo image
bitbake libgcrypt-image-minimal
```

## Testing

The demo image includes ptest support:

```bash
# In QEMU
ptest-runner libgcrypt
```

This runs the libgcrypt test suite to verify the wolfSSL backend is working correctly.

## Requirements

- **wolfssl-fips**: This integration only works with wolfSSL FIPS builds
- **FIPS Bundle**: You must have a valid wolfSSL FIPS commercial bundle
- **libgcrypt 1.11.0+**: The wolfSSL fork is based on libgcrypt 1.11.0

## Architecture

```
┌─────────────────────────────────┐
│  Applications (GnuPG, systemd)  │
└───────────────┬─────────────────┘
                │ libgcrypt API
┌───────────────▼─────────────────┐
│         libgcrypt 1.11.0        │
│    (wolfSSL-enabled fork)       │
└───────────────┬─────────────────┘
                │ wolfCrypt API
┌───────────────▼─────────────────┐
│  wolfSSL FIPS (wolfCrypt Core)  │
│    FIPS 140-3 Validated         │
└─────────────────────────────────┘
```

## More Information

- Demo Image: [recipes-core/images/libgcrypt-image-minimal/README.md](../../recipes-core/images/libgcrypt-image-minimal/README.md)
- Main Layer README: [../../README.md](../../README.md)
- libgcrypt-wolfssl: https://github.com/wolfSSL/libgcrypt-wolfssl

