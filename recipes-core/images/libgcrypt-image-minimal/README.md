# libgcrypt-image-minimal

Minimal demo image showcasing libgcrypt with wolfSSL FIPS backend.

## Overview

This image demonstrates libgcrypt configured to use wolfSSL's FIPS-validated wolfCrypt as its cryptographic backend. This allows any application using libgcrypt (GnuPG, systemd, etc.) to benefit from FIPS 140-3 validated cryptography.

## What's Included

- Everything from `wolfssl-image-minimal`
- wolfSSL FIPS (auto-configured for libgcrypt support)
- libgcrypt 1.11.0 with wolfSSL backend
- libgcrypt-ptest (test suite)
- ptest-runner (test execution tool)

## Configuration

### In `build/conf/local.conf`:

```bitbake
# Enable demo images
WOLFSSL_DEMOS = "wolfssl-image-minimal libgcrypt-image-minimal"

# Configure FIPS bundle (use absolute path)
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

### Build:

```bash
bitbake libgcrypt-image-minimal
```

### Run in QEMU:

```bash
runqemu libgcrypt-image-minimal nographic
```

## Testing

Inside QEMU, run the libgcrypt test suite:

```bash
# Run all ptests
ptest-runner

# Run only libgcrypt tests
ptest-runner libgcrypt
```

### Expected Output

The libgcrypt test suite should pass with the wolfSSL backend:

```
START: ptest-runner
BEGIN: /usr/lib/libgcrypt/ptest
PASS: basic
PASS: mpitests
PASS: t-mpi-bit
PASS: curves
PASS: fips186-dsa
...
END: /usr/lib/libgcrypt/ptest
STOP: ptest-runner
```

## How It Works

### wolfssl-fips Configuration

The `wolfssl-fips.bbappend` in this directory automatically configures wolfssl-fips with features needed by libgcrypt:

```bitbake
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-enable-libgcrypt.inc
```

This adds:
- `--enable-fips=v5`
- `--enable-keygen`
- Required compile flags (`HAVE_AES_ECB`, `WC_RSA_DIRECT`, etc.)

### libgcrypt Configuration

The `libgcrypt_%.bbappend` conditionally switches libgcrypt to the wolfSSL backend when wolfssl-fips is the provider:

```bitbake
inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/libgcrypt/libgcrypt-enable-wolfssl.inc',
        allowed_providers=['wolfssl-fips']
    )
}
```

This:
- Switches to `github.com/wolfSSL/libgcrypt-wolfssl` source
- Configures with `--enable-wolfssl-fips`
- Adds wolfSSL dependencies

## Applications

With this image, any application using libgcrypt will automatically use FIPS-validated cryptography:

- **GnuPG**: Encryption, signing, key management
- **systemd**: System services encryption
- **NetworkManager**: WPA/WPA2 authentication
- **cryptsetup**: Disk encryption (LUKS)

## Requirements

- Valid wolfSSL FIPS commercial bundle
- wolfssl-fips configured as provider
- libgcrypt 1.11.0+ (provided by wolfSSL fork)

## Troubleshooting

### Test Failures

If ptests fail, check:

1. **FIPS hash is correct**: wolfSSL FIPS auto-hash should have generated the correct hash
2. **All features enabled**: Verify wolfssl-fips has all required flags (see `inc/wolfssl-fips/wolfssl-enable-libgcrypt.inc`)
3. **Dependencies**: Ensure wolfssl-fips is properly built and installed

### Build Errors

If build fails, ensure:

1. **FIPS bundle is accessible**: Check `WOLFSSL_SRC_DIR` in `conf/wolfssl-fips.conf`
2. **FIPS config is included**: `require conf/wolfssl-fips.conf` in `local.conf`
3. **Demo is enabled**: `WOLFSSL_DEMOS` includes both base and libgcrypt images

## More Information

- OSP Integration: [../../../recipes-support/libgcrypt/README.md](../../../recipes-support/libgcrypt/README.md)
- Main README: [../../../README.md](../../../README.md)
- libgcrypt-wolfssl: https://github.com/wolfSSL/libgcrypt-wolfssl
- wolfSSL FIPS: https://www.wolfssl.com/products/wolfssl-fips/
