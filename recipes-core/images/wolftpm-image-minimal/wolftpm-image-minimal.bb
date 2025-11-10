SUMMARY = "Minimal image with wolfSSL, test utilities, and wolfTPM"
DESCRIPTION = "A minimal Linux image that includes wolfSSL library, test/benchmark utilities, and wolfTPM with TPM 2.0 support"

# Validate TPM configuration
python __anonymous() {
    """
    Check that required TPM features are enabled in local.conf
    """
    distro_features = d.getVar('DISTRO_FEATURES') or ''
    machine_features = d.getVar('MACHINE_FEATURES') or ''
    kernel_features = d.getVar('KERNEL_FEATURES') or ''
    
    errors = []
    
    # Check DISTRO_FEATURES
    if 'security' not in distro_features or 'tpm' not in distro_features or 'tpm2' not in distro_features:
        errors.append("DISTRO_FEATURES must contain 'security tpm tpm2'")
        errors.append("  Add to local.conf: DISTRO_FEATURES:append = \" security tpm tpm2\"")
    
    # Check MACHINE_FEATURES
    if 'tpm' not in machine_features or 'tpm2' not in machine_features:
        errors.append("MACHINE_FEATURES must contain 'tpm tpm2'")
        errors.append("  Add to local.conf: MACHINE_FEATURES:append = \" tpm tpm2\"")
    
    # Check KERNEL_FEATURES
    if 'features/tpm/tpm.scc' not in kernel_features:
        errors.append("KERNEL_FEATURES must contain 'features/tpm/tpm.scc'")
        errors.append("  Add to local.conf: KERNEL_FEATURES:append = \" features/tpm/tpm.scc\"")
    
    # Report errors
    if errors:
        error_msg = "\n%s requires TPM support to be properly configured in local.conf:\n\n" % d.getVar('PN')
        error_msg += "\n".join(["  - " + e for e in errors])
        error_msg += "\n\nThese settings MUST be in local.conf, not in the image recipe.\n"
        bb.fatal(error_msg)
}

# Add wolfTPM wrap test configured with wolfSSL support
# wolfTPM will be pulled in automatically via RDEPENDS
# The wolfssl_%.bbappend in this directory configures wolfSSL with --enable-certgen, etc.
IMAGE_INSTALL:append = " \
    wolftpm-wrap-test \
    tpm2-tools \
    tpm2-tss \
    libtss2 \
    libtss2-mu \
    libtss2-tcti-device \
    libtss2-tcti-mssim \
"

# Enable security and TPM features

require ${WOLFSSL_LAYERDIR}/recipes-core/images/wolfssl-minimal-image/wolfssl-image-minimal.bb

