EXTRA_OECONF += "--enable-ssh --enable-keygen --enable-certext --enable-certgen --disable-examples"
CPPFLAGS_append += "-DWOLFSSL_FPKI -DWOLFSSL_IP_ALT_NAME -DWOLFSSL_ALT_NAMES -DNO_WOLFSSL_DIR -DWOLFSSL_PUBLIC_ASN"

