wolfTPM Examples and Testing
============================

wolfTPM wrap_test example is included in this layer, which demonstrates
the TPM wrapper API functionality.

The recipes for these applications are located at:
```
meta-wolfssl/recipes-examples/wolftpm/wolftpm-examples.bb
meta-wolfssl/recipes-examples/wolftpm/wolftpm-wrap-test.bb
```

You'll need to compile wolfTPM and the examples. This can be done with
these commands in the build directory:
```
bitbake wolftpm
bitbake wolftpm-examples
```

To install these applications into your image, you will need to edit your
"build/conf/local.conf" file and add the following:

```bash
# Install necessary packages
IMAGE_INSTALL:append = " \
    tpm2-tools \
    tpm2-tss \
    libtss2 \
    libtss2-mu \
    libtss2-tcti-device \
    libtss2-tcti-mssim \
    wolfssl \
    wolftpm \
    wolftpm-wrap-test \
"

IMAGE_LINK_NAME = "core-image-minimal-qemux86-64"
# Enable security features
DISTRO_FEATURES:append = " security"
# Enable TPM support
DISTRO_FEATURES:append = " tpm tpm2"
# If you want all security modules, you can also add
DISTRO_FEATURES:append = " pam apparmor smack"
# Enable kernel TPM support
KERNEL_FEATURES:append = " features/tpm/tpm.scc"
# Machine features
MACHINE_FEATURES:append = " tpm tpm2"
```

To add wolfTPM configurations you can add configurations to the
EXTRA_OECONF variable. For example you can enable debug logging like
this:
```
EXTRA_OECONF += "--enable-debug"
```

Testing with QEMU and TPM Simulator
-----------------------------------

1. Compile your target image
```
bitbake core-image-minimal
```

2. Clean up any existing TPM state:
```
sudo killall swtpm 2>/dev/null
sudo rm -rf /tmp/mytpm1
```

3. Create directory and set permissions:
```
sudo mkdir -p /tmp/mytpm1
sudo chown -R $(whoami):$(whoami) /tmp/mytpm1
chmod 755 /tmp/mytpm1
```

4. Start the TPM simulator (in terminal 1):
```
sudo swtpm socket --tpmstate dir=/tmp/mytpm1 \
    --ctrl type=unixio,path=/tmp/mytpm1/swtpm-sock \
    --log level=20 \
    --tpm2
```

5. Initialize the TPM (in terminal 2):
```
sudo swtpm_setup --tpmstate /tmp/mytpm1 \
    --createek \
    --create-ek-cert \
    --create-platform-cert \
    --lock-nvram \
    --tpm2
```

6. Fix permissions for QEMU access:
```
sudo chown -R $(whoami):$(whoami) /tmp/mytpm1
sudo chmod -R 755 /tmp/mytpm1
sudo chmod 777 /tmp/mytpm1/swtpm-sock
```

7. Start QEMU (in terminal 3):
```
cd ~/poky/build
runqemu qemux86-64 nographic core-image-minimal \
    qemuparams="-chardev socket,id=chrtpm,path=/tmp/mytpm1/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0"
```

8. Run the wolfTPM wrap test
```
cd /usr/bin
./wolftpm-wrap-test
```

Refer to the [wolfTPM Examples README](https://github.com/wolfSSL/wolfTPM/blob/master/examples/README.md) for more information on the examples directory.

Refer to the [meta-wolfssl README](https://github.com/wolfSSL/meta-wolfssl/blob/master/README.md) for more information on setting up your layer.
