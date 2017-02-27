meta-wolfssl
==========

This layer provides a bbappend file for configuring cURL with wolfSSL.
The wolfSSL recipe can be located [here.](
https://github.com/openembedded/meta-openembedded/blob/master/meta-networking/recipes-connectivity/wolfssl/wolfssl_3.9.0.bb)

wolfSSL (formerly CyaSSL) is a lightweight SSL/TLS library written in C and
targeted at embedded and RTOS environments - primarily because of its small
size, speed, and feature set. With common build sizes between 20-100kB,
it is typically up to 20 times smaller than OpenSSL. Other feature
highlights include support for TLS 1.2 and DTLS 1.2, full client and
server support, abstraction layers for easy porting, CRL and OCSP
support, key and cert generation, and much more. For a full feature
list, please visit the wolfSSL webpage at:

https://www.wolfssl.com/wolfSSL/Products-wolfssl.html

Setup
-----

`For detailed image writing and installation instructions, see our
Beginner's Guide.`

Clone meta-wolfssl onto your machine.

After installing YoctoProject/OpenEmbedded components and then running
their build command:

1. Insert the meta-wolfssl file location into the build's bblayers.conf
   file in BBLAYERS ?= "" section.

2. Edit the build's local.conf file to include this line:

    IMAGE_INSTALL_append = " wolfssl" (include benchmark and/or wolfcrypt
                                          test recipes if needed)
3. Edit an image file to include this line:

    IMAGE_INSTALL += "wolfssl"

Once you have built your image, the location on the new machine for wolfssl
will be in /usr/libs, while benchmark and wolfcrypt will be located in
/usr/bin.


Maintenance
-----------

Layer maintainer: Chris Conlon <chris@wolfssl.com>

https://www.wolfssl.com

License
-------

wolfSSL is open source and dual licensed under both the GPLv2
and a standard commercial license. For commercial license
questions, please contact yaSSL at info@wolfssl.com.

