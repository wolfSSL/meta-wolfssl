# wolfEngine

The `wolfengine` recipe enables the integration of wolfSSL's cryptographic functionalities into OpenSSL through a custom engine mechanism. This integration allows applications using OpenSSL to leverage wolfSSL's advanced cryptographic algorithms, combining wolfSSL's lightweight and performance-optimized cryptography with OpenSSL's extensive API and capabilities. `wolfengine` is designed for easy integration into Yocto-based systems, ensuring a seamless blend of security and performance ideal for embedded and constrained environments.

The `wolfenginetest` yocto package will provide two apps, `wolfengineenv` and `wolfenginetest`. Running `wolfengineenv` will start up a child shell and run `wolfenginetest`. Use `wolfengineenv` to test that the `wolfengine` package is succesfully installed. If you want to run `wolfenginetest` directly you will need to directly source `wolfengineenv` via `source /usr/bin/wolfengineenv` or setup the env on your own, because `wolfenginetest` will fail otherwise. Use `wolfenginetest` to check that your shell env is correctly setup.

## Getting Started

### Prerequisites

- A functioning Yocto Project environment (Dunfell or earlier recommended)
- OpenSSL versions 1.x.x, supporting the engine interface (Come by default with Dunfell or earlier)
- Access to the `meta-wolfssl` repository

### Integrating wolfengine with Yocto

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

3. **Add wolfengine to your image**:

    Modify your image recipe or `local.conf` file to include `wolfengine`, `wolfssl`, `openssl`, `openssl-bin`, and `wolfenginetest`. You will only need `openssl-bin` and `wolfenginetest` if you want to use and test with our included example and conf file.

    For yocto kirkstone or newer:
    ```
    IMAGE_INSTALL:append = "wolfengine wolfssl openssl openssl-bin wolfenginetest"
    ```

    For yocto dunfell or earlier:
    ```
    IMAGE_INSTALL_append = "wolfengine wolfssl openssl openssl-bin wolfenginetest"
    ```


4. **Build Your Image**:

    With the `meta-wolfssl` layer added and the necessary packages included in your image configuration, proceed to build your Yocto image as usual.

    ```sh
    bitbake <your_image_recipe_name>
    ```

### Testing wolfengine

After building and deploying your image to the target device, you can test `wolfengine` functionality through the `wolfengineenv` script.

1. **Execute the wolfengineenv Script**:

    `wolfengineenv` is located in `/usr/bin`, so just execute the script upon entering into your terminal.

    ```sh
    wolfengineenv
    ```

    The script performs necessary setup actions, executes `wolfenginetest` to validate the integration.

2. **Expected Output**:

    Look for messages indicating a successful environment setup, and execution of `wolfenginetest`.

### Documentation and Support

For further information about `wolfengine` and `wolfssl`, visit the [wolfSSL Documentation](https://www.wolfssl.com/docs/) and the [wolfEngine Github](https://www.github.com/wolfSSL/wolfengine). If you encounter issues or require support regarding the integration of `wolfengine` with Yocto, feel free to reach out through [wolfSSL Support](support@wolfssl.com).
