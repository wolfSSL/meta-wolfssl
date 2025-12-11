# wolfssl-kernel-random.bbclass
#
# This class applies wolfSSL random callback patches to the Linux kernel.
# It fetches patches directly from the wolfSSL GitHub repository.
#
# Usage: In your kernel bbappend (e.g., linux-jammy-nvidia-tegra.bbappend):
#
#   inherit wolfssl-kernel-random
#   WOLFSSL_KERNEL_RANDOM_PATCH = "5.17-ubuntu-jammy-tegra"
#
# Available patches: https://github.com/wolfSSL/wolfssl/tree/master/linuxkm/patches
#
# Common values for WOLFSSL_KERNEL_RANDOM_PATCH:
#   - "5.10.17"
#   - "5.10.236"
#   - "5.15"
#   - "5.17"
#   - "5.17-ubuntu-jammy-tegra"  (for NVIDIA Tegra/Jetson)
#   - "6.1.73"
#   - "6.12"
#   - "6.15"

# User must set this to the patch directory name
WOLFSSL_KERNEL_RANDOM_PATCH ?= ""

# wolfSSL repository for fetching patches
WOLFSSL_PATCHES_REPO ?= "git://github.com/wolfSSL/wolfssl.git;protocol=https;branch=master"
WOLFSSL_PATCHES_SRCREV ?= "${AUTOREV}"

# Add wolfSSL source fetch for patches
SRC_URI += "${WOLFSSL_PATCHES_REPO};name=wolfssl-patches;destsuffix=wolfssl-patches;nobranch=1"
SRCREV_wolfssl-patches = "${WOLFSSL_PATCHES_SRCREV}"

# Apply wolfSSL kernel randomness patches
do_patch:prepend() {
    if [ -n "${WOLFSSL_KERNEL_RANDOM_PATCH}" ]; then
        patch_dir="${WORKDIR}/wolfssl-patches/linuxkm/patches/${WOLFSSL_KERNEL_RANDOM_PATCH}"

        if [ ! -d "$patch_dir" ]; then
            bbfatal "wolfSSL: Patch directory not found: $patch_dir"
            bbfatal "wolfSSL: Check available patches at https://github.com/wolfSSL/wolfssl/tree/master/linuxkm/patches"
        fi

        bbnote "wolfSSL: Applying kernel randomness patches from: $patch_dir"

        # Apply all patches in the directory
        for patch_file in "$patch_dir"/*.patch; do
            if [ -f "$patch_file" ]; then
                bbnote "wolfSSL: Applying patch: $(basename $patch_file)"
                
                # Check if patch is already applied
                if patch -p1 -R --dry-run -d ${S} < "$patch_file" >/dev/null 2>&1; then
                    bbnote "wolfSSL: Patch already applied, skipping: $(basename $patch_file)"
                else
                    patch -p1 -d ${S} < "$patch_file" || {
                        bbfatal "wolfSSL: Failed to apply patch: $patch_file"
                    }
                fi
            fi
        done

        bbnote "wolfSSL: Kernel randomness patches applied successfully."
    else
        bbnote "wolfSSL: WOLFSSL_KERNEL_RANDOM_PATCH not set, skipping kernel patching."
    fi
}
