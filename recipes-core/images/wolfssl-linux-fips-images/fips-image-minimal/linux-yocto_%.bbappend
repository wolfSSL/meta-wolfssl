# Apply wolfSSL kernel randomness patches for FIPS DRBG integration
# This adds callback hooks to drivers/char/random.c and include/linux/random.h
# allowing the wolfSSL kernel module (libwolfssl.ko) to register its FIPS-certified
# DRBG implementation with the kernel.
#
# See: meta-wolfssl/recipes-wolfssl/wolfssl/README-linuxkm-randomness-patch.md

inherit wolfssl-kernel-random
WOLFSSL_KERNEL_RANDOM_PATCH = "6.12"
