# wolfProvider

The `wolfprovider` recipe enables the integration of wolfSSL's cryptographic functionalities into OpenSSL through a custom provider mechanism. This integration allows applications using OpenSSL to leverage wolfSSL's advanced cryptographic algorithms, combining wolfSSL's lightweight and performance-optimized cryptography with OpenSSL's extensive API and capabilities. `wolfprovider` is designed for easy integration into Yocto-based systems, ensuring a seamless blend of security and performance ideal for embedded and constrained environments.

The `wolfprovidertest` yocto package will provide two apps, `wolfproviderenv` and `wolfprovidertest`. Running `wolfproviderenv` will start up a child shell and run `wolfprovidertest`. Use `wolfproviderenv` to test that the `wolfprovider` package is succesfully installed. If you want to run `wolfprovidertest` directly you will need to directly source `wolfproviderenv` via `source /usr/bin/wolfproviderenv` or setup the env on your own, because `wolfprovidertest` will fail otherwise. Use `wolfprovidertest` to check that your shell env is correctly setup.

## Getting Started

### Prerequisites

- A functioning Yocto Project environment (Kirkstone or later recommended)
- OpenSSL 3.0 or later, supporting the provider interface (Come by default with Kirkstone or later)
- Access to the `meta-wolfssl` repository

### Integrating wolfprovider with Yocto

1. **Clone the meta-wolfssl repository**:

    Clone the `meta-wolfssl` repository into your Yocto project's sources directory if not already included in your project.

    ```sh
    git clone https://github.com/wolfSSL/meta-wolfssl.git
    ```

2. **Include meta-wolfssl in your bblayers.conf**:

    Add `meta-wolfssl` to your `bblayers.conf` file to incorporate it into your build environment.

    ```bitbake
    BBLAYERS ?= " \
      ...
      /path/to/meta-wolfssl \
      ...
    "
    ```

3. **Add wolfprovider to your image**:

    Enable the wolfprovider demo image in your `local.conf` file:
    ```bitbake
    WOLFSSL_DEMOS = "wolfprovider-image-minimal"
    ```

4. **Configure wolfProvider Mode (Optional)**:

    wolfProvider can operate in two modes:
    
    **Normal Mode (Default)**: wolfProvider acts as a supplementary provider alongside OpenSSL's default provider. No configuration needed.
    
    **Replace-Default Mode**: wolfProvider replaces OpenSSL's default provider by patching OpenSSL, making wolfSSL the primary crypto backend.
    
    To enable and disable modes like FIPS, replace default, etc. for testing you can use these files:
    `layers/meta-wolfssl/recipes-core/images/wolfprovider-image-minimal/wolfssl_%.bbappend`
    `layers/meta-wolfssl/recipes-core/images/wolfprovider-image-minimal/openssl_%.bbappend`

    to rebuild with replace default we need to run a clean on the wolfprovider and openssl then rebuild: 

    ```sh
    bitbake -c cleanall openssl wolfprovider
    bitbake wolfprovider-image-minimal
    ```

5. **Build Your Image**:

    With the `meta-wolfssl` layer added and the necessary packages included in your image configuration, proceed to build your Yocto image as usual.

    ```sh
    bitbake wolfprovider-image-minimal
    ```

## Testing wolfProvider

After building and deploying your image to the target device, you can test `wolfprovider` functionality with three test suites:

1. **Environment Setup and Verification**:

    ```sh
    wolfproviderenv
    ```
    
    This sets up the environment and verifies wolfProvider is correctly installed and loaded. It automatically detects the mode you are in and does the neccesary things to prepare the env for testing.

2. **Unit Tests**:

    ```sh
    wolfprovidertest
    ```
    
    Runs the comprehensive wolfProvider unit test suite from the upstream wolfProvider repository. Tests cover all cryptographic operations.

3. **Command-Line Tests**:

    ```sh
    wolfprovidercmd
    ```
    
    Runs OpenSSL command-line tests including:
    - Hash operations (SHA, MD5, etc.)
    - AES encryption/decryption
    - RSA operations
    - ECC operations
    - Certificate operations

## Demo Image

See `recipes-core/images/wolfprovider-image-minimal/` for complete working examples of all configurations.
Refer to the [recipes-core/images/wolfprovider-image-minimal/README.md](recipes-core/images/wolfprovider-image-minimal/README.md) file for more information.

### Integrating wolfProvider with Custom Image

To integrate wolfProvider into your own image recipe (not using the demo images), directly require the appropriate `.inc` files in `bbappend` files.

#### Direct Include in bbappend Files

Create `bbappend` files in your custom layer that directly require the `.inc` files you need.

**1. Create `recipes-wolfssl/wolfssl/wolfssl_%.bbappend` in your layer:**

For non-FIPS:
```bitbake
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider.inc
```

For FIPS:
```bitbake
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/wolfssl-enable-wolfprovider-fips.inc
```

**2. Create `recipes-connectivity/openssl/openssl_%.bbappend` in your layer:**

For standalone mode:
```bitbake
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider.inc
```

For replace-default mode:
```bitbake
require ${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default.inc
```

**3. Add packages to your image recipe:**

```bitbake
# In your-image.bb
IMAGE_INSTALL:append = " \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfproviderenv \
    wolfprovidercmd \
"

**3. For FIPS mode, configure in `local.conf`:**

```bitbake
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

**See working examples:**
- `recipes-core/images/wolfprovider-image-minimal/wolfprovider-image-minimal/` (standalone, non-FIPS)
- `recipes-core/images/wolfprovider-image-minimal/wolfprovider-fips-image-minimal/` (standalone, FIPS)
- `recipes-core/images/wolfprovider-image-minimal/wolfprovider-replace-default-image-minimal/` (replace-default, non-FIPS)
- `recipes-core/images/wolfprovider-image-minimal/wolfprovider-replace-default-fips-image-minimal/` (replace-default, FIPS)

#### Using WOLFSSL_FEATURES (For Testing/Development)

If you want conditional configuration based on variables, you can use the existing `bbappend` files in `recipes-wolfssl/wolfprovider/`:

Add to your `local.conf`:

```bitbake
# Enable wolfProvider feature
WOLFSSL_FEATURES = "wolfprovider"

# For replace-default mode (optional)
WOLFPROVIDER_MODE = "replace-default"

# For FIPS mode (optional)
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

Then add packages to your image recipe:

```bitbake
# In your-image.bb
IMAGE_INSTALL:append = " \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfproviderenv \
    wolfprovidercmd \
"
```

The following existing files will automatically handle configuration:
- `recipes-wolfssl/wolfprovider/wolfssl_%.bbappend` - Configures wolfSSL with wolfProvider support
- `recipes-wolfssl/wolfprovider/openssl_3.%.bbappend` - Configures OpenSSL for wolfProvider

#### Available Reusable Files

**`.inc` files in `inc/wolfprovider/`:**
- `wolfssl-enable-wolfprovider.inc` - Configure wolfSSL for wolfProvider (non-FIPS)
- `wolfssl-enable-wolfprovider-fips.inc` - Configure wolfSSL for wolfProvider (FIPS)
- `openssl/openssl-enable-wolfprovider.inc` - Configure OpenSSL for standalone mode
- `openssl/openssl-enable-wolfprovider-replace-default.inc` - Configure OpenSSL for replace-default mode
- `wolfssl-enable-wolfprovidertest.inc` - Enable unit tests (optional only for standalone mode)

**Existing `bbappend` files in `recipes-wolfssl/wolfprovider/`:**
- `wolfssl_%.bbappend` - Automatically configures wolfSSL based on `WOLFSSL_FEATURES`
- `openssl_3.%.bbappend` - Automatically configures OpenSSL based on `WOLFPROVIDER_MODE`

**Demo implementations:**
See `recipes-core/images/wolfprovider-image-minimal/` for complete working examples of all configurations.

#### Building Your Image

After setting up your configuration:

```bash
# Clean state if switching modes or providers
bitbake -c cleanall openssl wolfprovider

# Build your image
bitbake your-image
```

#### Verifying Integration

On your target device:

```bash
wolfproviderenv
```

## Documentation and Support

For further information about `wolfprovider` and `wolfssl`, visit the [wolfSSL Documentation](https://www.wolfssl.com/docs/) and the [wolfProvider Github](https://www.github.com/wolfSSL/wolfprovider). If you encounter issues or require support regarding the integration of `wolfprovider` with Yocto, feel free to reach out through [wolfSSL Support](support@wolfssl.com).
