wolfTPM Examples 
================

Several wolfTPM example applications are included in this
layer, these include:

- attestation
- endorsement
- keygen
- pcr
- seal
- bench
- firmware
- management
- pkcs7
- timestamp
- boot
- gpio
- native
- tls
- wrap
- csr
- nvram

The recipe for these applications is located at:
```
meta-wolfssl/recipes-examples/wolftpm/wolftpm_%.bbappend
```

This can be compiled with bitbake using:

```
$ bitbake wolftpm
```

To install these applications into your image, you will 
need to edit your "build/conf/local.conf" file and add 
them to the "IMAGE_INSTALL" variable like so:

- For Dunfell and newer versions of Yocto
```
IMAGE_INSTALL:append = " wolftpm "
```

- For versions of Yocto older than Dunfell
```
IMAGE_INSTALL_append = " wolftpm "
```

When your image builds, these will be installed to the 
`/usr/bin/examples` system directory. When inside your
executing image, you can run them from the terminal. 
For example, we can run the wrap test like so from the 
examples directory:

```
$ cd wrap
$ ./wrap_test
```

The examples can be excluded from your build by deleting
the recipe `wolftpm_%bbappend`.

Refer to the [wolfTPM Examples README](https://github.com/wolfSSL/wolfTPM/blob/master/examples/README.md) for more information on the examples directory.

Refer to the [meta-wolfssl README](https://github.com/wolfSSL/meta-wolfssl/blob/master/README.md) for more information on setting up your layer.
