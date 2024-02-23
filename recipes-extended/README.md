Supported Ports
===============

In this section these projects have been ported to work with specific versions
of packages shipped with yocto to be used with wolfSSL

Rsyslog
-----

This supports using `Rsyslog` version: 8.2106.0, which was shipped with Yocto Honister

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building rsyslog with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-extended/rsyslog/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building rsyslog with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-extended/rsyslog/*.bbappend"
    ```
    
    Then just compile the image that use's `Rsyslog` and include the `wolfSSL`
    package or preform `bitbake Rsyslog`

