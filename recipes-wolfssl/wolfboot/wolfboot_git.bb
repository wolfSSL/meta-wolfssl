SUMMARY = "wolfBoot secure bootloader"
DESCRIPTION = "wolfBoot is a portable, OS-agnostic secure bootloader for \
32-bit and 64-bit targets. It provides verified secure boot with A/B \
update / rollback support. On AMD/Xilinx ZynqMP it replaces U-Boot as \
the second-stage bootloader (FSBL -> PMU FW -> ATF (EL3) -> wolfBoot \
(EL2) -> signed Linux kernel)."

require wolfboot.inc

inherit deploy wolfssl-compatibility

# Keep this recipe out of 'bitbake world' for the same reason as
# wolfboot-signed-image.bb: do_compile requires a signing key pair that the
# user supplies out-of-band, so an unattended world build can only ever fail
# here. Build it explicitly, or pull it in from an image recipe.
EXCLUDE_FROM_WORLD = "1"

# Which config/examples/*.config template to build against. Override in
# local.conf / image recipe to target a different board or boot medium.
# Examples: zynqmp_sdcard.config, zynqmp.config (QSPI), versal_sdcard.config
WOLFBOOT_CONFIG ??= "zynqmp_sdcard.config"

# Linux rootfs device passed via the DTB /chosen/bootargs root= patch in
# src/fdt.c. Override to match your partition layout. The wolfBoot ZynqMP
# example configs hard-code a sensible default but it is far easier to
# flip this single variable than to ship a custom .config fork.
WOLFBOOT_LINUX_BOOTARGS_ROOT ??= ""

# REQUIRED: absolute path to a pre-generated wolfBoot signing private key
# (DER format, RSA4096 by default). Generate once via
# `wolfboot-keygen --rsa4096 -g wolfboot_signing_private_key.der` and store
# outside the build tree (never inside DEPLOY_DIR_IMAGE or sstate).
# See README.md for the full provisioning workflow.
WOLFBOOT_SIGNING_KEY ?= ""

# OPTIONAL: absolute path to a pre-generated wolfBoot signing public key
# (DER format). If unset, wolfBoot's keygen derives the public key from the
# private key in-memory to populate src/keystore.c. Only set this if you
# want to pin a public key independent of the private key file (e.g. HSM).
WOLFBOOT_PUBLIC_KEY ?= ""

# keytools-native provides wolfboot-keygen (used only when deriving the
# public half from a supplied private key) and wolfboot-sign (used by
# wolfboot-signed-image.bb for FIT image signing).
DEPENDS = "wolfboot-keytools-native"

# Additional flags passed to 'make wolfboot.elf'. These are command-line
# overrides, so they take precedence over .config assignments. WARNING:
# do NOT use this for CFLAGS_EXTRA — command-line CFLAGS_EXTRA+= would
# replace ALL file-level CFLAGS_EXTRA lines, wiping out critical defines
# like SDHCI_FORCE_CARD_DETECT. Use WOLFBOOT_EXTRA_CONFIG_LINES instead.
WOLFBOOT_EXTRA_MAKE_FLAGS ?= ""

# Extra lines appended to the .config after the template is copied.
# Use this for CFLAGS_EXTRA additions (e.g. "CFLAGS_EXTRA+=-O2") so they
# coexist with the template's own CFLAGS_EXTRA lines.
WOLFBOOT_EXTRA_CONFIG_LINES ?= ""

# Link with -nostdlib: for configs built for an ABI the sysroot's libgcc does
# not match (PolarFire SoC M-mode is soft-float lp64 on an lp64d toolchain).
WOLFBOOT_NOSTDLIB ?= "0"

COMPATIBLE_MACHINE = ".*"
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_configure[noexec] = "1"

# Validate WOLFBOOT_SIGNING_KEY only when this recipe actually builds.
# A parse-time anonymous python () {} would fail any bitbake invocation
# that merely parses meta-wolfssl (e.g. unrelated CI running
# `bitbake -c cleanall wolfssl`); a named prefunc runs only when
# do_compile is scheduled.
python check_wolfboot_signing_key() {
    import os
    key = d.getVar('WOLFBOOT_SIGNING_KEY') or ''
    if not key:
        bb.fatal("WOLFBOOT_SIGNING_KEY is not set. Generate a signing key "
                 "with 'wolfboot-keygen --rsa4096 -g <path>.der' and point "
                 "WOLFBOOT_SIGNING_KEY at it (absolute path). See "
                 "recipes-wolfssl/wolfboot/README.md for the full workflow.")
    if not os.path.isfile(key):
        bb.fatal("WOLFBOOT_SIGNING_KEY='%s' does not exist or is not a "
                 "regular file." % key)
    pub = d.getVar('WOLFBOOT_PUBLIC_KEY') or ''
    if not pub:
        bb.fatal("WOLFBOOT_PUBLIC_KEY is not set. Extract the public half "
                 "from the private key (RSA: openssl rsa -pubout; ECC: the "
                 "first Qx||Qy bytes, see recipes-wolfssl/wolfboot/README.md).")
    if not os.path.isfile(pub):
        bb.fatal("WOLFBOOT_PUBLIC_KEY='%s' does not exist or is not a "
                 "regular file." % pub)
}
do_compile[prefuncs] += "check_wolfboot_signing_key"

do_compile() {
    # A re-run of do_compile keeps the tree; drop objects built with the
    # previous .config (make tracks sources, not flags).
    find ${S} \( -name '*.o' -o -name '*.d' \) -not -path '*/.git/*' -delete
    if [ -n "${WOLFBOOT_WOLFSSL_SRC}" ] && [ -d "${WOLFBOOT_WOLFSSL_STAGED_SRC}" ]; then
        find ${WOLFBOOT_WOLFSSL_STAGED_SRC} \( -name '*.o' -o -name '*.d' \) -delete
    fi
    rm -f ${S}/wolfboot.elf ${S}/wolfboot.map ${S}/src/keystore.c

    # Seed wolfBoot's Makefile with the requested example .config.
    if [ ! -f ${S}/config/examples/${WOLFBOOT_CONFIG} ]; then
        bbfatal "WOLFBOOT_CONFIG='${WOLFBOOT_CONFIG}' not found under ${S}/config/examples/"
    fi
    cp ${S}/config/examples/${WOLFBOOT_CONFIG} ${S}/.config

    # Append any extra config lines (e.g. CFLAGS_EXTRA+=-O2 from a bbappend).
    if [ -n "${WOLFBOOT_EXTRA_CONFIG_LINES}" ]; then
        echo "${WOLFBOOT_EXTRA_CONFIG_LINES}" >> ${S}/.config
    fi

    # Optionally override the Linux rootfs device in the compiled-in bootargs.
    if [ -n "${WOLFBOOT_LINUX_BOOTARGS_ROOT}" ]; then
        sed -i -e 's|-DLINUX_BOOTARGS_ROOT=\\"[^"]*\\"|-DLINUX_BOOTARGS_ROOT=\\"${WOLFBOOT_LINUX_BOOTARGS_ROOT}\\"|' \
            ${S}/.config
    fi

    # Cross-compile wolfboot.elf.
    # wolfBoot is a bare-metal bootloader (-nostdlib -ffreestanding), so we
    # use raw make (not oe_runmake) to prevent Yocto's CC/CFLAGS/LDFLAGS
    # from overriding wolfBoot's own toolchain settings. The Yocto cross
    # compiler still needs --sysroot to find headers and libgcc; it is
    # appended to the .config below so it applies to compilation and linking.
    #
    # USER_PRIVATE_KEY + USER_PUBLIC_KEY tell wolfBoot's Makefile to use a
    # pre-generated key pair instead of regenerating one inside the build
    # tree (upstream contract, see wolfBoot/Makefile:371). This sidesteps
    # the fact that wolfBoot's in-tree keytools target would otherwise try
    # to cross-compile keygen for AArch64 and then run the resulting
    # AArch64 binary on the x86_64 build host -- which fails under qemu
    # inside Docker if AArch64 binfmt isn't set up.
    #
    # wolfBoot's Makefile requires both USER_PRIVATE_KEY and USER_PUBLIC_KEY.
    # Both must be supplied by the user (generate via wolfboot-keygen).
    if [ -z "${WOLFBOOT_PUBLIC_KEY}" ] || [ ! -f "${WOLFBOOT_PUBLIC_KEY}" ]; then
        bbfatal "WOLFBOOT_PUBLIC_KEY is not set or the file does not exist. " \
                "Generate the key pair with wolfboot-keygen and extract the public " \
                "half (RSA: openssl rsa -pubout; ECC: the first Qx||Qy bytes), see " \
                "recipes-wolfssl/wolfboot/README.md. Point WOLFBOOT_SIGNING_KEY and " \
                "WOLFBOOT_PUBLIC_KEY at the respective files."
    fi
    PUBKEY_FOR_MAKE=${WOLFBOOT_PUBLIC_KEY}

    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    SYSROOT_FLAG="--sysroot=${RECIPE_SYSROOT}"

    # glibc's <gnu/stubs.h> includes a per-ABI stubs-<abi>.h; when wolfBoot's
    # -mabi differs from the sysroot's that file is missing. It only lists
    # libc stubs, meaningless to a -nostdlib image, so supply empty ones.
    LIBC_STUBS="${WORKDIR}/libc-stubs"
    rm -rf "$LIBC_STUBS"; mkdir -p "$LIBC_STUBS/gnu"
    for abi in lp64 lp64d ilp32 ilp32d 64 32 soft hard; do
        if [ ! -e "${RECIPE_SYSROOT}/usr/include/gnu/stubs-$abi.h" ]; then
            : > "$LIBC_STUBS/gnu/stubs-$abi.h"
        fi
    done
    SYSROOT_FLAG="$SYSROOT_FLAG -isystem $LIBC_STUBS"

    # Toolchain flags go through .config (CFLAGS_EXTRA / LDFLAGS_EXTRA are
    # additive there); CC/LD on the make command line would leak the cross
    # compiler into the sub-makes that build the host tools. No PIE and no
    # build-id note: the image is linked at fixed addresses from its boot vector.
    echo "CFLAGS_EXTRA+=$SYSROOT_FLAG -fno-pie" >> ${S}/.config
    LD_EXTRA="$SYSROOT_FLAG -no-pie -Wl,--build-id=none"
    if [ "${WOLFBOOT_NOSTDLIB}" = "1" ]; then
        LD_EXTRA="$LD_EXTRA -nostdlib"
    fi
    # A wolfBoot without the LDFLAGS_EXTRA consumer (options.mk) gets the link
    # flags the old way, as CC and LD overrides on the command line.  Both,
    # not just LD: such a wolfBoot also builds its in-tree keytools, whose
    # sub-make inherits the command-line variables, and the host objects it
    # compiles with its own CC do not link with the cross LD.
    CC_ARG=""
    LD_ARG=""
    if grep -Eq 'LDFLAGS[[:space:]]*\+=[[:space:]]*\$\(LDFLAGS_EXTRA\)' ${S}/options.mk; then
        echo "LDFLAGS_EXTRA+=$LD_EXTRA" >> ${S}/.config
    else
        CC_ARG="CC=${TARGET_PREFIX}gcc $SYSROOT_FLAG"
        LD_ARG="LD=${TARGET_PREFIX}gcc $LD_EXTRA"
    fi

    # Native keytools; with both given, wolfBoot skips its in-tree build.
    NATIVE_KEYGEN="$(command -v wolfboot-keygen)"
    NATIVE_SIGN="$(command -v wolfboot-sign)"

    # Build wolfCrypt from a caller-supplied wolfSSL tree when asked.
    # WOLFBOOT_LIB_WOLFSSL is wolfBoot's way to set an external wolfSSL source
    # location. Leaving it unset keeps the in-tree lib/wolfssl fetched
    # by wolfboot.inc. Always point it at the WORKDIR copy staged by
    # do_stage_external_wolfssl, never at the caller's tree because the build
    # needs to write object files into this directory. Unquoted below so it
    # vanishes when empty.
    WOLFSSL_LIB_ARG=""
    if [ -n "${WOLFBOOT_WOLFSSL_SRC}" ]; then
        WOLFSSL_LIB_ARG="WOLFBOOT_LIB_WOLFSSL=${WOLFBOOT_WOLFSSL_STAGED_SRC}"
        bbnote "wolfBoot: building wolfCrypt from ${WOLFBOOT_WOLFSSL_SRC}" \
               "(staged at ${WOLFBOOT_WOLFSSL_STAGED_SRC})"
    fi

    make wolfboot.elf \
        CROSS_COMPILE=${TARGET_PREFIX} \
        ${CC_ARG:+"$CC_ARG"} \
        ${LD_ARG:+"$LD_ARG"} \
        USER_PRIVATE_KEY="${WOLFBOOT_SIGNING_KEY}" \
        USER_PUBLIC_KEY="$PUBKEY_FOR_MAKE" \
        KEYGEN_TOOL="$NATIVE_KEYGEN" \
        SIGN_TOOL="$NATIVE_SIGN" \
        $WOLFSSL_LIB_ARG \
        ${WOLFBOOT_EXTRA_MAKE_FLAGS} \
        V=1
}

do_install() {
    # Install wolfboot.elf into sysroot for xilinx-bootbin BIF consumption
    # (BIF_PARTITION_IMAGE[wolfboot] points at ${RECIPE_SYSROOT}/boot/wolfboot.elf).
    install -d ${D}/boot
    install -m 0644 ${S}/wolfboot.elf ${D}/boot/wolfboot.elf
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${S}/wolfboot.elf ${DEPLOYDIR}/wolfboot.elf
    # Optionally deploy the public signing key (safe to publish). This is
    # the verifying key embedded in wolfboot.elf; having it in DEPLOYDIR
    # lets CI and downstream tooling verify signed images without access
    # to the private key.
    if [ -n "${WOLFBOOT_PUBLIC_KEY}" ] && [ -f "${WOLFBOOT_PUBLIC_KEY}" ]; then
        install -m 0644 ${WOLFBOOT_PUBLIC_KEY} ${DEPLOYDIR}/wolfboot_signing_public_key.der
    fi
    # NOTE: the private key (wolfboot_signing_private_key.der) is
    # intentionally NOT deployed. User-supplied out-of-band via
    # WOLFBOOT_SIGNING_KEY; publishing it would defeat the point of signed
    # boot.
}

addtask deploy before do_build after do_compile

# wolfBoot is a bare-metal bootloader -- skip QA checks that assume a
# hosted Linux binary. Use the compatibility helpers so the package
# override resolves to the right separator (colon vs underscore) across
# Yocto versions -- older releases such as Thud still use underscore
# overrides and cannot parse the colon syntax.
python __anonymous() {
    wolfssl_varSet(d, 'INSANE_SKIP', '${PN}', 'ldflags textrel buildpaths')
    wolfssl_varSet(d, 'FILES', '${PN}', '/boot/wolfboot.elf')
}

SYSROOT_DIRS += "/boot"
