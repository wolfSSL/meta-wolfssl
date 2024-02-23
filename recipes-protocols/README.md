Supported Ports
===============

In this section these projects have been ported to work with specific versions
of packages shipped with yocto to be used with wolfSSL

Net-snmp
-----

This supports using `Net-snmp` version: 5.9, which was shipped with Yocto Gatesgarth 

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building net-snmp with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-protocols/net-snmp/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building net-snmp with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-protocols/net-snmp/*.bbappend"
    ```
    
    Then just compile the image that use's `Net-snmp` and include the `wolfSSL`
    package or preform `bitbake net-snmp`

