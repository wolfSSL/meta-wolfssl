# wolfProvider Minimal Images

Minimal demo images showcasing wolfProvider integration with OpenSSL 3.x in various configurations.

## Overview

These images demonstrate different wolfProvider configurations for OpenSSL 3.x integration. Each image is self-contained and requires no `local.conf` configuration (except FIPS images which require `wolfssl-fips.conf`).

## Available Images

### 1. wolfprovider-image-minimal
**Standalone mode, non-FIPS**

- wolfProvider configured as an additional provider alongside OpenSSL's default
- Applications can explicitly load wolfProvider or use it alongside the default provider
- Includes test utilities and unit tests

**Configuration:**
```bitbake
# Enable demo images
WOLFSSL_DEMOS = "wolfprovider-image-minimal"
```

if enabling fips add: 
```bitbake
# In build/conf/local.conf:
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

**Build:**
```bash
bitbake wolfprovider-image-minimal
```

### 2. wolfprovider-replace-default-image-minimal
**Replace-default mode**

- wolfProvider replaces OpenSSL's default provider
- All OpenSSL operations automatically use wolfProvider
- No code changes needed - transparent drop-in replacement

**Configuration:**
```bitbake
# Enable demo images
WOLFSSL_DEMOS = "wolfprovider-replace-default-image-minimal"
```

if enabling fips add: 
```bitbake
# In build/conf/local.conf:
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

**Build:**
```bash
bitbake wolfprovider-replace-default-image-minimal
```

## What's Included

All images include:
- Everything from `wolfssl-image-minimal`
- wolfSSL (or wolfSSL FIPS) with wolfProvider support
- OpenSSL 3.x with wolfProvider backend
- wolfProvider environment setup tools (`wolfproviderenv`, `wolfprovidercmd`)
- Unit tests (standalone mode images only)

## Testing

Inside QEMU, test wolfProvider:

```bash
# Run wolfProvider environment setup (standalone mode only)
wolfprovidertest

# Run wolfProvider command-line tests
wolfprovidercmd

# Run wolfProvider environment setup
wolfproviderenv

# Verify provider configuration (replace-default images)
openssl list -providers
```

## How It Works

Each image directory contains `bbappend` files that automatically configure packages:

- **wolfssl_%.bbappend** or **wolfssl-fips_%.bbappend**: Configures wolfSSL with wolfProvider support
- **openssl_%.bbappend**: Configures OpenSSL to support wolfProvider (standalone or replace-default)
- **wolfprovider_%.bbappend**: Enables unit tests (standalone mode only)

All configurations use conditional functions (`wolfssl_osp_include_if_provider`) that automatically detect the provider and include the appropriate configuration files.

## Mode Comparison

### Standalone Mode
- wolfProvider is an additional provider
- Applications must explicitly load wolfProvider
- OpenSSL's default provider remains available
- Useful for testing and selective adoption

### Replace-Default Mode
- wolfProvider replaces OpenSSL's default provider
- All OpenSSL operations automatically use wolfProvider
- No application code changes needed
- Useful for system-wide deployment

## Requirements

- **FIPS images**: Valid wolfSSL FIPS commercial bundle and `wolfssl-fips.conf` configuration
- **Non-FIPS images**: No additional requirements

## More Information

- Main README: [../../../README.md](../../../README.md)
- wolfProvider: [../../../recipes-wolfssl/wolfprovider/README.md](../../../recipes-wolfssl/wolfprovider/README.md)
- wolfSSL FIPS: [../../../recipes-wolfssl/wolfssl/README-fips.md](../../../recipes-wolfssl/wolfssl/README-fips.md)
