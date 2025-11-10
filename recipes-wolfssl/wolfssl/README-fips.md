# wolfSSL FIPS Recipe

This directory contains the `wolfssl-fips` recipe for building FIPS 140-3 validated wolfSSL.

## Requirements

### Layer Dependencies

The `wolfssl-fips` recipe requires the following layers **only when actively building FIPS**:

1. **meta-openembedded/meta-oe** - Provides `p7zip-native` for extracting commercial bundles

**Note**: If you're not using FIPS (i.e., `WOLFSSL_SRC` is not configured), the `p7zip-native` dependency is automatically skipped, so you don't need meta-oe. This allows CI environments to parse the layer without requiring additional dependencies.

When building with FIPS, add to your `bblayers.conf`:
```
BBLAYERS ?= " \
  /path/to/poky/meta \
  /path/to/poky/meta-poky \
  /path/to/poky/meta-yocto-bsp \
  /path/to/meta-openembedded/meta-oe \
  /path/to/meta-wolfssl \
"
```

### Configuration

See the main README.md for detailed FIPS configuration instructions, including:
- Creating `conf/wolfssl-fips.conf` from the `.sample` template
- Setting `PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"`
- Configuring FIPS hash modes (manual vs auto)

## Note

The `wolfssl-fips` recipe is disabled by default (`DEFAULT_PREFERENCE = "-1"`). It will only be built when explicitly selected as the provider for `virtual/wolfssl` in your configuration.

If you're not using FIPS, you can ignore this recipe - it won't affect your builds.

