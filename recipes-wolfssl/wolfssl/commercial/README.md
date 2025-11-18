# Yocto wolfssl FIPS and Commerical Setup Instructions

## Prerequisites

- Yocto environment is set up and ready.

## Steps

1. **Clone the meta-wolfssl Repository**

   ```bash
   git clone https://github.com/wolfSSL/meta-wolfssl.git
   ```

2. **Add meta-wolfssl to Yocto's bblayers.conf**

   Add the path to meta-wolfssl in the `bblayers.conf` file, typically found under `poky/build/conf/`:
   ```bash
   BBLAYERS ?= " \
         ...
         /path/to/yocto/poky/meta-wolfssl \
         ...
      "
   ```

3. **Update the IMAGE_INSTALL and WOLFSSL_TYPE Variable**

   Add `wolfssl` and `wolfcrypttest` to the `IMAGE_INSTALL` then add `fips` or `commerical` to the `WOLFSSL_TYPE` variables in your recipe or `poky/build/conf/local.conf`. If using `poky/build/conf/local.conf`, append as follows:
   ```
   IMAGE_INSTALL:append = " wolfssl wolfcrypttest "
   WOLFSSL_TYPE = "fips"
   ```

   If using other products with their commercial varient, make sure to set those variables to the `commerical` type:
    ```
    WOLFTPM_TYPE = "commercial"
    WOLFSSH_TYPE = "commercial"
    WOLFMQTT_TYPE = "commercial"
    WOLFCLU_TYPE = "commercial"
    ```

4. **Move the Downloaded FIPS/Commercial Bundle**

   Move or copy the downloaded `wolfssl-x.x.x-*.(7z|tar.gz)` file to the appropriate directory within the meta-wolfssl repository:
   ```
   cp /path/to/wolfssl-x.x.x-*.tar.gz /path/to/meta-wolfssl/recipes-wolfssl/wolfssl/commerical/files
   # or
   cp /path/to/wolfssl-x.x.x-*.7z /path/to/meta-wolfssl/recipes-wolfssl/wolfssl/commerical/files
   ```

    Each product that has commerical support has their own respective directory structures to place their bundles.

5. **Edit poky/build/conf/local.conf**

    Update/Add the variables in your project's `poky/build/conf/local.conf`:
    `WOLFSSL_VERSION = "x.x.x"`: x.x.x should be the version of the fips/commercial bundle you downloaded. 
    `WOLFSSL_SRC_SHA = "<SHA_HASH>"`: `<SHA_HASH>` This is the sha hash given when you received the bundle.
    `WOLFSSL_SRC_PASS = "<PASSWORD>"`: `<PASSWORD>` This is the password given to unarchive the bundle (leave empty for `.tar.gz` archives).
    `WOLFSSL_SRC = "<BUNDLE_NAME>"`: `<BUNDLE_NAME>` This is the logical name of the bundle without the extension.
    `WOLFSSL_BUNDLE_FILE = "<FILENAME>"`: Optional override when the archive uses `.tar.gz` (for `.7z`, omit and it will default to `<BUNDLE_NAME>.7z`).

6. **Clean and Build wolfssl and wolfcrypttest**

   Ensure any artifacts from old builds are cleaned up, and then build `wolfssl` and `wolfcrypttest` with no errors:
   ```bash
   bitbake -c cleanall wolfssl
   bitbake -c cleanall wolfcrypttest
   bitbake wolfssl
   bitbake wolfcrypttest
   ```

7. **Compile Your Image**

   Perform a bitbake on your image recipe, for example: `bitbake core-image-minimal`.

8. **Extract the Hash Value**

    Skip to Step:10 if you are using the commercial bundle of wolfssl

    After compiling the image, extract the hash through QEMU or by loading the image on hardware. Use `runqemu nographic` for testing with QEMU.

    Once you are inside the qemu image and logged in use the command `wolfcrypttest`. This should produce the following error:

    ```
    in my Fips callback, ok = 0, err = -203
    message = In Core Integrity check FIPS error
    hash = <HASH_VALUE>
    In core integrity hash check failure, copy above hash
    into verifyCore[] in fips_test.c and rebuild
    RANDOM   test failed!
    error L=15305 code=-197 (FIPS mode not allowed error)
    [fiducial line numbers: 7943 25060 37640 49885]
    Exiting main with return code: -1
    ```

    Copy or write down the resulting `<HASH_VALUE>`, then exit the qemu image

9. ** Update/Add the variables in your project's `build/conf/local.conf`:**

    Open `build/conf/local.conf`: file in a text editor and add/update the `<FIPS_HASH>` variable with the copied `<HASH_VALUE>`.

    `FIPS_HASH = "<HASH_VALUE>"`

10. **Rebuild and Test**

    Perform bitbake on wolfssl and wolfcrypttest again to ensure they compile correctly. Rebuild your image and test with QEMU as before. The command `wolfcrypttest` should result in no errors.
