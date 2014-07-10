meta-wolfssl
==========

`This layer provides support for the CyaSSL embedded SSL library.

CyaSSL is a lightweight SSL library written in C and targeted at
embedded and RTOS environments - primarily because of its small size,
speed, and feature set. With common build sizes between 30-100kB,
it is typically up to 20 times smaller than OpenSSL. Other feature
highlights include support for TLS 1.2 and DTLS, full client and
server support, abstraction layers for easy porting, CRL and OCSP
support, key and cert generation, and much more. For a full feature
list, please visit the CyaSSL webpage at:

http://www.wolfssl.com/yaSSL/Products-cyassl.html
`
Setup
-----
Clone meta-wolfssl onto your machine. 

After installing YoctoProject/OpenEmbedded components and then running 
their build command:
    
1. Insert the meta-wolfssl file location into the build's bblayers.conf
   file in BBLAYERS ?= "" section.
2. Edit the build's local.conf file to include this line:
       
    IMAGE_INSTALL_append = " cyassl" (include benchmark and/or ctaocrypt
                                          test recipes if needed)
3. Edit an image file to include this line:

    IMAGE_INSTALL += "cyassl"

Once you have built your image, the location on the new machine for cyassl 
will be in /usr/libs, while benchmark and ctaocrypt will be located in 
/usr/bin.


Maintenance
-----------

Layer maintainer: Chris Conlon <chris@wolfssl.com>

License
-------

CyaSSL is open source and dual licensed under both the GPLv2
and a standard commercial license. For commercial license
questions, please contact yaSSL at info@yassl.com.

