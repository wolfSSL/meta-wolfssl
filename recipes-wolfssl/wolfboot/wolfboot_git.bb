SUMMARY = "wolfBoot secure bootloader"
DESCRIPTION = "wolfBoot is a portable, OS-agnostic secure bootloader for \
32-bit and 64-bit targets. It provides verified secure boot with A/B \
update / rollback support. On AMD/Xilinx ZynqMP it replaces U-Boot as \
the second-stage bootloader (FSBL -> PMU FW -> ATF (EL3) -> wolfBoot \
(EL2) -> signed Linux kernel)."

require wolfboot.inc

inherit deploy

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
                 "from the private key with: openssl rsa -in <privkey>.der "
                 "-inform DER -pubout -outform DER -out <pubkey>.der")
    if not os.path.isfile(pub):
        bb.fatal("WOLFBOOT_PUBLIC_KEY='%s' does not exist or is not a "
                 "regular file." % pub)
}
do_compile[prefuncs] += "check_wolfboot_signing_key"

do_compile() {
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
    # compiler still needs --sysroot to find headers and libgcc; we embed
    # it in CC so it applies to both compilation and linking.
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
                "Generate both keys with 'wolfboot-keygen --rsa4096 -g <privkey>.der' " \
                "then extract the public half with 'openssl rsa -in <privkey>.der " \
                "-inform DER -pubout -outform DER -out <pubkey>.der'. Point both " \
                "WOLFBOOT_SIGNING_KEY and WOLFBOOT_PUBLIC_KEY at the respective files."
    fi
    PUBKEY_FOR_MAKE=${WOLFBOOT_PUBLIC_KEY}

    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    SYSROOT_FLAG="--sysroot=${RECIPE_SYSROOT}"
    # KEYGEN_TOOL override: wolfBoot's Makefile otherwise tries to build
    # tools/keytools/keygen using the target cross-compiler and then run
    # the resulting AArch64 binary on the x86_64 build host. Point it at
    # the native keygen from wolfboot-keytools-native instead.
    NATIVE_KEYGEN="$(command -v wolfboot-keygen)"
    make wolfboot.elf \
        CROSS_COMPILE=${TARGET_PREFIX} \
        CC="${TARGET_PREFIX}gcc $SYSROOT_FLAG" \
        LD="${TARGET_PREFIX}gcc $SYSROOT_FLAG" \
        USER_PRIVATE_KEY="${WOLFBOOT_SIGNING_KEY}" \
        USER_PUBLIC_KEY="$PUBKEY_FOR_MAKE" \
        KEYGEN_TOOL="$NATIVE_KEYGEN" \
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
# hosted Linux binary.
INSANE_SKIP:${PN} = "ldflags textrel buildpaths"

FILES:${PN} = "/boot/wolfboot.elf"
SYSROOT_DIRS += "/boot"
