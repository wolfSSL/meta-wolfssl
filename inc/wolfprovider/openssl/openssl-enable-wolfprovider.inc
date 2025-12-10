# OpenSSL standalone wolfProvider mode configuration
# Include this file for standard wolfProvider integration as a provider plugin

EXTRA_OECONF += " no-fips shared "

do_install:append() {
    install -d ${D}${sysconfdir}/openssl
    echo "0" > ${D}${sysconfdir}/openssl/replace-default-enabled
}

# Ensure BitBake can locate the patch in this include's files directory
FILESEXTRAPATHS:prepend := "${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssl/files:"
SRC_URI:append:class-target = " file://openssl-disable-internal-keymgmt-tests.patch"

# Disable internal keymgmt tests under wolfprovider FIPS mode which
# fails on the FACTOR3 and EXPONENT3 and COEFFICIENT2 parameters which
# are not supported by wolfProvider.
python do_patch:append:class-target () {
    import os, subprocess
    # Only run this when FIPS is enabled
    if not bb.utils.contains('IMAGE_FEATURES', 'fips', True, False, d):
        bb.note("FIPS not enabled; skipping openssl-disable-internal-keymgmt-tests.patch")
        return

    s = d.getVar("S")
    patch_path = os.path.join(d.getVar("WOLFSSL_LAYERDIR"), "inc/wolfprovider/openssl/files/openssl-disable-internal-keymgmt-tests.patch")
    # Try to apply the patch; if it fails with "already applied", log it and continue
    try:
        result = subprocess.run(["patch", "-d", s, "-p1", "-i", patch_path, "--dry-run"], 
                              capture_output=True, text=True, check=False)
        if result.returncode == 0:
            bb.note("openssl-disable-internal-keymgmt-tests.patch can be applied, applying now...")
            subprocess.run(["patch", "-d", s, "-p1", "-i", patch_path], check=True)
        else:
            bb.note("openssl-disable-internal-keymgmt-tests.patch already applied or cannot apply, skipping")
            bb.debug(1, f"Patch check output: {result.stderr}")
    except Exception as e:
        bb.warn(f"openssl-disable-internal-keymgmt-tests.patch: Error applying patch: {e}")
}

