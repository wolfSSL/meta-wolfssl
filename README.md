meta-wolfssl
==========

This layer provides both [Yocto](https://www.yoctoproject.org/) and
[OpenEmbedded](http://www.openembedded.org/wiki/Main_Page) recipes for wolfSSL
products and examples, as well as .bbappend files for configuring common open
source packages and projects with support for wolfSSL.

This layer currently provides recipes for the following wolfSSL products:

- [wolfSSL embedded SSL/TLS library](https://www.wolfssl.com/products/wolfssl/)
- [wolfSSH lightweight SSH library](https://www.wolfssl.com/products/wolfssh/)
- [wolfMQTT lightweight MQTT client library](https://www.wolfssl.com/products/wolfmqtt/)
- [wolfTPM portable TPM 2.0 library](https://www.wolfssl.com/products/wolftpm/)
- [wolfSSL-py A Python wrapper for the wolfSSL library](https://github.com/wolfSSL/wolfssl-py)
- [wolfCrypt-py A Python Wrapper for the wolfCrypt API](https://github.com/wolfSSL/wolfcrypt-py)
- [wolfPKCS11 A PKCS#11 implementation using wolfSSL](https://github.com/wolfSSL/wolfpkcs11)

This layer also provides Open Source Package (OSP) integrations:

- [libgcrypt with wolfSSL backend](recipes-support/libgcrypt/README.md) - Use wolfSSL FIPS as the crypto backend for libgcrypt

These recipes have been tested using these versions of yocto:

- Scarthgap     (v5.0)
- Nanbield      (v4.3)
- Langdale      (v4.1)
- Kirkstone     (v4.0)
- Hardknott     (v3.3)
- Gatesgarth    (v3.2)
- Dunfell       (v3.1)
- Zeus          (v3.0)
- Thud          (v2.6)
- Sumo          (v2.5)

The wolfSSL library recipe is also included in the openembedded meta-networking
layer, located [here](https://github.com/openembedded/meta-openembedded/tree/master/meta-networking/recipes-connectivity/wolfssl).

wolfSSL is a lightweight SSL/TLS library written in C and targeted at embedded
and RTOS environments - primarily because of its small size, speed, and
feature set. With common build sizes between 20-100kB, it is typically up to
20 times smaller than OpenSSL. Other feature highlights include support for
[TLS 1.3](https://www.wolfssl.com/tls13) and DTLS 1.2, full client and server
support, abstraction layers for easy porting, CRL and OCSP support, key and cert
generation, support for hardware cryptography modules, and much more. For a full
feature list, please visit the
[wolfSSL product page](https://www.wolfssl.com/products/wolfssl/).

Setup
-----

Clone meta-wolfssl onto your machine:

```
git clone https://github.com/wolfSSL/meta-wolfssl.git
```

### Layer Dependencies

**For FIPS Builds Only:** If you plan to use the `wolfssl-fips` recipe, you must also include the `meta-openembedded/meta-oe` layer, which provides `p7zip-native` for extracting commercial FIPS bundles. Non-FIPS builds do not require this dependency.

```
git clone https://github.com/openembedded/meta-openembedded.git
```

After installing your build's Yocto/OpenEmbedded components:

1.  Insert the 'meta-wolfssl' layer in `build/conf/bblayers.conf` location
    into your build's bblayers.conf
    file, in the BBLAYERS section:

    **For non-FIPS builds:**
    ```
    BBLAYERS ?= " \
       ...
       /path/to/yocto/poky/meta-wolfssl \
       ...
    "
    ```

    **For FIPS builds (includes meta-oe):**
    ```
    BBLAYERS ?= " \
       ...
       /path/to/meta-openembedded/meta-oe \
       /path/to/yocto/poky/meta-wolfssl \
       ...
    "
    ```

2.  Once the 'meta-wolfssl' layer has been added to your BBLAYERS collection,
    you have two options

    1.  If you want to directly add wolfSSL recipes to your image recipe
        proceed to step 3.


    2.  If you want to run `bitbake wolf*` on a particular recipe then it needs
        to be added to the IMAGE_INSTALL.
        This can be done by adding the following line to `local.conf` located in
        `path/to/poky/build/conf`.
        - For Dunfell and newer versions of Yocto:
        ```
        IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfpkcs11 "
        ```

        - For versions of Yocto older than Dunfell:

        ```
        IMAGE_INSTALL_append = " wolfssl wolfssh wolfmqtt wolftpm wolfpkcs11 "
        ```

        ```
        $ bitbake wolfssl
        $ bitbake wolfssh
        $ bitbake wolfmqtt
        $ bitbake wolftpm
        $ bitbake wolfclu - This command would result in an error
        $ bitbake wolfpkcs11
        ```


3.  Edit your build's local.conf file to install the recipes you would like
    to include (ie: wolfssl, wolfssh, wolfmqtt, wolftpm)

    - For Dunfell and newer versions of Yocto

    ```
    IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfpkcs11 "
    ```

    - For versions of Yocto older than Dunfell
    ```
    IMAGE_INSTALL_append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfpkcs11 "
    ```

    This will add the necassary --enable-* options necassary to use your
    specific combination of recipes.

    If you did step 2.2 make sure you comment out recipes that you don't desire
    because leaving them uncommented may add unneed --enable-* options in your
    build, which could increase the size of the build and turn on uneeded
    features.

Using WOLFSSL_FEATURES Variable
--------------------------------

As an alternative to `IMAGE_INSTALL`, you can use the `WOLFSSL_FEATURES` variable 
in your `local.conf` to enable specific wolfSSL features. This ensures wolfSSL 
packages are configured correctly but doesn't automatically add them to every 
image recipe:

```
WOLFSSL_FEATURES:append = " wolfclu wolfssh wolfmqtt wolftpm"
```

Add this to your `build/conf/local.conf` file.

When you specify a package in `WOLFSSL_FEATURES` or `IMAGE_INSTALL`, the layer 
automatically configures wolfSSL with the necessary `--enable-*` options for that 
package. The key difference:
- `IMAGE_INSTALL`: Adds packages to your image AND configures wolfSSL
- `WOLFSSL_FEATURES`: Only configures wolfSSL, packages must be added separately

**Method 3: Manual .bbappend (Advanced)**

If you don't want to use `IMAGE_INSTALL` or `WOLFSSL_FEATURES`, you can manually 
create a `wolfssl_%.bbappend` file in your own layer that includes the necessary 
`.inc` files for the features you need. For example, if you need wolfclu and wolfssh 
support, create a `wolfssl_%.bbappend` file:

```
# In your-layer/recipes-wolfssl/wolfssl/wolfssl_%.bbappend
require inc/wolfclu/wolfssl-enable-wolfclu.inc
require inc/wolfssh/wolfssl-enable-wolfssh.inc
```

Or point to the meta-wolfssl layer directly:

```
require ${COREBASE}/../meta-wolfssl/inc/wolfclu/wolfssl-enable-wolfclu.inc
require ${COREBASE}/../meta-wolfssl/inc/wolfssh/wolfssl-enable-wolfssh.inc
```

**Important**: When using this method, you must also create `.bbappend` files for each 
package you want to use. A convenience `.inc` file is provided to disable the feature 
check. For example:

```
# In your-layer/recipes-wolfssl/wolfclu/wolfclu_%.bbappend
require inc/wolfssl-manual-config.inc

# In your-layer/recipes-wolfssl/wolfssh/wolfssh_%.bbappend
require inc/wolfssl-manual-config.inc
```

Or point to the meta-wolfssl layer directly:

```
require ${COREBASE}/../meta-wolfssl/inc/wolfssl-manual-config.inc
```

The `inc/wolfssl-manual-config.inc` file can be used for any wolfSSL package. It 
disables the automatic validation check that looks for `IMAGE_INSTALL` or 
`WOLFSSL_FEATURES`. Remember to also include the corresponding `wolfssl-enable-*.inc` 
file(s) in your `wolfssl_%.bbappend` to configure wolfSSL with the necessary features.

This gives you complete control over which wolfSSL features are enabled without 
relying on automatic detection.

Once your image has been built, the default location for the wolfSSL library
on your machine will be in the "/usr/lib" directory.

Note: If you need to install the development headers for these libraries, you
will want to use the "-dev" variant of the package. For example, to install
both the wolfSSL library and headers into your image, use "wolfssl-dev" along
with IMAGE_INSTALL:append, ie:

- For Dunfell and newer versions of Yocto
```
IMAGE_INSTALL:append = "wolfssl-dev"
```

- For versions of Yocto older than Dunfell
```
IMAGE_INSTALL_append = "wolfssl-dev"
```


After building your image, you will find wolfSSL headers in the
"/usr/include" directory and applications in "usr/bin".

Customizing the wolfSSL Library Configuration
---------------------------------------------

Custom applications that use wolfSSL libraries may wish to enable or disable
specific Autoconf/configure options when the library is compiled. This can be
done through the use of an application-specific .bbappend file for the wolfSSL
library.

For example, if your application wanted TLS 1.3 support compiled into the
wolfSSL library, you would want to create a .bbappend file for wolfSSL in
your application recipe/layer, ie:

```
wolfssl_%.bbappend
```

Inside this .bbappend file, you can use the EXTRA_OECONF variable to add
additional configure options to the wolfSSL library build.  For enabling
TLS 1.3 this would be:

```
EXTRA_OECONF += "--enable-tls13"
```

Make sure this .bbappend file gets picked up when bitbake is compiling your
application.

Building Other Applications with wolfSSL
----------------------------------------

Support for building many open source projects with wolfSSL is included in the
various recipes-* directories. As an example, take a look at
recipes_support/curl/wolfssl_%.bbappend. This .bbappend adds `--enable-curl` to
the wolfSSL configuration line via `EXTRA_OECONF`. curl_%.bbappend sets up curl
to use wolfSSL as its crypto and TLS provider. curl_7.82.0.bbappend is a
.bbappend specifically for adding wolfSSL support to curl version 7.82.0.

In the curl project, wolfSSL is supported upstream, but other projects may not
have native wolfSSL support. We've added wolfSSL support to many popular open
source projects, and the patches can be found in our
[open source projects (OSP) repository](https://github.com/wolfSSL/osp). Several
of these patches are used here. OpenSSH is one example. Under
recipes-connectivity/openssh/files, you'll find a patch for OpenSSH 8.5p1 that
adds wolfSSL support. One directory up in recipes-connectivity/openssh, you'll
find openssh_8.5p1.bbappend which

1. Adds the patch to the build.
2. Removes OpenSSH's OpenSSL dependency.
3. Adds the wolfSSL dependency.
4. Adds `--with-wolfssl` to the configuration line.

Additionally, there's another wolfssl_%.bbappend which adds `--enable-openssh`
to the wolfSSL configuration. This is the general pattern you'll see for other
projects that depend on wolfSSL, too.

This layer offers wolfSSL support for the following open source projects:

- [curl](https://layers.openembedded.org/layerindex/recipe/5765/)
- [OpenSSH](https://layers.openembedded.org/layerindex/recipe/5083/)

wolfSSL Example Application Recipes
-----------------------------------

Several wolfSSL example application recipes are included in this layer. These
include:

- wolfCrypt test application      (depends on wolfssl)
- wolfCrypt benchmark application (depends on wolfssl)

The recipes for these applications are located at:

```
meta-wolfssl/recipes-examples/wolfcrypt/wolfcrypttest/wolfcrypttest.bb
meta-wolfssl/recipes-examples/wolfcrypt/wolfcryptbenchmark/wolfcryptbenchmark.bb
```

These can be compiled individually with bitbake:

```
$ bitbake wolfcrypttest
$ bitbake wolfcryptbenchmark
```

To install these applications into your image, you will need to edit your
"build/conf/local.conf" file and add them to the "IMAGE_INSTALL"
variable. For example, to install the wolfSSL, wolfSSH, and wolfMQTT libraries
in addition to the wolfCrypt test and benchmark applications:


- For Dunfell and newer versions of Yocto
```
IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfcrypttest wolfcryptbenchmark "
```

- For versions of Yocto older than Dunfell
```
IMAGE_INSTALL_append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfcrypttest wolfcryptbenchmark "
```

When your image builds, these will be installed to the '/usr/bin' system
directory. When inside your executing image, you can run them from the
terminal.

wolfSSL Demo Images
-------------------

This layer includes several pre-configured demo images for testing various wolfSSL 
sub-packages. Each image is a minimal Yocto image based on `core-image-minimal` with 
specific wolfSSL components installed and configured.

For detailed information about each demo image, including structure, configuration 
methods, and testing instructions, see [recipes-core/README.md](recipes-core/README.md).

### Enabling Demo Images

To enable a demo image, add the following to your `conf/local.conf`:

```
WOLFSSL_DEMOS = "wolfssl-image-minimal <additional-image-name>"
```

**Important**: All demo images (except `wolfssl-image-minimal` itself) require 
`wolfssl-image-minimal` to be included in `WOLFSSL_DEMOS` because they inherit from it.

You can then build the image with:

```
$ bitbake <image-name>
```

### Available Demo Images

1. **wolfssl-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal"`
   - Provides: wolfSSL library, wolfcrypttest, wolfcryptbenchmark
   - Description: Base minimal image with wolfSSL and core crypto testing tools

2. **wolfclu-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal wolfclu-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfCLU
   - Description: Demonstrates wolfCLU command-line tools

3. **wolftpm-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal wolftpm-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfTPM + TPM 2.0 tools
   - Requirements: Add to `local.conf`:
     ```
     DISTRO_FEATURES += "security tpm tpm2"
     MACHINE_FEATURES += "tpm tpm2"
     KERNEL_FEATURES += "features/tpm/tpm.scc"
     ```
   - Testing: Use `test-wolftpm.sh` script in the image directory to run with swtpm.
     Once booted, run `/usr/bin/wolftpm-wrap-test`

4. **wolfssl-py-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal wolfssl-py-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + Python bindings (wolfssl-py, 
     wolfcrypt-py, wolf-py-tests) + Python 3 with cffi and pytest
   - Note: For all wolfssl-py tests to pass, you will need to configure networking in 
     the QEMU environment (DNS resolvers, network connectivity, etc.)

5. **wolfprovider-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal wolfprovider-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfProvider + 
     wolfprovidertest + OpenSSL 3.x
   - Description: Demonstrates wolfProvider as an OpenSSL 3.x provider

6. **wolfssl-combined-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal wolfssl-combined-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfssh + wolfmqtt + 
     wolfProvider + wolftpm + TPM 2.0 tools
   - Requirements: Add to `local.conf`:
     ```
     DISTRO_FEATURES += "security tpm tpm2"
     MACHINE_FEATURES += "tpm tpm2"
     KERNEL_FEATURES += "features/tpm/tpm.scc"
     ```
   - Description: Comprehensive image combining multiple wolfSSL sub-packages

7. **wolfclu-combined-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal wolfclu-combined-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfCLU + Python bindings 
     (wolfssl-py, wolfcrypt-py, wolf-py-tests) + Python 3 with cffi and pytest + 
     DNS configuration + ca-certificates
   - Description: Combines wolfCLU with Python bindings and networking support

8. **libgcrypt-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal libgcrypt-image-minimal"`
   - Requires: `require /path/to/meta-wolfssl/conf/wolfssl-fips.conf` (wolfSSL FIPS bundle)
   - Provides: Everything from `wolfssl-image-minimal` + libgcrypt with wolfSSL backend + 
     libgcrypt-ptest + ptest-runner
   - Description: Demonstrates libgcrypt using wolfSSL FIPS as the crypto backend. Enables 
     FIPS-validated cryptography for all applications using libgcrypt (GnuPG, systemd, etc.)
   - Testing: Run `ptest-runner libgcrypt` in QEMU to verify the wolfSSL backend
   - More Info: See [recipes-support/libgcrypt/README.md](recipes-support/libgcrypt/README.md) 
     and [recipes-core/images/libgcrypt-image-minimal/README.md](recipes-core/images/libgcrypt-image-minimal/README.md)

### Building Multiple Demo Images

You can enable multiple demo images by space-separating them. Remember to always 
include `wolfssl-image-minimal` first:

```
WOLFSSL_DEMOS = "wolfssl-image-minimal wolfclu-image-minimal wolfssl-py-image-minimal"
```

Then build each image individually:

```
$ bitbake wolfssl-image-minimal
$ bitbake wolfclu-image-minimal
$ bitbake wolfssl-py-image-minimal
```

### Running Demo Images

After building, run images with QEMU using:

```
$ runqemu <image-name>
```

For images with special requirements (like `wolftpm-image-minimal`), use the provided 
test scripts in the image directory.

Excluding Recipe from Build
---------------------------

Recipes can be excluded from your build by deleting their respective ".bb" file,
or by deleting the recipe directory.

Wolfssl-py and Wolfcrypt-py Installation Requirements
-----------------------------------------------------

To use the python wrapper for wolfSSL and wolfcrypt in a yocto build it will
require python3, python3-cffi and wolfSSL are built on the target system.

If you are using older version of yocto (2.x) or (3.x), you will need to download
and add the meta-oe and meta-python recipes from openembedded's [meta-openembedded](https://github.com/openembedded/meta-openembedded) to the image.

It will be necassary then to make sure at minimum that the IMAGE_INSTALL:append
looks as follows:

- For Dunfell and newer versions of Yocto
    + if wolfSSL-py is desired on target system
    ```
    IMAGE_INSTALL:append = " wolfssl wolfssl-py python3 "
    ```
    + if wolfCrypt-py is desired on target system
    ```
    IMAGE_INSTALL:append = " wolfssl wolfcrypt-py python3 "
    ```
    + if wolfSSL-py and wolfCrypt-py are both desired on target system
    ```
    Image_INSTALL:append = " wolfssl wolfssl-py wolfcrypt-py python3 python3-cffi"
    ```

- For versions of Yocto older than Dunfell
    + if wolfSSL-py is desired on target system
    ```
    IMAGE_INSTALL_append = " wolfssl wolfssl-py python3 "
    ```
    + if wolfCrypt-py is desired on target system
    ```
    IMAGE_INSTALL_append = " wolfssl wolfcrypt-py python3 "
    ```
    + if wolfSSL-py and wolfCrypt-py are both desired on target system
    ```
    Image_INSTALL_append = " wolfssl wolfssl-py wolfcrypt-py python3 python3-cffi"
    ```

Testing Wolfssl-py and Wolfcrypt-py
-----------------------------------

To test the python wrapper for wolfSSL and wolfcrypt in a yocto build it will
require python3, python3-pytest, python3-cffi and wolfSSL are built on the target system.

It will be necassary then to make sure at minimum that the IMAGE_INSTALL:append
looks as follows:


- If wolfSSL-py and wolfCrypt-py are both desired on target system

    + For Dunfell and newer versions of Yocto
    ```
    IMAGE_INSTALL:append = " wolfssl wolfssl-py wolfcrypt-py wolf-py-tests python3 python3-cffi python3-pytest"
    ```

    + For versions of Yocto older than Dunfell
    ```
    IMAGE_INSTALL_append = " wolfssl wolfssl-py wolfcrypt-py wolf-py-tests python3 python3-cffi python3-pytest"
    ```

This places the tests in the root home directory
```
$ cd /home/root/wolf-py-tests/
$ ls wolfcrypt-py-test wolfssl-py-test
```

navigate into the desired test:

    + for wolfssl-py
    ```
    $ cd /home/root/wolf-py-tests/wolfssl-py-test

    ```
    + for wolfcrypt-py
    ```
    $ cd /home/root/wolf-py-tests/wolfcrypt-py-test
    ```

once in the desired test directory, begin the test by calling pytest
```
$ pytest
```

This should then result in a pass or fail for the desired suit.

If you are testing this with the core-image-minimal yocto build, make sure
to add a DNS server to /etc/resolv.conf like such with root perms

```
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

Running Image on the QEMU
-------------------------

To run meta-wolfssl image on the QEMU (Quick EMUlator) you can follow these
general steps. For this example we will use the Yocto Project Poky.
Refer to:
[Yocto Project](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html) for a detailed guide.

1. Initialize the Build
This can be done by running these commands:

```
$ cd poky
$ source oe-init-build-env
```

This will initialize the build environment and let you run
bitbake in the build directory.

2. Run bitbake
Next you can run bitbake to build the OS image that you want. Make sure
you have the correct variables added in the `local.conf` For this example
we will run `core-image-base`. Which can be built by running this comamnd
from the `build` directoy:

```
$ bitbake core-image-base
```

This will run bitbake and build the image with your added
meta-wolfssl recipes.

3. Run the Image in QEMU
You can now simulate your image with the QEMU This can be done by running
the qemu that comes in your Yocto Project the default system is usually
`qemux86-64` but you can find what its set to by looking at your `local.conf`.
We can run this command to start the emulator:

```
$ runqemu qemux86-64
```

4. Run Your Recipes
Now that you are in the QEMU you can navigate your way to the `usr/bin`
directory which contains the your wolfssl your applications. Lets say we
included these images in our `local.conf`

```
IMAGE_INSTALL:append = " wolfssl wolfcrypttest wolfcryptbenchmark "
```

In that case we can run wolfcrypttest and wolfcryptbenchmark examples from
the `usr/bin` directory like so:

```
$ ./wolfcrypttest
$ ./wolfcryptbenchmark
```

This will run the wolfcrypt test and benchmark examples from the QEMU.

wolfProvider
------------
To build wolfProvider view the instructions in this [README](recipes-wolfssl/wolfprovider/README.md)

wolfEngine
------------
To build wolfEngine view the instructions in this [README](recipes-wolfssl/wolfengine/README.md)

wolfPKCS11
-----------
wolfPKCS11 is a PKCS#11 implementation provided by wolfSSL for cryptographic token interface support. This layer includes support for building wolfPKCS11 as a Yocto/OpenEmbedded recipe.

To include wolfPKCS11 in your image, add it to your IMAGE_INSTALL variable in your `local.conf`:

- For Dunfell and newer versions of Yocto:
```
IMAGE_INSTALL:append = " wolfpkcs11 "
```
- For versions of Yocto older than Dunfell:
```
IMAGE_INSTALL_append = " wolfpkcs11 "
```

After building, the wolfPKCS11 library and tools will be available in the standard locations (e.g., `/usr/lib`, `/usr/bin`). For more details on configuration and usage, see the wolfPKCS11 README.

FIPS-READY
----------
For building FIPS-Ready for wolfSSL view the instruction in this [README](recipes-wolfssl/wolfssl/fips-ready/README.md)

Commercial/FIPS Bundles
-----------------------
For building FIPS and/or commercial bundles of wolfSSL products view the instructions in this [README](recipes-wolfssl/wolfssl/commercial/README.md).

To gain access to these bundles contact support@wolfssl.com to get a qoute.

### Using wolfssl-fips Recipe

The layer provides a `wolfssl-fips` recipe that uses BitBake's `virtual/wolfssl` provider mechanism, allowing you to seamlessly swap between open-source, FIPS, and commercial versions of wolfSSL.

#### What is virtual/wolfssl?

`virtual/wolfssl` is an abstract interface that can be provided by multiple recipes:
- `wolfssl` (open-source) - Default provider from meta-networking
- `wolfssl-fips` (FIPS-validated) - Provided by this layer
- Future: `wolfssl-commercial` - For commercial non-FIPS bundles

When you set `PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"`, all recipes that depend on `virtual/wolfssl` will automatically use the FIPS-validated version instead of the standard open-source version.

#### Setup Instructions

1. **Copy the configuration template:**
   ```bash
   cd meta-wolfssl
   cp conf/wolfssl-fips.conf.sample conf/wolfssl-fips.conf
   ```

2. **Edit `conf/wolfssl-fips.conf` with your FIPS bundle details:**
   - `WOLFSSL_SRC_DIR` - Directory containing your .7z bundle
   - `WOLFSSL_SRC` - Bundle filename (without .7z extension)
   - `WOLFSSL_SRC_PASS` - Bundle password
   - `WOLFSSL_LICENSE` - License file name (typically in bundle)
   - `WOLFSSL_LICENSE_MD5` - MD5 checksum of license file
   - `FIPS_HASH` - FIPS integrity hash (auto-generated on first build if using auto mode)
   - `WOLFSSL_FIPS_HASH_MODE` - `"auto"` (QEMU-based) or `"manual"` (static hash)

3. **Include the configuration in your `build/conf/local.conf`:**
   ```bitbake
   # Use absolute path to the config file
   require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
   ```

   The configuration will automatically:
   - Set `PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"`
   - Set `PREFERRED_PROVIDER_wolfssl = "wolfssl-fips"`
   - Configure FIPS bundle extraction and validation

4. **Build your image or package:**
   ```bash
   bitbake <your-image>
   ```

#### FIPS Hash Modes

The layer supports two modes for FIPS integrity hash generation:

**Auto Mode (Recommended):**
```bitbake
WOLFSSL_FIPS_HASH_MODE = "auto"
```
- Automatically extracts hash by building with placeholder, running test binary via QEMU
- Works for all architectures
- No manual hash management needed

**Manual Mode:**
```bitbake
WOLFSSL_FIPS_HASH_MODE = "manual"
FIPS_HASH = "YOUR_HASH_HERE"
```
- Uses static hash value from config
- Requires you to obtain and set the hash manually

#### File Security

The `conf/wolfssl-fips.conf` file is automatically ignored by git (via `.gitignore`), keeping your bundle password and license information private. Only the `.sample` template is tracked in git.

#### Benefits

- **Seamless switching:** Change provider in one place, all recipes adapt
- **No recipe modifications:** Existing recipes work unchanged
- **Automatic configuration:** FIPS features and hash extraction handled automatically
- **Security:** Credentials stay local and private

Maintenance
-----------

Layer maintainers:
- wolfSSL Support (<support@wolfssl.com>)
- Chris Conlon (<chris@wolfssl.com>)
- Jacob Barthelmeh (<jacob@wolfssl.com>)

Website
-------
https://www.wolfssl.com

License
-------

wolfSSL is open source and dual licensed under both the GPLv2 and a standard
commercial license. wolfSSL also offers commercial licensing for our
[FIPS-validated wolfCrypt module](wolfssl.com/license/fips.). For commercial
license questions, please contact wolfSSL at licensing@wolfssl.com. For product
support inquiries please contact support@wolfssl.com.
