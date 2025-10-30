# Configure wolfssl for libgcrypt integration

EXTRA_OECONF += " --enable-ed25519 --enable-ed448 --enable-curve25519 --enable-sha224 --enable-md5 --enable-aesctr --enable-aescfb --enable-aesccm --enable-aesofb --enable-keygen --enable-rsa --disable-harden --enable-cmac --enable-shake128 --enable-shake256 --enable-ecc --disable-examples "

TARGET_CFLAGS += "-DWOLFSSL_AES_EAX -DWOLFSSL_AES_SIV -DWOLFSSL_AES_XTS -DWOLFSSL_AES_CFB -DHAVE_AES_ECB -DWOLFSSL_AESGCM_STREAM -DWC_RSA_DIRECT -DWC_RSA_NO_PADDING -DWOLFSSL_PUBLIC_MP -DWOLFSSL_RSA_KEY_CHECK -DHAVE_FIPS_VERSION=5 -DACVP_VECTOR_TESTING -DWOLFSSL_ECDSA_SET_K -DHAVE_ALL_CURVES -DWC_RNG_SEED_CB -DHAVE_POLY1305"
