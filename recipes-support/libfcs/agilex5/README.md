# wolfSSL FCS offload on Altera Agilex 5

This guide builds wolfSSL with Secure Device Manager crypto offload, includes
the result in an Agilex 5 Linux image, deploys that image, and verifies the
packaged wolfCrypt test on the board.

## Prerequisites

- An Agilex 5 GSRD Yocto build configured for the exact board and release.
- This `meta-wolfssl` layer in `BBLAYERS`.
- A kernel exposing `/sys/kernel/fcs_sysfs`.
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

The 26.1 GSRD already provides the required headers and versioned runtime
library through `gsrd-intel-fcs-lib`. This layer adds the unversioned
`libFCS.so` linker name required by dependent recipes. Selecting the GSRD
provider prevents two recipes from installing the same library. A non-GSRD
build can omit the override and use meta-wolfssl's `libfcs` recipe instead.

```bitbake
WOLFSSL_FCS_PROVIDER = "gsrd-intel-fcs-lib"
```

Use only one provider for `libFCS.so`.

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

The expected SD card image is:

```text
build/tmp/deploy/images/agilex5e_013b/gsrd-console-image-agilex5e_013b.rootfs.wic
```

Fail the validation if that file is absent or empty:

```sh
test -s build/tmp/deploy/images/agilex5e_013b/\
gsrd-console-image-agilex5e_013b.rootfs.wic
sha256sum build/tmp/deploy/images/agilex5e_013b/\
gsrd-console-image-agilex5e_013b.rootfs.wic
```

Inspect the partition table and the installed test from an initialized
OpenEmbedded shell:

```sh
(
    source poky/oe-init-build-env build
    image=tmp/deploy/images/agilex5e_013b/\
gsrd-console-image-agilex5e_013b.rootfs.wic
    native="$(find "$PWD/tmp/work" -type d \
        -path '*/gsrd-console-image/*/recipe-sysroot-native' \
        -print -quit)"
    test -n "$native"
    wic ls -n "$native" "$image"
    wolfcrypt_bins="$(wic ls -n "$native" "$image:2/usr/bin/")"
    printf '%s\n' "$wolfcrypt_bins"
    printf '%s\n' "$wolfcrypt_bins" | grep -q 'wolfcrypttest'
    printf '%s\n' "$wolfcrypt_bins" | grep -q 'wolfcryptbenchmark'
    oe-pkgdata-util find-path /usr/bin/wolfcrypttest
)
```

When the image was built with the Kas container, run the same checks through
`kas shell` so Yocto's native tools retain the `/work` path used at build time:

```sh
docker run --rm --user "$(id -u):$(id -g)" \
    -e HOME=/work -v "$PWD:/work" -w /work \
    ghcr.io/siemens/kas/kas:4.8 \
    shell kas.yml:wolfssl-fcs.yml -c '
        image=tmp/deploy/images/agilex5e_013b/\
gsrd-console-image-agilex5e_013b.rootfs.wic
        native="$(find "$PWD/tmp/work" -type d \
            -path "*/gsrd-console-image/*/recipe-sysroot-native" \
            -print -quit)"
        test -n "$native"
        wic ls -n "$native" "$image"
        wolfcrypt_bins="$(wic ls -n "$native" "$image:2/usr/bin/")"
        printf "%s\n" "$wolfcrypt_bins"
        printf "%s\n" "$wolfcrypt_bins" | grep -q wolfcrypttest
        printf "%s\n" "$wolfcrypt_bins" | grep -q wolfcryptbenchmark
        oe-pkgdata-util find-path /usr/bin/wolfcrypttest
    '
```

The image must contain a FAT boot partition and an ext4 root partition. The
second `wic ls` command must show both `wolfcrypttest` and
`wolfcryptbenchmark`, and the package lookup must report `wolfssl`.

Confirm that BitBake also staged the packaged test:

```sh
test -n "$(find build/tmp/work \
    -path '*/wolfssl/*/packages-split/*/usr/bin/wolfcrypttest' \
    -print -quit)"
```

## Deploy the image

Power off the board and remove its microSD card. Attach the card to the build
server, identify the whole device by its capacity, and unmount any mounted
partitions. Device names vary: USB readers commonly appear as `/dev/sdX`, while
built-in readers may appear as `/dev/mmcblkN`. The example below uses the
device observed on the build server; replace it only after checking `lsblk`:

```sh
image=build/tmp/deploy/images/agilex5e_013b/\
gsrd-console-image-agilex5e_013b.rootfs.wic
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
test -e /sys/kernel/fcs_sysfs
```

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

If only the Altera test fails, check SDM provisioning status `0x85`. Status
`0x84` indicates session exhaustion and requires a board power cycle.

## Developer-only smoke test

Copying `${B}/wolfcrypt/test/.libs/testwolfcrypt` directly to a running target
is useful while developing the recipe. It is not the final integration test
because it bypasses image construction, package installation, and runtime
dependency resolution. Use the packaged `/usr/bin/wolfcrypttest` flow above
for release validation.
