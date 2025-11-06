# To enable debug add `--enable-debug --enable-keylog-export` to the EXTRA_OECONF
EXTRA_OECONF += " --enable-all-crypto --enable-opensslcoexist --with-eccminsz=192 --with-max-ecc-bits=1024 --enable-sha"
CPPFLAGS += " -DWC_RSA_NO_PADDING -DWOLFSSL_PUBLIC_MP -DHAVE_PUBLIC_FFDHE -DHAVE_FFDHE_6144 -DHAVE_FFDHE_8192 -DWOLFSSL_PSS_LONG_SALT -DWOLFSSL_PSS_SALT_LEN_DISCOVER -DRSA_MIN_SIZE=1024 -DWOLFSSL_OLD_OID_SUM"
CPPFLAGS += " ${@'-DWOLFSSL_OLD_OID_SUM -DWOLFSSL_DH_EXTRA' if d.getVar('WOLFSSL_TYPE') not in ("fips", "fips-ready") else ''}"
