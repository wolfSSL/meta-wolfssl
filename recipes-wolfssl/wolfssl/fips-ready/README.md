# Yocto wolfSSL FIPS Ready Setup Instructions

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

   Add `wolfssl` and `wolfcrypttest` to the `IMAGE_INSTALL` then add `fips-ready` to the `WOLFSSL_TYPE` variables in your recipe or `poky/conf/local.conf`. If using `poky/conf/local.conf`, append as follows:
   ```bash
   IMAGE_INSTALL:append = " wolfssl wolfcrypttest "
   WOLFSSL_TYPE = "fips-ready"
   ```

4. **Download the FIPS-Ready Package**

   Download the FIPS-ready package from wolfSSL's [download page](https://www.wolfssl.com/download/). The file to download is `wolfssl-x.x.x-gplv3-fips-ready.zip`.

5. **Move the Downloaded FIPS-Ready Bundle**

   Move or copy the downloaded `wolfssl-x.x.x-gplv3-fips-ready.zip` file to the appropriate directory within the meta-wolfssl repository:
   ```
   cp /path/to/wolfssl-x.x.x-gplv3-fips-ready.zip /path/to/meta-wolfssl/recipes-wolfssl/wolfssl/fips-ready/files
   ```

6. **Edit fips-ready-details/wolfssl_%.bbappend**

    Using a test editor update the file `/path/to/meta-wolfssl/recipes-wolfssl/wolfssl/fips-ready/fips-ready-details/wolfssl_%.bbappend`
    Update the variables:
    `WOLFSSL_VERSION = "x.x.x"`: x.x.x should be the version of the fips-ready bundle you downloaded. 
    `WOLF_SRC_SHA = "<SHA_HASH>"`: `<SHA_HASH>` should be the sha hash posted under the bundle on the wolfssl download page.

7. **Clean and Build wolfSSL and wolfcrypttest**

   Ensure any artifacts from old builds are cleaned up, and then build `wolfssl` and `wolfcrypttest` with no errors:
   ```bash
   bitbake -c cleanall wolfssl
   bitbake -c cleanall wolfcrypttest
   bitbake wolfssl
   bitbake wolfcrypttest
   ```

8. **Compile Your Image**

   Perform a bitbake on your image recipe, for example: `bitbake core-image-minimal`.

9. **Extract the Hash Value**

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

10. **Edit the .bbappend File**

    Open  `/path/to/meta-wolfssl/recipes-wolfssl/wolfssl/fips-ready/fips-ready-details/wolfssl_%.bbappend` file in a text editor and update the `<FIPS_HASH>` variable with the copied `<HASH_VALUE>`.

    `FIPS_HASH="<HASH_VALUE>"`

11. **Rebuild and Test**

    Perform bitbake on wolfssl and wolfcrypttest again to ensure they compile correctly. Rebuild your image and test with QEMU as before. The command `wolfcrypttest` should result in no errors.

