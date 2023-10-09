To add wolfssh (and /usr/bin/wolfsshd installed) add the following to the conf/local.cnf file in the build directory.

```
IMAGE_INSTALL_append = " wolfssh "
```

If wanting to increase SFTP throughput the folloing could be added to a wolfssh_%.bbappend file created in the directory meta-wolfssl/recipes-wolfssl/wolfssh/

```
CPPFLAGS_append = "-DWOLFSSH_MAX_SFTP_RW=64000"
```

Instaling the example applications (more robust client applications are in the works, these are examples) could be done by adding the following in the bbappend file.

```
do_install_append() {
    cp ${WORKDIR}/build/examples/client/.libs/client ${D}/usr/bin/wolfssh
    cp ${WORKDIR}/build/examples/sftpclient/.libs/wolfsftp ${D}/usr/bin/
    cp ${WORKDIR}/build/examples/scpclient/.libs/wolfscp ${D}/usr/bin/
}
```



