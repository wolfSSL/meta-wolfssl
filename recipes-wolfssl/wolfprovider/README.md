# wolfProvider

The `wolfprovider` recipe enables the integration of wolfSSL's cryptographic functionalities into OpenSSL through a custom provider mechanism. This integration allows applications using OpenSSL to leverage wolfSSL's advanced cryptographic algorithms, combining wolfSSL's lightweight and performance-optimized cryptography with OpenSSL's extensive API and capabilities. `wolfprovider` is designed for easy integration into Yocto-based systems, ensuring a seamless blend of security and performance ideal for embedded and constrained environments.

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

    Modify your image recipe or `local.conf` file to include `wolfprovider`, `wolfssl`, `openssl`, `openssl-bin`, and `wolfprovidertest`. You will only need `openssl-bin` and `wolfprovidertest` if you want to use and test with our included example and conf file.

    ```bitbake
    IMAGE_INSTALL += "wolfprovider wolfssl openssl openssl-bin wolfprovidertest"
    ```

4. **Build Your Image**:

    With the `meta-wolfssl` layer added and the necessary packages included in your image configuration, proceed to build your Yocto image as usual.

    ```sh
    bitbake <your_image_recipe_name>
    ```

### Testing wolfprovider

After building and deploying your image to the target device, you can test `wolfprovider` functionality through the `wolfproviderenv` script.

1. **Execute the wolfproviderenv Script**:

    `wolfproviderenv` is located in `/usr/bin`, so just execute the script upon entering into your terminal.

    ```sh
    wolfproviderenv
    ```

    The script performs necessary setup actions, executes `wolfprovidertest` to validate the integration, and lists available OpenSSL providers to confirm `wolfprovider` is active and correctly configured.

2. **Expected Output**:

    Look for messages indicating a successful environment setup, execution of `wolfprovidertest` with a custom provider loaded successfully, and `libwolfprovider` listed among active OpenSSL providers.

### Documentation and Support

For further information about `wolfprovider` and `wolfssl`, visit the [wolfSSL Documentation](https://www.wolfssl.com/docs/) and the [wolfProvider Github](https://www.github.com/wolfSSL/wolfprovider). If you encounter issues or require support regarding the integration of `wolfprovider` with Yocto, feel free to reach out through [wolfSSL Support](support@wolfssl.com).
