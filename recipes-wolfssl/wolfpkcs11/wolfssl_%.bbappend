EXTRA_OECONF += "--enable-aescfb --enable-rsapss --enable-keygen --enable-pwdbased --enable-scrypt"
TARGET_CFLAGS += "-DWOLFSSL_PUBLIC_MP -DWC_RSA_DIRECT -DHAVE_AES_ECB -DHAVE_AES_KEYWRAP"
