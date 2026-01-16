# gnutls-image-minimal

Minimal demo image showcasing gnutls with wolfSSL FIPS backend.

## Overview

This image demonstrates gnutls configured to use wolfSSL's FIPS-validated wolfCrypt as its cryptographic backend. This allows any application using gnutls (wget, openldap etc...) to benefit from FIPS 140-3 validated cryptography.

## What's Included

- Everything from `wolfssl-image-minimal`
- wolfSSL FIPS (auto-configured for gnutls support)
- gnutls 3.8.9 with wolfSSL backend
- gnutls-wolfssl (test suite)

## Configuration

### In `build/conf/local.conf`:

```bitbake
# Enable demo images
WOLFSSL_DEMOS = "wolfssl-image-minimal gnutls-image-minimal"

# Configure FIPS bundle (use absolute path)
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

### Build:

```bash
bitbake gnutls-image-minimal
```

### Run in QEMU:

```bash
runqemu gnutls-image-minimal nographic
```

## Testing

Inside QEMU, run the gnutls test suite:

```bash
# Run all tests
cd /opt/wolfssl-gnutls-wrapper/tests/
make run_fips
```

### Expected Output

The gnutls test suite should pass with the wolfSSL backend, each test prints PASS/FAIL and a summary.
It also showcases all the logs of the wrapper whenever some gnutls cryptographic code
in an application is called.

## How It Works

### wolfssl-fips Configuration

The `wolfssl-fips.bbappend` in this directory automatically configures wolfssl-fips with features needed by gnutls:

```bitbake
require ${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-enable-gnutls.inc
```

This adds:
- `--enable-fips=v5`
- `--enable-keygen`
- Required compile flags (`HAVE_AES_ECB`, `WC_RSA_DIRECT`, etc.)

### gnutls Configuration

The `gnutls_%.bbappend` conditionally switches gnutls to the wolfSSL backend when wolfssl-fips is the provider:

```bitbake
inherit wolfssl-osp-support

python __anonymous() {
    wolfssl_osp_include_if_provider(
        d,
        inc_file='inc/gnutls/gnutls-enable-wolfssl.inc',
        allowed_providers=['wolfssl-fips']
    )
}
```

This:
- Switches to `github.com/wolfSSL/gnutls` source
- Configures with the configurations listed in `inc/gnutls/gnutls-enable-wolfssl.inc`
- Adds wolfSSL dependencies

## Applications

With this image, any application using gnutls will automatically use FIPS-validated cryptography:

## Requirements

- Valid wolfSSL FIPS commercial bundle
- wolfssl-fips configured as provider
- gnutls 3.8.9+ (provided by wolfSSL fork)

## Troubleshooting

### Test Failures

If ptests fail, check:

1. **FIPS hash is correct**: wolfSSL FIPS auto-hash should have generated the correct hash
2. **All features enabled**: Verify wolfssl-fips has all required flags (see `inc/wolfssl-fips/wolfssl-enable-gnutls.inc`)
3. **Dependencies**: Ensure wolfssl-fips is properly built and installed

### Build Errors

If build fails, ensure:

1. **FIPS bundle is accessible**: Check `WOLFSSL_SRC_DIR` in `conf/wolfssl-fips.conf`
2. **FIPS config is included**: `require conf/wolfssl-fips.conf` in `local.conf`
3. **Demo is enabled**: `WOLFSSL_DEMOS` includes both base and gnutls images

## More Information

- Main README: [../../../README.md](../../../README.md)
- gnutls-wolfssl: https://github.com/wolfSSL/gnutls-wolfssl
- wolfSSL FIPS: https://www.wolfssl.com/products/wolfssl-fips/
