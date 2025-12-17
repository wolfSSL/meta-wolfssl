# OpenSSH wolfProvider FIPS mode configuration
# Include this file for standard wolfProvider integration as a provider plugin

# Bring in the openssh patch from the OSP repository (target only)
SRC_URI_append_class-target = " \
    git://github.com/wolfSSL/osp.git;protocol=https;branch=master;name=osp;destsuffix=git/osp \
"

# Track the revision for the OSP auxiliary repo fetch
SRCREV_osp = "${AUTOREV}"

# Ensure BitBake can locate the updated run-ptest script in this include's files directory
FILESEXTRAPATHS_prepend := "${WOLFSSL_LAYERDIR}/inc/wolfprovider/openssh/files:"
SRC_URI_append_class-target = " file://run-ptest"

# Apply the patch for the correct version of OpenSSH
python do_patch_append_class-target () {
    import os, subprocess
    # Only run this when FIPS is enabled
    if not bb.utils.contains('IMAGE_FEATURES', 'fips', True, False, d):
        bb.note("FIPS not enabled; skipping openssh-V_9_6_P1-FIPS-wolfprov.patch")
        return
    patch_path = os.path.join(d.getVar("WORKDIR"), "git/osp/wolfProvider/openssh/openssh-V_9_6_P1-FIPS-wolfprov.patch")
    s = d.getVar("S")

    # Try to apply the patch; if it fails with "already applied", log it and continue
    try:
        result = subprocess.run(["patch", "-d", s, "-p1", "-i", patch_path, "--dry-run"],
                              capture_output=True, text=True, check=False)
        if result.returncode == 0:
            bb.note(f"{patch_path} can be applied, applying now...")
            subprocess.run(["patch", "-d", s, "-p1", "-i", patch_path], check=True)
        else:
            bb.note(f"{patch_path} already applied or cannot apply, skipping")
            bb.debug(1, f"Patch check output: {result.stderr}")
    except Exception as e:
        bb.warn(f"{patch_path}: Error applying patch: {e}")
}
