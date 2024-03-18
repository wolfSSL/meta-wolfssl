EXTRA_OECONF += "--enable-sni --enable-opensslextra --enable-opensslall --enable-dtls13 --enable-dtls --enable-crl --enable-tlsx --enable-secure-renegotiation"

TARGET_CFLAGS += "-DKEEP_PEER_CERT -DFP_MAX_BITS=8192 -DHAVE_EX_DATA -DOPENSSL_COMPATIBLE_DEFAULTS"
