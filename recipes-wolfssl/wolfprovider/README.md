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
    
    To enable replace-default mode, simply uncomment the mode you want in the `.inc` files here `recipes-core/images/wolfprovider-image-minimal/openssl_%.bbappend`

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

### Testing wolfprovider

After building and deploying your image to the target device, you can test `wolfprovider` functionality with three test suites:

1. **Environment Setup and Verification**:

    ```sh
    wolfproviderenv
    ```
    
    This sets up the environment and verifies wolfProvider is correctly installed and loaded. It automatically detects replace-default mode.

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

### Demo Image

A demo image is provided to verify wolfProvider works:

**wolfprovider-image-minimal**: Demonstrates wolfProvider with all test suites
```bash
# In local.conf
WOLFSSL_DEMOS = "wolfprovider-image-minimal"

# Build
bitbake wolfprovider-image-minimal
```

### Documentation and Support

For further information about `wolfprovider` and `wolfssl`, visit the [wolfSSL Documentation](https://www.wolfssl.com/docs/) and the [wolfProvider Github](https://www.github.com/wolfSSL/wolfprovider). If you encounter issues or require support regarding the integration of `wolfprovider` with Yocto, feel free to reach out through [wolfSSL Support](support@wolfssl.com).
