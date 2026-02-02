# Non-FIPS wolfSSL configuration for GnuTLS
EXTRA_OECONF += " \
      --enable-cmac \
      --with-eccminsz=192 \
      --enable-ed25519 \
      --enable-ed448 \
      --enable-md5 \
      --enable-curve25519 \
      --enable-curve448 \
      --enable-aesccm \
      --enable-aesxts \
      --enable-aescfb \
      --enable-keygen \
      --enable-shake128 \
      --enable-shake256 \
"

TARGET_CFLAGS += " \
      -DWOLFSSL_PUBLIC_ASN \
      -DHAVE_FFDHE_3072 \
      -DHAVE_FFDHE_4096 \
      -DWOLFSSL_DH_EXTRA \
      -DWOLFSSL_PSS_SALT_LEN_DISCOVER \
      -DWOLFSSL_PUBLIC_MP \
      -DWOLFSSL_RSA_KEY_CHECK \
      -DHAVE_FFDHE_Q \
      -DHAVE_FFDHE_6144 \
      -DHAVE_FFDHE_8192 \
      -DWOLFSSL_ECDSA_DETERMINISTIC_K \
      -DWOLFSSL_VALIDATE_ECC_IMPORT \
      -DRSA_MIN_SIZE=1024 \
      -DWOLFSSL_AES_COUNTER \
"
