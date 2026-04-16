SUMMARY = "wolfBoot signed kernel FIT image"
DESCRIPTION = "Signs the kernel FIT image (fitImage / image.ub) with \
wolfBoot RSA4096+SHA3-384 for verified secure boot. The signed output is \
placed in DEPLOY_DIR_IMAGE as image_v<version>_signed.bin, ready for \
flashing to the OFP_A / OFP_B partitions of an A/B-enabled SD card or QSPI."

HOMEPAGE = "https://github.com/wolfssl/wolfBoot"
SECTION = "bootloaders"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-3.0-only;md5=c79ff39f19dfec6d293b95dea7b07891"

inherit deploy

DEPENDS = "wolfboot-keytools-native"

# REQUIRED: absolute path to the same wolfBoot signing private key used by
# wolfboot_git.bb to embed the public key into wolfboot.elf. User-supplied
# out-of-band (never sourced from DEPLOY_DIR_IMAGE or sstate).
WOLFBOOT_SIGNING_KEY ?= ""

# Kernel recipe name -- default matches linux-xlnx on ZynqMP / Versal.
# Override in local.conf for non-Xilinx kernels (e.g. KERNEL_PN = "linux-yocto").
KERNEL_PN ?= "linux-xlnx"

# Only depend on the kernel being deployed. The signing key is supplied
# directly by the user, NOT pulled from wolfboot:do_deploy, so there is no
# wolfboot dep here.
do_compile[depends] += "${KERNEL_PN}:do_deploy"

do_configure[noexec] = "1"

# Version stamped into the signed image header. Increment for A/B updates
# (e.g. set to "2" for the next A/B update image).
WOLFBOOT_IMAGE_VERSION ?= "1"

# Name of the FIT image produced by the kernel recipe. Defaults match
# linux-xlnx on ZynqMP / Versal.
WOLFBOOT_FIT_IMAGE ?= "fitImage"

# Validate WOLFBOOT_SIGNING_KEY only when this recipe actually builds
# (see wolfboot_git.bb for the rationale re: parse-time vs task-time).
python check_wolfboot_signing_key() {
    key = d.getVar('WOLFBOOT_SIGNING_KEY') or ''
    if not key:
        bb.fatal("WOLFBOOT_SIGNING_KEY is not set. Generate a signing key "
                 "with 'wolfboot-keygen --rsa4096 -g <path>.der' and point "
                 "WOLFBOOT_SIGNING_KEY at it (absolute path). The SAME key "
                 "must also be set in wolfboot_git.bb so public/private "
                 "halves match. See recipes-wolfssl/wolfboot/README.md.")
    import os
    if not os.path.isfile(key):
        bb.fatal("WOLFBOOT_SIGNING_KEY='%s' does not exist or is not a "
                 "regular file." % key)
}
do_compile[prefuncs] += "check_wolfboot_signing_key"

do_compile() {
    install -d ${B}

    # Validate the upstream FIT image exists before invoking the signing
    # tool, so a missing/renamed artifact fails with an actionable message
    # instead of a cryptic wolfboot-sign error.
    fit_image="${DEPLOY_DIR_IMAGE}/${WOLFBOOT_FIT_IMAGE}"
    if [ ! -f "$fit_image" ]; then
        bbfatal "FIT image '$fit_image' not found. Check WOLFBOOT_FIT_IMAGE and that ${KERNEL_PN}:do_deploy produced it."
    fi

    # Sign a local copy under ${B} instead of operating directly on the
    # shared DEPLOY_DIR_IMAGE. wolfboot-sign writes its output next to the
    # input; keeping both input and output under ${WORKDIR} avoids races
    # with the kernel's do_deploy (or parallel multiconfig builds) and
    # leaves publishing to do_deploy below.
    cp "$fit_image" ${B}/${WOLFBOOT_FIT_IMAGE}

    # Sign the FIT image with RSA4096 + SHA3-384 using the user-supplied
    # signing key. wolfboot-sign emits the output NEXT TO the input file,
    # naming it <input>_v<version>_signed.bin. Run from ${B} with a
    # relative path so the output lands inside ${B} predictably.
    cd ${B}
    wolfboot-sign --rsa4096 --sha3 \
        ${WOLFBOOT_FIT_IMAGE} \
        ${WOLFBOOT_SIGNING_KEY} \
        ${WOLFBOOT_IMAGE_VERSION}
}

do_install[noexec] = "1"

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${B}/${WOLFBOOT_FIT_IMAGE}_v${WOLFBOOT_IMAGE_VERSION}_signed.bin \
        ${DEPLOYDIR}/image_v${WOLFBOOT_IMAGE_VERSION}_signed.bin
}

addtask deploy before do_build after do_compile
