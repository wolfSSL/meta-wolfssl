Supported Ports
===============

In this section these projects have been ported to work with specific versions
of packages shipped with yocto to be used with wolfSSL

BIND
----

This supports using `BIND` version: 9.11.22, which was shipped with Yocto Dunfell.

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building bind with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-connectivity/bind/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building bind with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-connectivity/bind/*.bbappend"
    ```
    
    Then just compile the image that use's `BIND` and include the `wolfSSL`
    package or preform `bitbake bind`

OpenSSH
-------

This supports using `OpenSSH` version: 8.5p1, which was shipped with Yocto Hardknott

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building OpenSSH with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-connectivity/openssh/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building OpenSSH with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-connectivity/openssh/*.bbappend"
    ```
    
    Then just compile the image that use's `OpenSSH` and include the `wolfSSL`
    package or preform `bitbake openssh`


Socat
-----

This supports using `Socat` version: 1.8.0.0, which was shipped with Yocto Dunfell

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building socat with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-connectivity/socat/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building socat with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-connectivity/socat/*.bbappend"
    ```
    
    Then just compile the image that use's `Socat` and include the `wolfSSL`
    package or preform `bitbake socat`

