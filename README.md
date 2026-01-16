meta-wolfssl
==========

This layer provides both [Yocto](https://www.yoctoproject.org/) and
[OpenEmbedded](http://www.openembedded.org/wiki/Main_Page) recipes for
wolfSSL products and examples, as well as .bbappend files for configuring
common open source packages and projects with support for wolfSSL.

This layer currently provides recipes for the following wolfSSL products:

- [wolfSSL embedded SSL/TLS library](https://www.wolfssl.com/products/wolfssl/)
- [wolfSSH lightweight SSH library](https://www.wolfssl.com/products/wolfssh/)
- [wolfMQTT lightweight MQTT client library](https://www.wolfssl.com/products/wolfmqtt/)
- [wolfTPM portable TPM 2.0 library](https://www.wolfssl.com/products/wolftpm/)
- [wolfSSL-py A Python wrapper for the wolfSSL library](https://github.com/wolfSSL/wolfssl-py)
- [wolfCrypt-py A Python Wrapper for the wolfCrypt API](https://github.com/wolfSSL/wolfcrypt-py)
- [wolfPKCS11 A PKCS#11 implementation using wolfSSL](https://github.com/wolfSSL/wolfpkcs11)
- [wolfEngine OpenSSL 1.X Engine](https://github.com/wolfSSL/wolfEngine)
- [wolfProvider OpenSSL 3.X Provider](https://github.com/wolfSSL/wolfProvider)


This layer also provides Open Source Package (OSP):
- See [Yocto Version Support](#yocto-version-support) for version
requirements.

**Important Branch Notice**
---------------------------

The `master` branch is intended for development and may contain unstable
changes. For production use, please switch to a version-specific branch
that matches your Yocto release for a more stable layer.

If your version of Yocto is not supported by an existing branch, you can
use the `master` branch, but for dedicated support please contact
support@wolfssl.com.


Table of Contents
-----------------

- [Yocto Version Support](#yocto-version-support)
- [Setup](#setup)
  - [Layer Dependencies](#layer-dependencies)
  - [Development Headers](#development-headers)
- [Port Recipes Version Requirements](#port-recipes-version-requirements)
- [Customizing the wolfSSL Library Configuration](#customizing-the-wolfssl-library-configuration)
- [Building Other Applications with wolfSSL](#building-other-applications-with-wolfssl)
- [wolfSSL Example Application Recipes](#wolfssl-example-application-recipes)
- [wolfSSL Demo Images](#wolfssl-demo-images)
  - [Enabling Demo Images](#enabling-demo-images)
  - [Available Demo Images](#available-demo-images)
  - [Standalone Demo Images](#standalone-demo-images)
  - [Running Demo Images](#running-demo-images)
- [Python Bindings (wolfssl-py and wolfcrypt-py)](#python-bindings-wolfssl-py-and-wolfcrypt-py)
  - [Installation Requirements](#installation-requirements)
  - [Testing](#testing)
- [Running Image on QEMU](#running-image-on-qemu)
- [Additional wolfSSL Products](#additional-wolfssl-products)
  - [wolfProvider](#wolfprovider)
  - [wolfEngine](#wolfengine)
  - [wolfPKCS11](#wolfpkcs11)
- [Commercial/FIPS Bundles](#commercialfips-bundles)
  - [Using wolfssl-fips Recipe](#using-wolfssl-fips-recipe)
  - [Commercial Bundles from Google Cloud Storage](#commercial-bundles-from-google-cloud-storage)
- [Manual Configuration](#manual-configuration)
- [Excluding Recipe from Build](#excluding-recipe-from-build)
- [Additional Documentation](#additional-documentation)
- [Maintenance](#maintenance)
- [Website](#website)
- [License](#license)

Yocto Version Support (Master Branch)
---------------------

**Core wolfSSL recipes** (wolfssl, wolfssh, wolfmqtt, wolftpm, wolfclu,
wolfpkcs11, wolfssl-py, wolfcrypt-py) have been tested with the following
Yocto versions:

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

**Port recipes** (recipes that add wolfSSL support to existing open source
packages) have specific version requirements. See the [Port Recipes Version
Requirements](#port-recipes-version-requirements) section below.

Setup
-----

Clone meta-wolfssl onto your machine:

```
git clone https://github.com/wolfSSL/meta-wolfssl.git
```

### Layer Dependencies

**For FIPS Builds Only:** If you plan to use the `wolfssl-fips` recipe, you
must also include the `meta-openembedded/meta-oe` layer, which provides
`p7zip-native` for extracting commercial FIPS bundles. Non-FIPS builds do
not require this dependency.

```
git clone https://github.com/openembedded/meta-openembedded.git
```

After installing your build's Yocto/OpenEmbedded components:

1. Insert the 'meta-wolfssl' layer into your build's `bblayers.conf` file
   (located at `build/conf/bblayers.conf`), in the BBLAYERS section:

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

2. Add wolfSSL packages to your image. You have two options:

   **Method 1: Using IMAGE_INSTALL**

   Add packages to `IMAGE_INSTALL` in your `local.conf`:

   - For Dunfell and newer versions of Yocto:
   ```
   IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfpkcs11 "
   ```

   - For versions of Yocto older than Dunfell:
   ```
   IMAGE_INSTALL_append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfpkcs11 "
   ```

   This automatically configures wolfSSL with the necessary `--enable-*`
   options for the packages you include and adds them to your image.

   **Method 2: Manual .bbappend**

   If you prefer more control, you can manually create a `wolfssl_%.bbappend`
   file in your own layer that includes the necessary `.inc` files for the
   features you need. For example:

   ```
   # In your-layer/recipes-wolfssl/wolfssl/wolfssl_%.bbappend
   require ${COREBASE}/../meta-wolfssl/inc/wolfclu/wolfssl-enable-wolfclu.inc
   require ${COREBASE}/../meta-wolfssl/inc/wolfssh/wolfssl-enable-wolfssh.inc
   ```

   You must also create `.bbappend` files for each package you want to use:

   ```
   # In your-layer/recipes-wolfssl/wolfclu/wolfclu_%.bbappend
   require ${COREBASE}/../meta-wolfssl/inc/wolfssl-manual-config.inc
   ```

   See the [Manual Configuration](#manual-configuration) section for more
   details.

### Development Headers

To install development headers, use the "-dev" variant:

- For Dunfell and newer versions of Yocto:
```
IMAGE_INSTALL:append = " wolfssl-dev"
```

- For versions of Yocto older than Dunfell:
```
IMAGE_INSTALL_append = " wolfssl-dev"
```

After building, wolfSSL headers will be in `/usr/include` and applications
in `/usr/bin`.

Port Recipes Version Requirements
----------------------------------

Port recipes add wolfSSL support to existing open source packages. These have
specific Yocto version requirements based on the package versions shipped
with each Yocto release:

| Port Recipe | Package Version | Supported Yocto Versions |
|-------------|----------------|-------------------------|
| BIND | 9.11.22 | Dunfell |
| curl | 7.82.0 | Kirkstone |
| libssh2 | 1.9.0 | Dunfell, Gatesgarth |
| net-snmp | 5.9 | Gatesgarth |
| OpenSSH | 8.5p1 | Hardknott |
| OpenSSH | 9.6p1 | Scarthgap |
| rsyslog | 8.2106.0 | Honister |
| socat | 1.7.3.4, 1.8.0.0 | Dunfell |
| strongSwan | 5.9.4 | Honister |
| tcpdump | 4.9.3 | Warrior, Zeus, Dunfell, Gatesgarth |

To enable a port recipe, uncomment the corresponding line in
`meta-wolfssl/conf/layer.conf`. See the README files in each port's
directory for detailed usage instructions:
- [recipes-connectivity/README.md](recipes-connectivity/README.md)
- [recipes-support/README.md](recipes-support/README.md)
- [recipes-protocols/README.md](recipes-protocols/README.md)
- [recipes-extended/README.md](recipes-extended/README.md)

Customizing the wolfSSL Library Configuration
-----------------------------------------------

Custom applications that use wolfSSL libraries may wish to enable or
disable specific Autoconf/configure options when the library is compiled.
This can be done through the use of an application-specific .bbappend file
for the wolfSSL library.

For example, if your application wanted TLS 1.3 support compiled into the
wolfSSL library, create a `wolfssl_%.bbappend` file in your application
recipe/layer:

```
EXTRA_OECONF += "--enable-tls13"
```

Make sure this .bbappend file gets picked up when bitbake is compiling your
application.

Building Other Applications with wolfSSL
----------------------------------------

Support for building many open source projects with wolfSSL is included in
the various recipes-* directories. As an example, take a look at
recipes-support/curl/wolfssl_%.bbappend. This .bbappend adds `--enable-curl`
to the wolfSSL configuration line via `EXTRA_OECONF`. curl_%.bbappend sets
up curl to use wolfSSL as its crypto and TLS provider.

In the curl project, wolfSSL is supported upstream, but other projects may
not have native wolfSSL support. We've added wolfSSL support to many
popular open source projects, and the patches can be found in our
[open source projects (OSP) repository](https://github.com/wolfSSL/osp).

This layer offers wolfSSL support for the following open source projects:

- [curl](https://layers.openembedded.org/layerindex/recipe/5765/)
- [OpenSSH](https://layers.openembedded.org/layerindex/recipe/5083/)

wolfSSL Example Application Recipes
-----------------------------------

Several wolfSSL example application recipes are included in this layer:

- wolfCrypt test application (depends on wolfssl)
- wolfCrypt benchmark application (depends on wolfssl)

These can be compiled individually with bitbake:

```
$ bitbake wolfcrypttest
$ bitbake wolfcryptbenchmark
```

To install these applications into your image, add them to `IMAGE_INSTALL`:

- For Dunfell and newer versions of Yocto:
```
IMAGE_INSTALL:append = " wolfcrypttest wolfcryptbenchmark "
```

- For versions of Yocto older than Dunfell:
```
IMAGE_INSTALL_append = " wolfcrypttest wolfcryptbenchmark "
```

When your image builds, these will be installed to `/usr/bin`.

wolfSSL Demo Images
-------------------

This layer includes several pre-configured demo images for testing various
wolfSSL sub-packages. Each image is a minimal Yocto image based on
`core-image-minimal` with specific wolfSSL components installed and
configured.

For detailed information about each demo image, including structure,
configuration methods, and testing instructions, see
[recipes-core/README.md](recipes-core/README.md).

### Enabling Demo Images

To enable a demo image, add the following to your `conf/local.conf`:

```
WOLFSSL_DEMOS = "wolfssl-image-minimal <additional-image-name>"
```

**Important**: All demo images (except `wolfssl-image-minimal` itself and
`fips-image-minimal`) require `wolfssl-image-minimal` to be included in
`WOLFSSL_DEMOS` because they inherit from it. These images are not intended
for production use; they are meant only to demonstrate how to configure
packages correctly using the `/inc/` files for different application use
cases.

You can then build the image with:

```
$ bitbake <image-name>
```

### Available Demo Images

1. **wolfssl-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal"`
   - Provides: wolfSSL library, wolfcrypttest, wolfcryptbenchmark
   - Description: Base minimal image with wolfSSL and core crypto testing
     tools

2. **wolfclu-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     wolfclu-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfCLU
   - Description: Demonstrates wolfCLU command-line tools

3. **wolftpm-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     wolftpm-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfTPM + TPM 2.0
     tools
   - Requirements: Add to `local.conf`:
     ```
     DISTRO_FEATURES += "security tpm tpm2"
     MACHINE_FEATURES += "tpm tpm2"
     KERNEL_FEATURES += "features/tpm/tpm.scc"
     ```
   - Testing: Use `test-wolftpm.sh` script in the image directory to run
     with swtpm. Once booted, run `/usr/bin/wolftpm-wrap-test`
   - More Info: See
     [recipes-examples/wolftpm/README.md](recipes-examples/wolftpm/README.md)

4. **wolfssl-py-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     wolfssl-py-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + Python bindings
     (wolfssl-py, wolfcrypt-py, wolf-py-tests) + Python 3 with cffi and
     pytest
   - Note: For all wolfssl-py tests to pass, you will need to configure
     networking in the QEMU environment (DNS resolvers, network
     connectivity, etc.)

5. **wolfprovider-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     wolfprovider-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfProvider +
     wolfprovidertest + OpenSSL 3.x
   - Description: Demonstrates wolfProvider as an OpenSSL 3.x provider

6. **wolfssl-combined-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     wolfssl-combined-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfssh + wolfmqtt
     + wolfProvider + wolftpm + TPM 2.0 tools
   - Requirements: Add to `local.conf`:
     ```
     DISTRO_FEATURES += "security tpm tpm2"
     MACHINE_FEATURES += "tpm tpm2"
     KERNEL_FEATURES += "features/tpm/tpm.scc"
     ```
   - Description: Comprehensive image combining multiple wolfSSL
     sub-packages

7. **wolfclu-combined-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     wolfclu-combined-image-minimal"`
   - Provides: Everything from `wolfssl-image-minimal` + wolfCLU + Python
     bindings (wolfssl-py, wolfcrypt-py, wolf-py-tests) + Python 3 with
     cffi and pytest + DNS configuration + ca-certificates
   - Description: Combines wolfCLU with Python bindings and networking
     support

8. **libgcrypt-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "wolfssl-image-minimal
     libgcrypt-image-minimal"`
   - Requires: `require /path/to/meta-wolfssl/conf/wolfssl-fips.conf`
     (wolfSSL FIPS bundle)
   - Provides: Everything from `wolfssl-image-minimal` + libgcrypt with
     wolfSSL backend + libgcrypt-ptest + ptest-runner
   - Description: Demonstrates libgcrypt using wolfSSL FIPS as the crypto
     backend. Enables FIPS-validated cryptography for all applications using
     libgcrypt (GnuPG, systemd, etc.)
   - Testing: Run `ptest-runner libgcrypt` in QEMU to verify the wolfSSL
     backend
   - More Info: See
     [recipes-support/libgcrypt/README.md](recipes-support/libgcrypt/README.md)
     and
     [recipes-core/images/libgcrypt-image-minimal/README.md](recipes-core/images/libgcrypt-image-minimal/README.md)

### Standalone Demo Images

These images do not require `wolfssl-image-minimal` in WOLFSSL_DEMOS:

1. **fips-image-minimal**
   - Enable with: `WOLFSSL_DEMOS = "fips-image-minimal"`
   - Requires: `require /path/to/meta-wolfssl/conf/wolfssl-fips.conf`
     (wolfSSL FIPS bundle)
   - Layer Dependencies: The following layers must be included in
     `bblayers.conf`:
     ```
     /path/to/meta-openembedded/meta-oe \
     /path/to/meta-openembedded/meta-python \
     /path/to/meta-openembedded/meta-networking \
     ```
   - FIPS Configuration: See the [Commercial/FIPS Bundles](#commercialfips-bundles)
     section for detailed instructions on configuring FIPS properly.
   - Provides: libgcrypt with wolfSSL FIPS backend + gnutls with wolfSSL
     FIPS backend + wolfProvider in replace-default mode + OpenSSL 3.x +
     test utilities
   - Description: Comprehensive FIPS image demonstrating wolfSSL FIPS
     integration with libgcrypt, gnutls, and wolfProvider. All crypto
     operations use wolfSSL FIPS as the backend.

### Running Demo Images

After building, run images with QEMU using:

```
$ runqemu <image-name>
```

For images with special requirements (like `wolftpm-image-minimal`), use
the provided test scripts in the image directory.

Python Bindings (wolfssl-py and wolfcrypt-py)
----------------------------------------------

### Installation Requirements

To use the python wrapper for wolfSSL and wolfcrypt in a yocto build, you
need python3, python3-cffi and wolfSSL built on the target system.

If you are using older versions of yocto (2.x) or (3.x), you will need to
download and add the meta-oe and meta-python recipes from openembedded's
[meta-openembedded](https://github.com/openembedded/meta-openembedded) to
the image.

Add to `IMAGE_INSTALL`:

- For Dunfell and newer versions of Yocto:
```
IMAGE_INSTALL:append = " wolfssl wolfssl-py wolfcrypt-py python3 python3-cffi"
```

- For versions of Yocto older than Dunfell:
```
IMAGE_INSTALL_append = " wolfssl wolfssl-py wolfcrypt-py python3 python3-cffi"
```

### Testing

To test the python wrapper, you also need python3-pytest:

- For Dunfell and newer versions of Yocto:
```
IMAGE_INSTALL:append = " wolf-py-tests python3-pytest"
```

- For versions of Yocto older than Dunfell:
```
IMAGE_INSTALL_append = " wolf-py-tests python3-pytest"
```

This places the tests in `/home/root/wolf-py-tests/`. Navigate to the
desired test directory and run `pytest`:

```
$ cd /home/root/wolf-py-tests/wolfssl-py-test
$ pytest
```

If you are testing with core-image-minimal, make sure to add a DNS server to
`/etc/resolv.conf`:

```
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
```

Running Image on QEMU
----------------------

To run meta-wolfssl image on QEMU (Quick Emulator):

1. Initialize the Build:
   ```
   $ cd poky
   $ source oe-init-build-env
   ```

2. Run bitbake to build your image:
   ```
   $ bitbake core-image-base
   ```

3. Run the Image in QEMU:
   ```
   $ runqemu qemux86-64
   ```

4. Run Your Recipes:
   Applications will be in `/usr/bin`. For example:
   ```
   $ ./wolfcrypttest
   $ ./wolfcryptbenchmark
   ```

For more details, refer to the
[Yocto Project Quick Start Guide](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html).

Additional wolfSSL Products
----------------------------

### wolfProvider

To build wolfProvider, view the instructions in this
[README](recipes-wolfssl/wolfprovider/README.md).

**Note:** Requires Kirkstone or later (OpenSSL 3.x).

### wolfEngine

To build wolfEngine, view the instructions in this
[README](recipes-wolfssl/wolfengine/README.md).

**Note:** Requires Dunfell or earlier (OpenSSL 1.x).

### wolfPKCS11

wolfPKCS11 is a PKCS#11 implementation provided by wolfSSL for
cryptographic token interface support.

To include wolfPKCS11 in your image, add it to your `IMAGE_INSTALL` variable
in your `local.conf`:

- For Dunfell and newer versions of Yocto:
```
IMAGE_INSTALL:append = " wolfpkcs11 "
```

- For versions of Yocto older than Dunfell:
```
IMAGE_INSTALL_append = " wolfpkcs11 "
```

After building, the wolfPKCS11 library and tools will be available in the
standard locations (e.g., `/usr/lib`, `/usr/bin`).

Commercial/FIPS Bundles
-----------------------

For building commercial bundles of wolfSSL products, view the
instructions in this
[README](recipes-wolfssl/wolfssl/commercial/README.md).

For FIPS-Ready builds, view the instructions in this
[README](recipes-wolfssl/wolfssl/fips-ready/README.md).

To gain access to these bundles, contact support@wolfssl.com to get a quote.

### Using wolfssl-fips Recipe

The layer provides a `wolfssl-fips` recipe that uses BitBake's
`virtual/wolfssl` provider mechanism, allowing you to seamlessly swap
between open-source, FIPS, and commercial versions of wolfSSL.

#### What is virtual/wolfssl?

`virtual/wolfssl` is an abstract interface that can be provided by multiple
recipes:
- `wolfssl` (open-source) - Default provider from meta-networking
- `wolfssl-fips` (FIPS-validated) - Provided by this layer
- Future: `wolfssl-commercial` - For commercial non-FIPS bundles
- Future: `wolfssl-fips-ready` - For FIPS Ready bundle builds (Emulates FIPS
Requirements)

When you set `PREFERRED_PROVIDER_virtual/wolfssl = "wolfssl-fips"`, all
recipes that depend on `virtual/wolfssl` will automatically use the
FIPS-validated version instead of the standard open-source version.

#### Setup Instructions

1. **Copy the configuration template to a known location:**
   ```bash
   cd meta-wolfssl
   cp conf/wolfssl-fips.conf.sample conf/wolfssl-fips.conf
   ```

2. **Edit `conf/wolfssl-fips.conf` with your FIPS bundle details:**
   - `WOLFSSL_VERSION` - Version of wolfSSL (e.g., "5.8.4"). This is the
     wolfSSL library version, not the FIPS bundle version.
   - `WOLFSSL_SRC_DIR` - Directory containing your commercial archive
   - `WOLFSSL_SRC` - Logical bundle name (without extension)
   - `WOLFSSL_BUNDLE_FILE` - Optional, set to `${WOLFSSL_SRC}.tar.gz` for
     tarballs
   - `WOLFSSL_SRC_PASS` - Bundle password (only needed for `.7z`)
   - `WOLFSSL_LICENSE` - License file name (typically in bundle)
   - `WOLFSSL_LICENSE_MD5` - MD5 checksum of license file
   - `FIPS_HASH` - FIPS integrity hash (auto-generated on first build if
     using auto mode)
   - `WOLFSSL_FIPS_HASH_MODE` - `"auto"` (QEMU-based) or `"manual"` (static
     hash)

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

5. **Test that the FIPS bundle is set up correctly:**
   You can verify your FIPS configuration by building the `fips-image-minimal`
   demo image. See the [fips-image-minimal](#fips-image-minimal) section for
   details.

#### FIPS Hash Modes

**Auto Mode (Recommended):**
```bitbake
WOLFSSL_FIPS_HASH_MODE = "auto"
```
- Automatically extracts hash by building with placeholder, running test
  binary via QEMU
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

The `conf/wolfssl-fips.conf` file is automatically ignored by git (via
`.gitignore`), keeping your bundle password and license information private.
Only the `.sample` template is tracked in git.

### Commercial Bundles from Google Cloud Storage

BitBake ships with a GCS fetcher. To use it with `wolfssl-fips`:

1. Upload the commercial tarball to a private bucket (for example
   `gs://wolfssl-commercial-artifacts/releases/5.8.2/wolfssl-5.8.2-commercial-fips-linux.tar.gz`).

2. Set the commercial variables plus the GCS URI in `conf/local.conf` (or
   your distro .conf):
   ```
   WOLFSSL_SRC = "wolfssl-5.8.2-commercial-fips-linux"
   WOLFSSL_SRC_SHA = "<sha256 from wolfSSL portal>"
   WOLFSSL_BUNDLE_FILE = "${WOLFSSL_SRC}.tar.gz"
   WOLFSSL_BUNDLE_GCS_URI = "gs://wolfssl-commercial-artifacts/releases/5.8.2/${WOLFSSL_BUNDLE_FILE}"
   ```

3. The recipe pulls in
   `${WOLFSSL_LAYERDIR}/inc/wolfssl-fips/wolfssl-commercial-gcs.inc`, which:
   - Points `SRC_URI` at the `gs://` location (with the checksum);
   - Disables the custom 7zip extraction task;
   - Lets BitBake handle download and unpack for tarballs.

4. Host requirements for the BitBake GCS fetcher:
   - Install the Google Cloud SDK (which provides the GCS client libraries)
     by following https://docs.cloud.google.com/sdk/docs/install.
   - Ensure the Python `google` namespace is present; on RPM-based installs
     the `google-cloud-cli` package does **not** ship the Python libraries,
     so also install `python3-google-cloud-core` (or `pip install --user
     google-cloud-core`) before running BitBake.
   - For private buckets, authenticate with `gcloud auth application-default
     login` or set `GOOGLE_APPLICATION_CREDENTIALS` to a service-account JSON
     before running BitBake.

For password-protected `.7z` bundles, keep `WOLFSSL_BUNDLE_FILE` unset (the
class will assume `<NAME>.7z`), provide `COMMERCIAL_BUNDLE_PASS`, and place
the archive where `COMMERCIAL_BUNDLE_DIR` points (or supply a `gs://…` URI
plus checksum). In that case the 7zip helper remains enabled and requires
`p7zip-native`.

Manual Configuration
--------------------

The `inc/wolfssl-manual-config.inc` file can be used for any wolfSSL
package. It disables the automatic validation check that looks for
`IMAGE_INSTALL`. Remember to also include the corresponding
`wolfssl-enable-*.inc` file(s) in your `wolfssl_%.bbappend` to configure
wolfSSL with the necessary features.

This gives you complete control over which wolfSSL features are enabled
without relying on automatic detection.

Additional Documentation
------------------------

This repository contains additional README files with detailed information:

### Core Recipes
- [recipes-core/README.md](recipes-core/README.md) - Demo images documentation

### Port Recipes
- [recipes-connectivity/README.md](recipes-connectivity/README.md) - BIND,
  OpenSSH, Socat
- [recipes-support/README.md](recipes-support/README.md) - curl, libssh2,
  strongSwan, tcpdump
- [recipes-protocols/README.md](recipes-protocols/README.md) - net-snmp
- [recipes-extended/README.md](recipes-extended/README.md) - rsyslog

### wolfSSL Products
- [recipes-wolfssl/wolfprovider/README.md](recipes-wolfssl/wolfprovider/README.md)
  - wolfProvider documentation
- [recipes-wolfssl/wolfengine/README.md](recipes-wolfssl/wolfengine/README.md)
  - wolfEngine documentation
- [recipes-wolfssl/wolfssh/README.md](recipes-wolfssl/wolfssh/README.md) -
  wolfSSH documentation

### Commercial/FIPS
- [recipes-wolfssl/wolfssl/commercial/README.md](recipes-wolfssl/wolfssl/commercial/README.md)
  - Commercial/FIPS bundle instructions
- [recipes-wolfssl/wolfssl/fips-ready/README.md](recipes-wolfssl/wolfssl/fips-ready/README.md)
  - FIPS-Ready build instructions

### OSP Integrations
- [recipes-support/libgcrypt/README.md](recipes-support/libgcrypt/README.md)
  - libgcrypt with wolfSSL backend

### Demo Images
- [recipes-core/images/libgcrypt-image-minimal/README.md](recipes-core/images/libgcrypt-image-minimal/README.md)
  - libgcrypt image documentation
- [recipes-core/images/gnutls-image-minimal/README.md](recipes-core/images/gnutls-image-minimal/README.md)
  - gnutls image documentation
- [recipes-core/images/wolfprovider-images/README.md](recipes-core/images/wolfprovider-images/README.md)
  - wolfProvider images documentation
- [recipes-core/images/wolfssl-linux-fips-images/fips-image-minimal/README.md](recipes-core/images/wolfssl-linux-fips-images/fips-image-minimal/README.md)
  - FIPS image documentation

### Examples
- [recipes-examples/wolftpm/README.md](recipes-examples/wolftpm/README.md) -
  wolfTPM example documentation

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

wolfSSL is open source and dual licensed under both the GPLv2 and a
standard commercial license. wolfSSL also offers commercial licensing for
our [FIPS-validated wolfCrypt module](https://www.wolfssl.com/license/fips/).
For commercial license questions, please contact wolfSSL at
licensing@wolfssl.com. For product support inquiries please contact
support@wolfssl.com.
