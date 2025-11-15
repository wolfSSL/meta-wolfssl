# OpenSSL wolfProvider REPLACE-DEFAULT mode configuration
# This file is included when wolfProvider is configured to replace OpenSSL's default crypto provider
# It should be included from the image recipe when replace-default mode is desired

# Build OpenSSL as plain, non-FIPS OpenSSL
# wolfProvider will provide FIPS functionality using wolfSSL FIPS
PACKAGECONFIG:class-target:pn-openssl = ""
EXTRA_OECONF:append:class-target = " no-fips"

# OpenSSL target-only tweaks for replace-default mode
do_configure:prepend:class-target () {
    set -eu

    # Be explicit about where we are
    echo "TARGET do_configure prepend: S='${S}', B='${B}'"

    vfile="${S}/VERSION.dat"

    # Sanity check: VERSION.dat must exist at the top of the OpenSSL tree
    if [ ! -f $vfile ]; then
        echo "ERROR: $vfile not found in ${S}" >&2
        exit 1
    fi

    echo "Injecting BUILD_METADATA into VERSION.dat (target only)"
    sed -i 's/^BUILD_METADATA=.*/BUILD_METADATA=wolfProvider/' $vfile

    # Optional FIPS tag based on image features
    if echo "${IMAGE_FEATURES}" | grep -qw "fips"; then
        sed -i 's/^BUILD_METADATA=.*/BUILD_METADATA=wolfProvider-fips/' $vfile
    fi
}

# Ensure provider is present on TARGET runtime (doesn't touch -native/-nativesdk)
RDEPENDS:libcrypto3:append:class-target = " wolfprovider"

# Bring in the replace-default patch (target only)
SRC_URI:append:class-target = " \
    git://github.com/wolfSSL/wolfProvider.git;protocol=https;nobranch=1;rev=v1.1.0;destsuffix=git/wolfProvider \
"

python do_patch:append:class-target () {
    import os, subprocess
    s = d.getVar("S")
    patch_path = os.path.join(d.getVar("WORKDIR"), "git/wolfProvider/patches/openssl3-replace-default.patch")
    bb.note("REPLACE-DEFAULT MODE: Checking if patch needs to be applied")
    # Try to apply patch; if it fails with "already applied", log it and continue
    try:
        # First check with --dry-run to see if patch can be applied
        result = subprocess.run(["patch", "-d", s, "-p1", "-i", patch_path, "--dry-run"], 
                              capture_output=True, text=True, check=False)
        if result.returncode == 0:
            bb.note("REPLACE-DEFAULT MODE: Patch can be applied, applying now...")
            subprocess.run(["patch", "-d", s, "-p1", "-i", patch_path], check=True)
        else:
            bb.note("REPLACE-DEFAULT MODE: Patch already applied or cannot apply, skipping")
            bb.debug(1, f"Patch check output: {result.stderr}")
    except Exception as e:
        bb.warn(f"REPLACE-DEFAULT MODE: Error applying patch: {e}")
}

