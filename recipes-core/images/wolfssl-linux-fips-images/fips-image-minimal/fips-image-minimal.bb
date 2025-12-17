SUMMARY = "Minimal FIPS image with libgcrypt, gnutls, and wolfProvider (replace-default mode)"
DESCRIPTION = "A minimal Linux image that includes libgcrypt, gnutls, and wolfProvider all configured to use wolfSSL FIPS as the crypto backend. wolfProvider is configured in replace-default mode. This image requires wolfSSL FIPS and does not require wolfssl-image-minimal."

# Validate that wolfssl-fips is the provider
# Just to be sure that the user has set the correct provider
python __anonymous() {
    virtual_provider = d.getVar('PREFERRED_PROVIDER_virtual/wolfssl') or ''
    wolfssl_provider = d.getVar('PREFERRED_PROVIDER_wolfssl') or ''

    if virtual_provider != 'wolfssl-fips':
        bb.fatal("fips-image-minimal requires PREFERRED_PROVIDER_virtual/wolfssl = 'wolfssl-fips'. Current value: '%s'. Please set 'require conf/wolfssl-fips.conf' in local.conf" % virtual_provider)

    if wolfssl_provider != 'wolfssl-fips':
        bb.fatal("fips-image-minimal requires PREFERRED_PROVIDER_wolfssl = 'wolfssl-fips'. Current value: '%s'. Please set 'require conf/wolfssl-fips.conf' in local.conf" % wolfssl_provider)
}

# Add packages with wolfSSL FIPS backend support
# Includes all testing applications from libgcrypt, gnutls, and wolfProvider demo images
IMAGE_INSTALL:append = " \
    wolfssl \
    libgcrypt \
    libgcrypt-ptest \
    gnutls \
    gnutls-dev \
    gnutls-bin \
    gnutls-fips \
    wolfssl-gnutls-wrapper \
    wolfssl-gnutls-wrapper-dev \
    wolfprovider \
    openssl \
    openssl-bin \
    wolfprovidercmd \
    wolfproviderenv \
    pkgconfig \
    ptest-runner \
    bash \
    make \
    glibc-utils \
    binutils \
    ldd \
    curl \
    librelp-ptest \
"

require recipes-core/images/core-image-minimal.bb

# This image requires wolfssl-fips
# Set in local.conf:
#   WOLFSSL_DEMOS = "fips-image-minimal"
#   require conf/wolfssl-fips.conf
