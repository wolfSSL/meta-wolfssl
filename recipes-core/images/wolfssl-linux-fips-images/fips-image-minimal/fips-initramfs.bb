SUMMARY = "Minimal initramfs with wolfSSL FIPS kernel module"
DESCRIPTION = "An initramfs image that loads the wolfSSL FIPS kernel module early in the boot process, before the root filesystem is mounted."

LICENSE = "MIT"

# Include wolfssl-linuxkm (will use -fips version if PREFERRED_PROVIDER is set)
PACKAGE_INSTALL = "initramfs-framework-base initramfs-module-udev initramfs-module-setup-live wolfssl-linuxkm busybox udev base-passwd ${ROOTFS_BOOTSTRAP_INSTALL}"

# Set the image fstypes to cpio.gz (required for kernel bundling)
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

# Don't allow the initramfs to contain a kernel
PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_NAME_SUFFIX ?= ""
IMAGE_LINGUAS = ""

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

# Inherit core-image for basic image functionality
inherit core-image

# Inherit wolfssl-initramfs helpers
inherit wolfssl-initramfs

# Use the bbclass methods as documented
ROOTFS_POSTPROCESS_COMMAND += "wolfssl_initramfs_run_depmod; "
ROOTFS_POSTPROCESS_COMMAND += "wolfssl_initramfs_inject_after_loadmodules; "
