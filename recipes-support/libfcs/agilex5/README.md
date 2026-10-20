# wolfSSL FCS offload on Altera Agilex 5

This guide builds wolfSSL with Secure Device Manager crypto offload, includes
the result in an Agilex 5 Linux image, deploys that image, and verifies the
packaged wolfCrypt test on the board.

## Prerequisites

- An Agilex 5 GSRD Yocto build configured for the exact board and release.
- This `meta-wolfssl` layer in `BBLAYERS`.
- A layer that builds Altera's libfcs. The 26.1 GSRD's `meta-altera-fpga`
  provides `gsrd-intel-fcs-lib`, and `meta-intel-fpga-refdes` provides
  `socfpga-intel-fcs-lib`. A user recipe that installs the libfcs headers and
  `libFCS.so` also works.
- A wolfSSL revision that contains the Agilex 5 port. wolfSSL 5.9.4 predates
  it; see [Use a wolfSSL revision with the Agilex 5 port](#use-a-wolfssl-revision-with-the-agilex-5-port).
- A kernel exposing `/sys/kernel/fcs_sysfs/platform`. libfcs reads that file
  during initialization. Older Altera kernels such as linux-socfpga 6.12.19
  create `/sys/kernel/fcs_sysfs` without it, and libfcs then fails to start.
- An owner root key hash provisioned in the SDM.

Provisioning is outside this layer's scope. Follow Altera's device-security
procedure and distinguish recoverable virtual-key programming from permanent
eFuse programming before changing a board. A virtual owner key is cleared when
the board loses power and must be reapplied before each cold-boot test. Once an
owner key is active, boot and FPGA configuration artifacts must be signed by
that owner.

Run BitBake on a Linux build server with the memory and storage required by the
GSRD release. Do not run BitBake on the target board.

The 26.1 GSRD source and board-specific build instructions are published in
Altera's
[DK-A5E013BM16AEA GSRD guide](https://altera-fpga.github.io/rel-26.1/embedded-designs/agilex-5/e-series/013B/gsrd/ug-gsrd-agx5e-013b/).
Install `python3-venv` and Kas as described there. If the build server cannot
install Python packages, the official Kas container is an alternative:

```sh
docker pull ghcr.io/siemens/kas/kas:4.8
```

The 26.1 GSRD kernel append uses Bash conditionals in a BitBake task that runs
under `/bin/sh`. Make those conditionals portable before building:

```sh
sed -i \
    -e 's/if \[\[/if [/g' \
    -e 's/\]\]; then/]; then/g' \
    -e 's/" == "/" = "/g' \
    meta-altera-fpga/meta-altera-bsp/recipes-kernel/linux/\
linux-socfpga-lts_%.bbappend
```

Without this correction, `linux-socfpga-lts:do_deploy` reports `[[: not
found` and selects a nonexistent `fit_agilex5_kernel_no_rbf.its` file.

## Add the layer to an Agilex 5 GSRD build

The 26.1 GSRD for the DK-A5E013BM16AEA uses Kas. Add `meta-wolfssl` to the
GSRD `kas.yml` or to a Kas configuration fragment:

```yaml
header:
  version: 17

repos:
  meta-wolfssl:
    url: https://github.com/wolfSSL/meta-wolfssl.git
    branch: master
    layers:
      .:

local_conf_header:
  wolfssl-altera-fcs: |
    WOLFSSL_ALTERA_FCS = "1"
    WOLFSSL_FCS_PROVIDER = "gsrd-intel-fcs-lib"
    IMAGE_INSTALL:append = " wolfssl wolfcrypttest wolfcryptbenchmark "
    # Remove after the first wolfSSL release that contains the Agilex 5 port.
    SRC_URI:pn-wolfssl = "git://github.com/wolfssl/wolfssl.git;nobranch=1;protocol=https"
    SRCREV:pn-wolfssl = "c177f861d0ecba3a998e1cae3d18d21103572aed"
```

Save the fragment as `wolfssl-fcs.yml`. Kas configurations can be combined
without changing the GSRD's supplied `kas.yml`.

For a local `meta-wolfssl` checkout under the GSRD Yocto directory, replace the
repository URL and branch with:

```yaml
  meta-wolfssl:
    path: meta-wolfssl
    layers:
      .:
```

meta-wolfssl does not build libfcs itself. `WOLFSSL_FCS_PROVIDER` names the
recipe that does, and defaults to the 26.1 GSRD's `gsrd-intel-fcs-lib`. Altera's
recipes install only the versioned runtime library, so this layer appends the
unversioned `libFCS.so` linker name to `gsrd-intel-fcs-lib` and
`socfpga-intel-fcs-lib`. Builds using `meta-intel-fpga-refdes` select its
recipe instead:

```bitbake
WOLFSSL_FCS_PROVIDER = "socfpga-intel-fcs-lib"
```

A user supplied recipe must install `libFCS.so` itself. The port has been
validated with libfcs 3.01, the revision built by the 26.1 GSRD.

## Use a wolfSSL revision with the Agilex 5 port

The `--enable-alterafcs` option this layer passes exists only in wolfSSL
releases after 5.9.4. Until the next release, add a bbappend to your own layer,
for example `recipes-wolfssl/wolfssl/wolfssl_%.bbappend`, that builds a wolfSSL
master commit containing the port:

```bitbake
# Remove after the first wolfSSL release that contains the Agilex 5 port.
SRC_URI = "git://github.com/wolfssl/wolfssl.git;nobranch=1;protocol=https"
SRCREV = "c177f861d0ecba3a998e1cae3d18d21103572aed"
```

Keep the revision in `SRCREV`, not as `rev=` in the URL. The `%` append also
matches meta-openembedded's `wolfssl` recipe, which sets its own `SRCREV`, and a
`rev=` parameter would then conflict with it during parsing. The same two
assignments can be placed in `local.conf` or a Kas `local_conf_header` as
`SRC_URI:pn-wolfssl` and `SRCREV:pn-wolfssl`. Without them, `do_configure`
fails on the unrecognized option.

## Build the Agilex 5 image

From the 26.1 DK-A5E013BM16AEA GSRD `software/yocto_linux` directory, build the
same `gsrd-console-image` target documented by Altera:

```sh
source venv/bin/activate
kas build kas.yml:wolfssl-fcs.yml gsrd-console-image
```

With the Kas container, run the equivalent command from the same directory:

```sh
docker run --rm --user "$(id -u):$(id -g)" \
    -e HOME=/work -v "$PWD:/work" -w /work \
    ghcr.io/siemens/kas/kas:4.8 \
    build kas.yml:wolfssl-fcs.yml gsrd-console-image
```

The SD card image is written to BitBake's `DEPLOY_DIR_IMAGE`. Its parent
`TMPDIR` depends on the distribution: Kas 4.x selects `poky` and uses
`build/tmp`, while Kas 5.x defaults to `nodistro` and uses `build/tmp-glibc`.
Ask BitBake for the directory instead of assuming either. From the same
`software/yocto_linux` directory, inspect the image and the installed test in an
initialized OpenEmbedded shell:

```sh
(
    set -e
    source poky/oe-init-build-env build >/dev/null
    deploy="$(bitbake-getvar --value DEPLOY_DIR_IMAGE)"
    image="$deploy/gsrd-console-image-agilex5e_013b.rootfs.wic"
    test -s "$image"
    sha256sum "$image"
    native="$(bitbake-getvar -r gsrd-console-image --value RECIPE_SYSROOT_NATIVE)"
    test -d "$native"
    wic ls -n "$native" "$image"
    wolfcrypt_bins="$(wic ls -n "$native" "$image:2/usr/bin/")"
    printf '%s\n' "$wolfcrypt_bins"
    printf '%s\n' "$wolfcrypt_bins" | grep -q 'wolfcrypttest'
    printf '%s\n' "$wolfcrypt_bins" | grep -q 'wolfcryptbenchmark'
    oe-pkgdata-util find-path /usr/bin/wolfcrypttest
    printf 'image=%s\n' "$image"
)
```

When the image was built with the Kas container, run the same commands, without
the `source` line, through `kas shell` so Yocto's native tools retain the
`/work` path used at build time:

```sh
docker run --rm --user "$(id -u):$(id -g)" \
    -e HOME=/work -v "$PWD:/work" -w /work \
    ghcr.io/siemens/kas/kas:4.8 \
    shell kas.yml:wolfssl-fcs.yml -c '
        set -e
        deploy="$(bitbake-getvar --value DEPLOY_DIR_IMAGE)"
        image="$deploy/gsrd-console-image-agilex5e_013b.rootfs.wic"
        test -s "$image"
        sha256sum "$image"
        native="$(bitbake-getvar -r gsrd-console-image \
            --value RECIPE_SYSROOT_NATIVE)"
        test -d "$native"
        wic ls -n "$native" "$image"
        wolfcrypt_bins="$(wic ls -n "$native" "$image:2/usr/bin/")"
        printf "%s\n" "$wolfcrypt_bins"
        printf "%s\n" "$wolfcrypt_bins" | grep -q wolfcrypttest
        printf "%s\n" "$wolfcrypt_bins" | grep -q wolfcryptbenchmark
        oe-pkgdata-util find-path /usr/bin/wolfcrypttest
        printf "image=%s\n" "$image"
    '
```

The container reports paths under `/work`, which is the current directory on
the host. Either block must exit with status 0. The image must contain a FAT
boot partition and an ext4 root partition, the second `wic ls` command must
show both `wolfcrypttest` and `wolfcryptbenchmark`, and the package lookup must
report `wolfssl`. Keep the printed `image` path and SHA-256 for deployment.

## Deploy the image

Power off the board and remove its microSD card. Attach the card to the build
server, identify the whole device by its capacity, and unmount any mounted
partitions. Device names vary: USB readers commonly appear as `/dev/sdX`, while
built-in readers may appear as `/dev/mmcblkN`. The example below uses the
device observed on the build server; replace it only after checking `lsblk`.
Set `image` to the absolute path printed by the inspection step:

```sh
image=/path/printed/by/inspection/gsrd-console-image-agilex5e_013b.rootfs.wic
card=/dev/mmcblk0

lsblk -o NAME,SIZE,TYPE,TRAN,RM,MODEL,MOUNTPOINTS
test -b "$card"
for part in $(lsblk -lnpo NAME "$card" | tail -n +2); do
    if findmnt -rn -S "$part" >/dev/null; then
        sudo umount "$part"
    fi
done

sudo dd if="$image" of="$card" bs=4M status=progress conv=fsync
image_size=$(stat -Lc %s "$image")
sudo cmp -n "$image_size" "$image" "$card" && echo "WIC verified"
sync
sudo blockdev --flushbufs "$card"
```

Verify the destination with `lsblk` before writing. This operation replaces the
card contents. Do not use a disk containing the build server's root filesystem.
Use a spare card or make a full-device backup first if the existing image must
be recoverable. `cmp` is silent on success; do not remove the card unless it
returns zero and prints `WIC verified`. A built-in MMC reader may not implement
the `eject` command. Once the partitions are unmounted and `blockdev` has
flushed the device, it is safe to remove the card physically.

If the target image enables a package manager and a compatible package feed,
an incremental update is also valid:

```sh
bitbake wolfssl wolfcrypttest
bitbake package-index
```

Publish the generated package feed, refresh the target package index, and
install or upgrade `wolfssl` and `wolfcrypttest` with the target's package
manager. Do not copy a package from a different machine, tune, C library, or
Yocto release.

## Verify on the board

Boot the deployed image and confirm that its packaged files are present:

```sh
test -x /usr/bin/wolfcrypttest
/lib/ld-linux-aarch64.so.1 --list /usr/bin/wolfcrypttest
test -r /sys/kernel/fcs_sysfs/platform
```

If `/sys/kernel/fcs_sysfs/platform` is missing, the kernel is too old for the
libfcs build in the image. libfcs fails to initialize and `wolfcrypttest`
skips the hardware test, so a zero exit status alone does not prove offload.

The DHCP address can change after booting a replacement image. Use the serial
console, the DHCP server's leases, or a local subnet scan to find the target
rather than assuming its previous address is retained.

The GSRD image does not install `ldd` by default. Invoking the AArch64 dynamic
loader with `--list` performs the same runtime dependency check without adding
a diagnostic package to the image.

Run the installed test:

```sh
/usr/bin/wolfcrypttest
```

The run must exit with status 0 and print:

```text
ALTERA-FCS test passed!
```

The Altera subtests require successful hardware operations for RNG, SHA-256,
and AES. They cannot pass solely through wolfSSL software fallback. Device
resident ECDSA and ECDH keys and HMAC verification are also exercised.

If the marker is missing, first confirm `/sys/kernel/fcs_sysfs/platform`
exists. If only the Altera test fails, check SDM provisioning status `0x85`. Status
`0x84` indicates session exhaustion and requires a board power cycle.

## Developer-only smoke test

Copying `${B}/wolfcrypt/test/.libs/testwolfcrypt` directly to a running target
is useful while developing the recipe. It is not the final integration test
because it bypasses image construction, package installation, and runtime
dependency resolution. Use the packaged `/usr/bin/wolfcrypttest` flow above
for release validation.
