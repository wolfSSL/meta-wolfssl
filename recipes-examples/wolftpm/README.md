wolfTPM Examples and Testing
============================

wolfTPM wrap_test example is included in this layer, which demonstrates
the TPM wrapper API functionality.

The recipes for these applications are located at:
```
meta-wolfssl/recipes-examples/wolftpm/wolftpm-examples.bb
meta-wolfssl/recipes-examples/wolftpm/wolftpm-wrap-test.bb
meta-wolfssl/recipes-examples/wolftpm/wolfssl_%.bbappend
```

You'll need to compile wolfTPM, wolfTPM wrap test example, and wolfSSL with
wolfTPM support. This can be done with these commands in the build directory:
```
bitbake wolfssl
bitbake wolftpm
bitbake wolftpm-wrap-test
```

Adding Layers
-------------

Besides adding meta-wolfssl to your bblayers.conf file, you will need to
add the following layers to your bblayers.conf file and clone
them into the poky directory. (Note: You need to have the same Yocto version
for all layers.)

```bash
git clone https://github.com/openembedded/meta-openembedded.git -b <YOCTO-VERSION>
git clone https://git.yoctoproject.org/meta-security -b <YOCTO-VERSION>
```

Add the following layers to your bblayers.conf file:
```bash
BBLAYERS ?= " \
  /path/to/yocto/poky/meta-wolfssl \
  /path/to/yocto/poky/meta-security \
  /path/to/yocto/poky/meta-security/meta-tpm \
  /path/to/yocto/poky/meta-openembedded/meta-oe \
  /path/to/yocto/poky/meta-openembedded/meta-python \
  /path/to/yocto/poky/meta-openembedded/meta-networking \
  /path/to/yocto/poky/meta-openembedded/meta-perl \
  "
```

System Requirements
-------------------

For Ubuntu/Debian systems, install the following packages:
```bash
sudo apt-get install python3-git python3-jinja2 python3-setuptools \
    swtpm swtpm-tools tpm2-tools git socat build-essential
```

Image Install Configuration
---------------------------

To install these applications into your image, you will need to edit your
`build/conf/local.conf` file and add the following:

```bash
# Add TPM packages
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

# Set the image link name
IMAGE_LINK_NAME = "core-image-minimal-qemux86-64"
# Enable security features
DISTRO_FEATURES:append = " security"
# Enable TPM support
DISTRO_FEATURES:append = " tpm tpm2"
# Enable kernel TPM support
KERNEL_FEATURES:append = " features/tpm/tpm.scc"
# Machine features
MACHINE_FEATURES:append = " tpm tpm2"
```

WolfTPM Configuration
---------------------

To add wolfTPM configurations you can add configurations to the
EXTRA_OECONF variable. We need to have --enable-devtpm for the TPM
simulator to work. You can enable debug logging and other configurations
like this:
```
EXTRA_OECONF += "--enable-devtpm --enable-debug"
```

Testing with QEMU and TPM Simulator
-----------------------------------

### Setting up Software TPM on Host Computer

Follow these steps to setup the Software TPM on your host computer. This
will allow you to run the wolfTPM wrap test inside the QEMU.

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

7. Start and run the QEMU (in terminal 3):
```
cd ~/poky/build
runqemu qemux86-64 nographic core-image-minimal \
    qemuparams="-chardev socket,id=chrtpm,path=/tmp/mytpm1/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0"
```

### Running wolfTPM wrap test on QEMU using Software TPM

Now that the TPM is setup, we can run the wolfTPM wrap test inside the QEMU.

1. Run the wolfTPM wrap test
```
cd /usr/bin
./wolftpm-wrap-test
```

You should see the following output:
```
root@qemux86-64:/usr/bin# ./wolftpm-wrap-test
TPM2 Demo for Wrapper API's
Mfg IBM (0), Vendor SW   TPM, Fw 8217.4131 (0x163636), FIPS 140-2 0, CC-EAL4 0
Found 2 persistent handles
Created new RSA Primary Storage Key at 0x81000200
Creating a loaded new TPM 2.0 key Test Passed
RSA Sign/Verify using RSA PKCSv1.5 (SSA) padding
RSA Sign/Verify using RSA PSS padding
RSA Encrypt/Decrypt Test Passed
RSA Encrypt/Decrypt OAEP Test Passed
RSA Encrypt/Decrypt RSAES Test Passed
RSA Key 0x80000001 Exported to wolf RsaKey
wolf RsaKey loaded into TPM: Handle 0x80000000
RSA Private Key Loaded into TPM: Handle 0x80000001
Created new ECC Primary Storage Key at 0x81000201
ECC Sign/Verify Passed
ECC DH Test Passed
ECC Verify Test Passed
ECC Key 0x80000001 Exported to wolf ecc_key
wolf ecc_key loaded into TPM: Handle 0x80000000
ECC Private Key Loaded into TPM: Handle 0x80000001
NV Test (with auth) on index 0x1800201 with 1024 bytes passed
NV Test on index 0x1800200 with 1024 bytes passed
Hash SHA256 test success
HMAC SHA256 test success
Encrypt/Decrypt (known key) test success
Encrypt/Decrypt test success
PCR Test pass
root@qemux86-64:/usr/bin#
```

Refer to the [wolfTPM Examples README](https://github.com/wolfSSL/wolfTPM/blob/master/examples/README.md) for more information on the examples directory.

Refer to the [meta-wolfssl README](https://github.com/wolfSSL/meta-wolfssl/blob/master/README.md) for more information on setting up your layer.
