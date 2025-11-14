EXTRA_OECONF += " \
    --enable-cmac \
    --enable-aesccm \
    --enable-keygen \
    --enable-fips=v5 \
"

TARGET_CFLAGS += " \
    -DWOLFSSL_PUBLIC_ASN \
    -DHAVE_PUBLIC_FFDHE \
    -DHAVE_FFDHE_3072 \
    -DHAVE_FFDHE_4096 \
    -DWOLFSSL_DH_EXTRA \
    -DWOLFSSL_PSS_SALT_LEN_DISCOVER \
    -DWOLFSSL_PUBLIC_MP \
    -DWOLFSSL_RSA_KEY_CHECK \
    -DNO_MD5 \
"
