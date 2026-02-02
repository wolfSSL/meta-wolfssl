# wolfSSL Demo Images

This directory contains demonstration images for testing various wolfSSL sub-packages. Each image is a minimal Yocto image based on `core-image-minimal` with specific wolfSSL components installed and configured.

## Enabling Demo Images

To enable a demo image, add the following to your `conf/local.conf`:

```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal <image-name>"
```

**Important:** All demo images (except `wolfssl-image-minimal` itself) require `wolfssl-image-minimal` to be included in `WOLFSSL_DEMOS` because they inherit from it.

You can then build the image with:

```bash
bitbake <image-name>
```

## Available Demo Images

### 1. wolfssl-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal"
```

**Provides:**
- wolfSSL library (with reproducible build configuration)
- wolfcrypttest - wolfSSL crypto test suite
- wolfcryptbenchmark - wolfSSL crypto benchmark utility

**Description:** Base minimal image with wolfSSL and its core crypto testing tools. This serves as the foundation for all other demo images.

---

### 2. wolfclu-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfclu-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfCLU - Command-line utility for wolfSSL crypto operations

**Description:** Demonstrates wolfCLU command-line tools for performing cryptographic operations.

---

### 3. wolftpm-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolftpm-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfTPM library
- wolftpm-wrap-test - wolfTPM wrapper test application
- TPM 2.0 tools (tpm2-tools, tpm2-tss, libtss2)
- bash shell

**Requirements:**
Add to your `conf/local.conf`:
```bitbake
DISTRO_FEATURES += "security tpm tpm2"
MACHINE_FEATURES += "tpm tpm2"
KERNEL_FEATURES += "features/tpm/tpm.scc"
```

**Description:** Demonstrates wolfTPM integration with TPM 2.0 hardware/software support. Includes validation checks to ensure TPM features are properly enabled.

**Testing:** 
1. Use the included `test-wolftpm.sh` script in the image directory to run the image with a software TPM simulator (swtpm) in QEMU
2. Once booted into the QEMU image, run the test binary:
   ```bash
   /usr/bin/wolftpm-wrap-test
   ```

---

### 4. wolfssl-py-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfssl-py-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfssl-py - Python bindings for wolfSSL/TLS
- wolfcrypt-py - Python bindings for wolfCrypt
- wolf-py-tests - Test suite for Python bindings
- Python 3 with cffi and pytest

**Description:** Demonstrates Python integration with wolfSSL. A simple image focused on Python bindings without additional networking features.

**Note:** For all wolfssl-py tests to pass, you will need to configure networking in the QEMU environment (DNS resolvers, network connectivity, etc.).

---

### 5. wolfprovider-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfprovider-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfProvider - OpenSSL 3.x provider using wolfSSL
- wolfprovidertest - Test application for wolfProvider
- OpenSSL 3.x library and binaries
- bash shell

**Description:** Demonstrates wolfProvider as an OpenSSL 3.x provider, allowing OpenSSL 3.x applications to use wolfSSL's crypto implementation. The image includes OpenSSL configured for wolfProvider compatibility.

---

### 6. wolfssl-combined-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfssl-combined-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfssh - SSH library implementation
- wolfmqtt - MQTT client library
- wolfProvider with OpenSSL 3.x
- wolfprovidertest
- wolftpm with wrap-test and TPM 2.0 tools
- bash shell

**Requirements:**
Add to your `conf/local.conf`:
```bitbake
DISTRO_FEATURES += "security tpm tpm2"
MACHINE_FEATURES += "tpm tpm2"
KERNEL_FEATURES += "features/tpm/tpm.scc"
```

**Description:** A comprehensive image combining multiple wolfSSL sub-packages (SSH, MQTT, Provider, TPM) for testing interoperability and integration scenarios.

---

### 7. wolfclu-combined-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfclu-combined-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfCLU - Command-line utility
- wolfssl-py - Python bindings for wolfSSL/TLS
- wolfcrypt-py - Python bindings for wolfCrypt
- wolf-py-tests - Python test suite
- Python 3 with cffi and pytest
- Networking support with DNS configuration
- ca-certificates

**Description:** Combines wolfCLU command-line tools with Python bindings, providing both CLI and Python interfaces to wolfSSL. Includes automatic DNS configuration for network-based Python tests.

---

### 8. libgcrypt-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal libgcrypt-image-minimal"
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfSSL FIPS (configured for libgcrypt support)
- libgcrypt 1.11.0 with wolfSSL backend
- libgcrypt-ptest - Test suite
- ptest-runner - Test execution tool

**Special Requirements:**
- Requires wolfSSL FIPS commercial bundle
- Must set `require conf/wolfssl-fips.conf` in `local.conf`

**Description:** Demonstrates libgcrypt configured to use wolfSSL FIPS as the cryptographic backend. This enables FIPS 140-3 validated cryptography for all applications using libgcrypt (GnuPG, systemd, NetworkManager, cryptsetup, etc.).

**Testing:**
```bash
# In QEMU
ptest-runner libgcrypt
```

**More Information:**
- [OSP Integration README](../../recipes-support/libgcrypt/README.md)
- [Image-specific README](libgcrypt-image-minimal/README.md)

---

### 9. gnutls-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal gnutls-image-minimal"
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- wolfSSL FIPS (configured for gnutls support)
- gnutls with wolfSSL FIPS backend
- gnutls-dev, gnutls-bin, gnutls-fips
- wolfssl-gnutls-wrapper
- nettle, pkgconfig

**Special Requirements:**
- Requires wolfSSL FIPS commercial bundle
- Must set `require conf/wolfssl-fips.conf` in `local.conf`

**Description:** Demonstrates gnutls configured to use wolfSSL FIPS as the cryptographic backend. This enables FIPS 140-3 validated cryptography for all applications using gnutls.

**More Information:**
- [Image-specific README](gnutls-image-minimal/README.md)

---

### 10. gnutls-nonfips-image-minimal

**Enable with:**
```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal gnutls-nonfips-image-minimal"
```

**Provides:**
- Everything from `wolfssl-image-minimal`
- gnutls with standard wolfSSL backend (non-FIPS)
- gnutls-dev, gnutls-bin
- wolfssl-gnutls-wrapper
- nettle, pkgconfig

**Description:** Demonstrates gnutls configured to use standard wolfSSL (non-FIPS) as the cryptographic backend. Use this for testing gnutls+wolfSSL integration without FIPS requirements.

---

## Image Structure

All demo images follow this structure:

```
recipes-core/images/<image-name>/
├── <image-name>.bb              # Main image recipe
├── wolfssl_%.bbappend           # Configure wolfSSL for this image
├── <package>_%.bbappend         # Disable feature checks for included packages
└── (optional) test scripts      # Helper scripts for testing
```

## Configuration Method

These images use **Manual Configuration** (Method 3 from the main README):

1. **Image recipes** explicitly list packages in `IMAGE_INSTALL:append`
2. **wolfssl_%.bbappend** includes the necessary `inc/<package>/wolfssl-enable-<package>.inc` files to configure wolfSSL with required features
3. **Package bbappends** include `inc/wolfssl-manual-config.inc` to disable the automatic feature check

This approach ensures wolfSSL is built with the correct configuration for each image's packages without requiring global `WOLFSSL_FEATURES` or `IMAGE_INSTALL` settings.

## Building Multiple Images

You can enable multiple demo images by space-separating them. **Remember to always include `wolfssl-image-minimal` first:**

```bitbake
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfclu-image-minimal wolfssl-py-image-minimal"
```

Then build each image individually:

```bash
bitbake wolfssl-image-minimal
bitbake wolfclu-image-minimal
bitbake wolfssl-py-image-minimal
```

**Note:** The base `wolfssl-image-minimal` must be included in `WOLFSSL_DEMOS` for any other demo image to be parsable by BitBake.

## Running Images

After building, run images with QEMU using:

```bash
runqemu <image-name>
```

For images with special requirements (like `wolftpm-image-minimal`), use the provided test scripts in the image directory.

## Notes

- All images inherit from `core-image-minimal` for a minimal footprint
- wolfSSL is always built with reproducible build flags
- Images with networking include DNS configuration for internet connectivity in QEMU
- TPM images require additional DISTRO/MACHINE feature configuration
- All images include the base crypto tests (wolfcrypttest, wolfcryptbenchmark)

