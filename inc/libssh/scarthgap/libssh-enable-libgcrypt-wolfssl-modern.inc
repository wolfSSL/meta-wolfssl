# Disable chacha20-poly1305 in libssh when using libgcrypt-wolfssl backend
# wolfSSL-backed libgcrypt does not support chacha20 cipher in FIPS mode

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://enable-fips-mode.patch"
