# Configuration to enable wolfcrypt-py support in wolfssl
# Python bindings need specific crypto features enabled
EXTRA_OECONF += " --enable-aes --enable-aesctr --enable-des3 --enable-chacha --enable-aesgcm-stream --enable-aesgcm --enable-sha --enable-sha384 --enable-sha512 --enable-sha3 --enable-hkdf --enable-rsa --enable-rsapss --enable-ecc --enable-ed25519 --enable-ed448 --enable-curve25519 --enable-keygen --enable-pwdbased --enable-pkcs7 --enable-dtls --enable-tls13 --enable-tlsx"
