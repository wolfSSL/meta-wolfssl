EXTRA_OECONF += "--enable-aes --enable-aescfb --enable-aescbc --enable-rsapss --enable-keygen --enable-pwdbased --enable-scrypt"
TARGET_CFLAGS += "-DWOLFSSL_PUBLIC_MP -DWC_RSA_DIRECT -DHAVE_AES_ECB -DHAVE_AES_KEYWRAP -DWOLFSSL_AES_DIRECT"

