Supported Ports
===============

In this section these projects have been ported to work with specific versions
of packages shipped with yocto to be used with wolfSSL

Curl
-----

This supports using `curl` version: 7.82.0, which was shipped with Yocto Kirkstone 

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building curl with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-support/curl/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building curl with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-support/curl/*.bbappend"
    ```
    
    Then just compile the image that use's `curl` and include the `wolfSSL`
    package or preform `bitbake curl`

    
libssh2    
-----

This supports using `libssh2` version: 1.9.0, which was shipped with Yocto Dunfell 
and Gatesgarth

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building libssh2 with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-support/libssh2/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building libssh2 with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-support/libssh2/*.bbappend"
    ```
    
    Then just compile the image that use's `libssh2` and include the `wolfSSL`
    package or preform `bitbake libssh2`
    
strongSwan
-----

This supports using `strongSwan` version: 5.9.4, which was shipped with Yocto Honister 

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building strongSwan with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-support/strongswan/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building strongSwan with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-support/strongswan/*.bbappend"
    ```
    
    Then just compile the image that use's `strongSwan` and include the `wolfSSL`
    package or preform `bitbake strongswan`
    
tcpdump
-----

This supports using `tcpdump` version: 4.9.3, which was shipped with Yocto Warrior, 
Zeus, Dunfell, and Gatesgarth 

- Usage:
    Change the line in the `meta-wolfssl/conf/layer.conf` from:
    ```
    # Uncomment if building tcpdump with wolfSSL.
    #BBFILES += "${LAYERDIR}/recipes-support/tcpdump/*.bbappend"
    ```
    to:
    ```
    # Uncomment if building tcpdump with wolfSSL.
    BBFILES += "${LAYERDIR}/recipes-support/tcpdump/*.bbappend"
    ```
    
    Then just compile the image that use's `tcpdumb` and include the `wolfSSL`
    package or preform `bitbake tcpdumb`
