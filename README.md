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

These recipes have been tested using these versions of yocto:

- Nanbield      (v4.3)
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

After installing your build's Yocto/OpenEmbedded components:

1.  Insert the 'meta-wolfssl' layer location into your build's bblayers.conf
    file, in the BBLAYERS section:

    ```
    BBLAYERS ?= " \
       ...
       /path/to/yocto/poky/meta-wolfssl \
       ...
    "
    ```

2.  Once the 'meta-wolfssl' layer has been added to your BBLAYERS collection,
    you have two options
   
    1.  If you want to directly add wolfSSL recipes to your image recipe 
        proceed to step 3.


    2.  If you want to run `bitbake wolf*` on a particular recipe then it needs 
        uncommented in `local.conf` located in `meta-wolfssl/conf/`. 

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
        recipes. 
        
        You should make sure to comment out recipes you don't want to use to 
        avoid uneeded --enable-options in your wolfSSL version. wolfSSL is 
        uncommented by default.

        Once the recipes that need to be compiled are uncommented,
        you can build the individual product/test recipes to make sure they 
        compile successfully:

        ```
        $ bitbake wolfssl
        $ bitbake wolfssh
        $ bitbake wolfmqtt
        $ bitbake wolftpm
        $ bitbake wolfclu
        ```

3.  Edit your build's local.conf file to install the recipes you would like
    to include (ie: wolfssl, wolfssh, wolfmqtt, wolftpm) 
    
    - For Dunfell and newer versions of Yocto
    IMAGE_INSTALL:append line:

    ```
    IMAGE_INSTALL:append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu "
    ```
    
    - For versions of Yocto older than Dunfell
    IMAGE_INSTALL_append line:

    ```
    IMAGE_INSTALL_append = " wolfssl wolfssh wolfmqtt wolftpm wolfclu "
    ```

    This will add the necassary --enable-* options necassary to use your
    specific combination of recipes.

    If you did step 2.2 make sure you comment out recipes that you don't desire
    because leaving them uncommented may add unneed --enable-* options in your 
    build, which could increase the size of the build and turn on uneeded 
    features.

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

wolfProvider
------------
To build wolfProvider view the instructions in this [README](recipes-wolfssl/wolfprovider/README.md)

FIPS-READY
----------
For building FIPS-Ready for wolfSSL view the instruction in this [README](recipes-wolfssl/wolfssl/fips-ready/README.md)

Commercial/FIPS Bundles
-----------------------
For building FIPS and/or commercial bundles of wolfSSL products view the instructions in this [README](recipes-wolfssl/wolfssl/commercial/README.md).

To gain access to these bundles contact support@wolfssl.com to get a qoute.

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
