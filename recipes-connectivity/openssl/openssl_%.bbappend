
# Apply wolfProvider metadata to the OpenSSL version
do_configure:prepend() {
    echo "Injecting BUILD_METADATA into VERSION.dat"
    sed -i 's/BUILD_METADATA=.*/BUILD_METADATA=wolfProvider/g' ${S}/VERSION.dat
    if echo "${IMAGE_FEATURES}" | grep -qw "fips"; then
        sed -i 's/BUILD_METADATA=.*/BUILD_METADATA=wolfProvider-fips/g' ${S}/VERSION.dat
    fi
}

# Apply the replace-default patch
SRC_URI:append = " \
    https://raw.githubusercontent.com/wolfSSL/wolfProvider/refs/tags/v1.1.0/patches/openssl3-replace-default.patch \
"
