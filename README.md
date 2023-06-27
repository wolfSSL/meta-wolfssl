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

After installing your build's Yocto/OpenEmbedded components:

1. Insert the 'meta-wolfssl' layer location into your build's bblayers.conf
   file, in the BBLAYERS section:

   ```
   BBLAYERS ?= " \
       ...
       /path/to/yocto/poky/meta-wolfssl \
       ...
   "
   ```

2. Once the 'meta-wolfssl' layer has been added to your BBLAYERS collection,
   you then will need to go to the local.conf file located in 
   meta-wolfssl/conf/. The products that you want to compile will need to be
   uncommented.

   As an example if wolfssh is desired the following needs to occur:
   From "meta-wolfssl" directory
   ```
   $ vim conf/layer.conf
   ```
   Then look for the text:
   ```
   # Uncomment if building wolfssh with wolfssl
   #BBFILES += "${LAYERDIR}/recipes-wolfssl/wolfssh/*.bb \
   #            ${LAYERDIR}/recipes-wolfssl/wolfssh/*.bbappend"
   ```
   Then uncomment by removing the #, it should look like this afterwards
   ```
   # Uncomment if building wolfssh with wolfssl
   BBFILES += "${LAYERDIR}/recipes-wolfssl/wolfssh/*.bb \
               ${LAYERDIR}/recipes-wolfssl/wolfssh/*.bbappend"
   ```

   This needs to be done in order to preform a bitbake operation on any of the 
   products or tests. You should uncomment products you want to use and 
   comment out products you don't want to use to avoid uneeded --enable-options
   in your wolfssl version. wolfssl and wolfclu uncommented by default.

3. Once the products that need to be compiled are uncommented,
   you can build the individual product recipes to make sure they compile
   successfully:

   ```
   $ bitbake wolfssl
   $ bitbake wolfssh
   $ bitbake wolfmqtt
   $ bitbake wolftpm
   $ bitbake wolfclu
   ```
4. Edit your build's local.conf file to install the libraries you would like
   included (ie: wolfssl, wolfssh, wolfmqtt, wolftpm) by adding a
   IMAGE_INSTALL:append line:

    ```
    IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu "
    ```

Once your image has been built, the default location for the wolfSSL library
on your machine will be in the "/usr/lib" directory.

Note: If you need to install the development headers for these libraries, you
will want to use the "-dev" variant of the package. For example, to install
both the wolfSSL library and headers into your image, use "wolfssl-dev" along
with IMAGE_INSTALL:append, ie:

```
IMAGE_INSTALL:append = "wolfssl-dev"
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

Example Application Recipes
---------------------------

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
"build/conf/local.conf" file and add them to the "IMAGE_INSTALL_append"
variable. For example, to install the wolfSSL, wolfSSH, and wolfMQTT libraries
in addition to the wolfCrypt test and benchmark applications:

```
IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu wolfcrypttest wolfcryptbenchmark "
```

When your image builds, these will be installed to the '/usr/bin' system
directory. When inside your executing image, you can run them from the
terminal.

Excluding Recipe from Build
---------------------------

Recipes can be excluded from your build by deleting their respective ".bb" file,
or by deleting the recipe directory.

Maintenance
-----------

Layer maintainers:
- Chris Conlon (<chris@wolfssl.com>)
- Hayden Roche (<hayden@wolfssl.com>)

https://www.wolfssl.com

License
-------

wolfSSL is open source and dual licensed under both the GPLv2 and a standard
commercial license. wolfSSL also offers commercial licensing for our
[FIPS-validated wolfCrypt module](wolfssl.com/license/fips.). For commercial
license questions, please contact wolfSSL at licensing@wolfssl.com. For product
support inquiries please contact support@wolfssl.com.
