# Agilex 5 wolfBoot integration

This integration targets the Altera Agilex 5 DK-A5E013BM16AEA, machine
`agilex5e_013b`, using the GSRD Yocto flow. It preserves the supported
platform boot chain:

```text
SDM -> U-Boot SPL -> TF-A BL31/EL3 -> wolfBoot BL33/EL2 -> signed kernel FIT
```

U-Boot SPL continues to initialize DDR, clocks, resets, pinmux and SD6HC.
TF-A continues to own EL3, PSCI, GICv3 and the security-controller setup.
The SoCFPGA recipe replaces only the U-Boot-proper loadable in `u-boot.itb`
with `wolfboot.bin` at `0x80200000`.

libfcs is not linked into wolfBoot. The wolfSSL, libfcs, `wolfcrypttest` and
`wolfcryptbenchmark` packages remain Linux software in the root filesystem.

When wolfBoot is enabled, this layer regenerates the GSRD kernel FIT with an
uncompressed Linux payload. The stock GSRD deploy append creates an LZMA FIT;
wolfBoot deliberately accepts only the supported FIT compression modes, so the
image must use the uncompressed form selected by the Agilex 5 machine config.

## Inputs

Use the matching wolfSSL Agilex 5 port and meta-wolfSSL FCS fragment described
in `recipes-support/libfcs/agilex5/README.md`. Keep three key domains separate:

1. SDM virtual owner key for Linux FCS requests.
2. Platform key used by the GSRD boot authentication flow, if enabled.
3. wolfBoot firmware-signing key used for the A/B Linux payloads.

Never store private keys in this layer, the build directory or deploy output.
For development, generate a dedicated wolfBoot key pair outside the checkout
as described in the parent `README.md`, then set these absolute paths in a
private Kas fragment or `local.conf`:

```bitbake
WOLFBOOT_SIGNING_KEY = "/secure/path/wolfboot_signing_private_key.der"
WOLFBOOT_PUBLIC_KEY = "/secure/path/wolfboot_signing_public_key.der"
```

Before a cold-boot FCS test, repeat the development-board virtual-owner
provisioning procedure in `recipes-support/libfcs/agilex5/README.md`. It uses
Quartus Programmer and a recoverable virtual key; it is separate from the
wolfBoot signing key and any permanent SDM/eFuse provisioning.

## Build with Kas

Append both meta-wolfSSL fragments to the normal GSRD build:

```sh
cp meta-wolfssl/recipes-wolfssl/wolfboot/agilex5/kas-wolfboot.yml ./kas-wolfboot.yml
kas build kas.yml:kas/image/gsrd-console-image.yaml:kas-wolfboot.yml:wolfboot-secrets.yml gsrd-console-image
```

The wolfBoot fragment also enables the matching FCS provider and installs the
packaged wolfCrypt tests, so this is one customer image flow rather than two
independent layer configurations. Kas requires concatenated files to come
from one checkout; keep the copied fragment local and untracked, and keep
`wolfboot-secrets.yml` outside version control.

The exact FCS fragment filename can differ in a downstream GSRD checkout.
Use the one documented by the libfcs Agilex guide. The wolfBoot fragment sets:

- the Agilex 5 wolfBoot config and pinned source revision;
- Linux root device `/dev/mmcblk0p4`;
- `kernel.itb` as the signed wolfBoot payload;
- the four-partition WIC definition;
- task dependencies for wolfBoot, signing and WIC assembly.

## Image layout

The resulting WIC has this DOS partition table:

| Partition | Size | Contents |
|---|---:|---|
| p1 | 128 MiB | FAT boot files, including SPL inputs and `u-boot.itb` |
| p2 | 200 MiB | raw wolfBoot A slot, initialized with version 1 |
| p3 | 200 MiB | raw wolfBoot B slot, initialized with version 1 |
| p4 | 1500 MiB | ext4 Linux root filesystem |

Both A and B are initialized so a first-boot fallback never selects an empty
slot. Subsequent update images must increment `WOLFBOOT_IMAGE_VERSION`.

## Preflash validation

Before writing removable media, record the revisions and image hash, then
inspect the artifacts:

```sh
# GSRD separates libc-specific output under tmp-glibc.
deploy=build/tmp-glibc/deploy/images/agilex5e_013b
fdtdump "$deploy/u-boot.itb"
fdisk -l "$deploy/gsrd-console-image-agilex5e_013b.rootfs.wic"
sha256sum "$deploy/gsrd-console-image-agilex5e_013b.rootfs.wic"
```

Require the FIT to retain its `atf` and `fdt-0` nodes, identify the BL33
loadable as wolfBoot, and keep its load address at `0x80200000`. Require four
partitions with Linux in p4. Also inspect both raw slots against the signed
image using byte-limited comparisons at their exact WIC offsets.

## Hardware acceptance

Flash only after resolving the removable card by model, size and transport.
Compare the complete WIC byte span after writing it, flush buffers, safely
remove the card, then cold boot the board.

Acceptance requires all of the following:

1. SPL loads the unchanged TF-A firmware node and TF-A enters wolfBoot at EL2.
2. wolfBoot verifies and boots the signed A image.
3. Linux mounts `/dev/mmcblk0p4`, brings all four CPUs online and performs a
   PSCI reboot successfully.
4. `/usr/bin/wolfcrypttest` exits zero and prints
   `ALTERA-FCS test passed!` after virtual owner-key provisioning.
5. A disposable-card test with only slot A corrupted boots the valid B slot.

Do not claim secure-boot validation from a software-only CI build. CI proves
configuration, compilation and no-hardware fallback behavior; the exact WIC
and physical board prove the boot and FCS contracts.
