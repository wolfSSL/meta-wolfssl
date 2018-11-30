meta-wolfssl
==========

This layer provides both Yocto and openembedded recipes for wolfSSL products
as well as bbappend files for configuring common open source packages and
projects with support for wolfSSL.

This layer currently provides recipes for the following wolfSSL products:

- wolfSSL embedded SSL/TLS library
- wolfSSH lightweight SSH library
- wolfMQTT lightweight MQTT client library

This layer currently provides bbappend files for the following open source
projects:

- cURL

The wolfSSL library recipe is also included in the openembedded
meta-networking layer, located [here.](
https://github.com/openembedded/meta-openembedded/blob/master/meta-networking/recipes-connectivity/wolfssl/wolfssl_3.14.4.bb).

wolfSSL is a lightweight SSL/TLS library written in C and targeted at embedded
and RTOS environments - primarily because of its small size, speed, and
feature set. With common build sizes between 20-100kB, it is typically up to
20 times smaller than OpenSSL. Other feature highlights include support for
TLS 1.3 and DTLS 1.2, full client and server support, abstraction layers for
easy porting, CRL and OCSP support, key and cert generation, support for
hardware cryptography modules, and much more. For a full feature list, please
visit the [wolfSSL product page](https://www.wolfssl.com/products/wolfssl/).

Setup
-----

For detailed documentation and installation instructions, see our
Beginner's Guide.

Clone meta-wolfssl onto your machine:

```
git clone https://github.com/wolfSSL/meta-wolfssl.git
```

After installing YoctoProject/OpenEmbedded components and running their
build command:

1. Insert the meta-wolfssl file location into your build's bblayers.conf
   file inside the BBLAYERS section:

   ```
   BBLAYERS ?= " \
       ...
       /path/to/yocto/poky/meta-wolfssl \
       ...
   "
   ```

2. Once the meta-wolfssl layer has been added to your BBLAYERS collection,
   you can build the individual product recipes to make sure they compile
   successfully:

   $ bitbake wolfssl
   $ bitbake wolfssh
   $ bitbake wolfmqtt

2. Edit your build's local.conf file to install the libraries you would like
   included (ie: wolfssl, wolfssh, wolfmqtt) by adding a IMAGE_INSTALL_append
   line:

    ```
    IMAGE_INSTALL_append = "wolfssl wolfssh wolfmqtt"
    ```

Once your image has been built, the default location for the wolfSSL library
on your machine will be in the '/usr/lib' directory.

Maintenance
-----------

Layer maintainer: Chris Conlon <chris@wolfssl.com>

https://www.wolfssl.com

License
-------

wolfSSL is open source and dual licensed under both the GPLv2
and a standard commercial license. For commercial license
questions, please contact wolfSSL at licensing@wolfssl.com. For product
support inquiries please contact support@wolfssl.com.

