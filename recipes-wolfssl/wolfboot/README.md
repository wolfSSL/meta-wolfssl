# wolfBoot (Yocto/OE recipes)

Recipes that build [wolfBoot](https://github.com/wolfssl/wolfBoot), wolfSSL's
portable secure bootloader, as part of a Yocto / OpenEmbedded image.

## Recipes

| Recipe | Purpose |
|---|---|
| `wolfboot-keytools-native_git.bb` | Host-side `wolfboot-keygen` and `wolfboot-sign` utilities (RSA4096 key generation, RSA4096+SHA3-384 image signing). |
| `wolfboot_git.bb` | Cross-compiles `wolfboot.elf` (bare-metal, AArch64 / AArch32 / RISC-V). Picks a config from `${S}/config/examples/` per the `WOLFBOOT_CONFIG` variable. Consumes a user-supplied signing key via `WOLFBOOT_SIGNING_KEY` (see "Signing-key provisioning" below). |
| `wolfboot-signed-image.bb` | Signs the kernel FIT image (default `fitImage`) with RSA4096+SHA3-384 and emits `image_v${WOLFBOOT_IMAGE_VERSION}_signed.bin` into `DEPLOY_DIR_IMAGE`. |

A companion `recipes-bsp/bootbin/xilinx-bootbin_%.bbappend` overrides the
AMD/Xilinx `xilinx-bootbin` recipe to swap U-Boot for `wolfboot.elf` in
`BOOT.BIN` on ZynqMP. It only activates when `WOLFBOOT_ENABLE = "1"` is
set in configuration (`local.conf` or a machine `.conf`).

## Signing-key provisioning (required)

`wolfboot_git.bb` and `wolfboot-signed-image.bb` both require you to
supply a pre-generated RSA4096 private key via `WOLFBOOT_SIGNING_KEY`.
The recipes will **not** auto-generate one — that would leak the
private half through sstate and DEPLOY_DIR_IMAGE.

Generate the key pair once on your workstation:

```sh
# One-time host-side build of the keytools (outside Yocto):
make -C /path/to/wolfBoot/tools/keytools keygen sign

# Generate the RSA4096 key pair:
/path/to/wolfBoot/tools/keytools/keygen --rsa4096 \
    -g /secure/path/wolfboot_signing_private_key.der
```

Store `wolfboot_signing_private_key.der` **outside** the build tree — a
secrets manager, an encrypted volume, or at minimum a `.gitignore`d
directory. Back it up: losing the private key means you can never sign
another A/B update image that your deployed `wolfboot.elf` will accept.

## Quick start (AMD/Xilinx ZynqMP, SD-card boot)

Set the following in `local.conf` (or a machine `.conf`). These must live
in configuration, not inside an image recipe: the `xilinx-bootbin`
bbappend reads `WOLFBOOT_ENABLE` at parse time, which runs before any
image recipe is evaluated.

```bitbake
# Activate the xilinx-bootbin bbappend (swap U-Boot for wolfBoot in BOOT.BIN)
WOLFBOOT_ENABLE = "1"

# Ensure the signed FIT image is built alongside the image.
EXTRA_IMAGEDEPENDS:append = " wolfboot-signed-image"

# REQUIRED: absolute path to the pre-generated signing private key.
WOLFBOOT_SIGNING_KEY = "/secure/path/wolfboot_signing_private_key.der"

# Pick a config template from wolfBoot/config/examples/
WOLFBOOT_CONFIG = "zynqmp_sdcard.config"

# Override the Linux rootfs partition in the DTB bootargs fixup.
# Default in the ZynqMP SD-card example is /dev/mmcblk0p4.
WOLFBOOT_LINUX_BOOTARGS_ROOT = "/dev/mmcblk0p4"

# Bump to "2" for A/B update images, etc.
WOLFBOOT_IMAGE_VERSION = "1"
```

Build:

```
bitbake <your-image>
```

Artifacts deployed to `tmp/deploy/images/<MACHINE>/`:

- `BOOT.BIN`                           - FSBL + PMUFW + ATF + wolfBoot.elf
- `wolfboot.elf`                       - bare-metal bootloader
- `wolfboot_signing_public_key.der`    - verifying key (safe to publish; only if `WOLFBOOT_PUBLIC_KEY` is set)
- `image_v1_signed.bin`                - signed FIT image (for OFP_A partition)

Note: the private signing key is **not** deployed — it stays on the
workstation / secrets store you pointed `WOLFBOOT_SIGNING_KEY` at.

## SD card layout (wolfBoot A/B scheme)

| Partition | Size | Type | Contents |
|---|---|---|---|
| p1 | 128 MB | FAT32 | `BOOT.BIN` |
| p2 | 200 MB | raw | `image_v1_signed.bin` (OFP_A = primary) |
| p3 | 200 MB | raw | update slot (OFP_B) |
| p4 | rest | ext4 | Linux rootfs |

See `wolfBoot/tools/scripts/` for helper scripts to create the SD card
and flash update images (once upstreamed).

## Key management

The signing key pair is **user-supplied**, not generated inside the build.
`WOLFBOOT_SIGNING_KEY` must point at a pre-generated RSA4096 private key
file (DER format) — see the "Signing-key provisioning" section at the top
of this README. The recipe:

- Stages the private key at `${S}/wolfboot_signing_private_key.der` so the
  wolfBoot Makefile can derive the public half and compile it into
  `wolfboot.elf` via `src/keystore.c`.
- Does **not** deploy the private key to `DEPLOY_DIR_IMAGE`. Only
  `wolfboot.elf` (and optionally the public key, if `WOLFBOOT_PUBLIC_KEY`
  is set) is deployed.
- `wolfboot-signed-image.bb` reads the same `WOLFBOOT_SIGNING_KEY`
  directly to sign the FIT, so there is no on-disk hand-off of the
  private key between recipes.

To rotate keys:

1. Generate a new RSA4096 key pair with `wolfboot-keygen --rsa4096 -g …`.
   Prefer a **new filename/path** for each rotation (e.g.
   `wolfboot_signing_private_key_v2.der`) rather than overwriting the
   existing `.der` in place — see the caveat below.
2. Update `WOLFBOOT_SIGNING_KEY` to the new private key path.
3. Build: `wolfboot.elf` embeds the new public key, and
   `image_v<N>_signed.bin` is signed with the new private key.
4. Flash the new `BOOT.BIN` (contains new `wolfboot.elf`) to the device,
   followed by a signed update image signed with the new key.

**sstate caveat.** `WOLFBOOT_SIGNING_KEY` points at an absolute path
outside the recipe tree, so BitBake does not checksum the key file's
contents into the task hash — only the path string participates. If you
overwrite the same `.der` file in place with new key material, sstate
and stamps may reuse the previously-built `wolfboot.elf` and signed
image, leaving you with a mismatched public/private pair. To stay safe:

- **Preferred**: rotate to a *new filename/path*. Changing the value of
  `WOLFBOOT_SIGNING_KEY` invalidates the task hash naturally.
- **Fallback** (if you must reuse the same path): force a rebuild with
  `bitbake -c cleansstate wolfboot wolfboot-signed-image` before the
  next `bitbake <your-image>`.

## Swapping U-Boot for wolfBoot

The `recipes-bsp/bootbin/xilinx-bootbin_%.bbappend` rewrites the BIF so
`BOOT.BIN` contains `wolfboot.elf` instead of `u-boot.elf` at EL2, and
drops the standalone DTB partition (wolfBoot loads the DTB out of the
signed FIT image). It activates only when `WOLFBOOT_ENABLE = "1"` is set
in configuration (`local.conf` or a machine `.conf`). Setting it inside
an image recipe is **not** sufficient: the bbappend's anonymous python
runs at parse time, before image recipes are evaluated.

## ZynqMP caveats

See the comments in `wolfBoot/config/examples/zynqmp_sdcard.config` for
two non-obvious points:

1. **Root device**: when the XSA disables `sdhci0` (common on ZCU102
   boards where only the external SD slot is populated), SD1 enumerates
   as `/dev/mmcblk0`, not `/dev/mmcblk1`. The template default is
   `mmcblk0p4`; flip to `mmcblk1p4` only if both sdhci0 + sdhci1 are
   enabled. Controlled via `WOLFBOOT_LINUX_BOOTARGS_ROOT`.

2. **BOOT_EL1**: `BOOT_EL1?=1` in the example is currently inert on
   ZynqMP because `EL2_HYPERVISOR` is defined in `hal/zynq.h` (included
   by `src/boot_aarch64_start.S`) but not in `src/boot_aarch64.c`. wolfBoot
   stays at EL2 before jumping to Linux, which matches standard PetaLinux
   U-Boot behavior. See the comments in the template.
