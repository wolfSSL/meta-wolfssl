# OpenSSL wolfProvider REPLACE-DEFAULT mode configuration
# This file is included when wolfProvider is configured to replace OpenSSL's default crypto provider
# It should be included from the image recipe when replace-default mode is desired

# Build OpenSSL as plain, non-FIPS OpenSSL
# wolfProvider will provide FIPS functionality using wolfSSL FIPS
EXTRA_OECONF:append:class-target = " no-fips shared "

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

# Override do_configure to filter enable-fips from the actual configure command
do_configure:append:class-target () {
    # The base do_configure uses ${PACKAGECONFIG_CONFARGS} which still has enable-fips
    # We need to regenerate it without enable-fips
    # Re-run configure with enable-fips explicitly removed
    if [ -f "${B}/configdata.pm" ] && grep -q "enable-fips" "${B}/configdata.pm" 2>/dev/null; then
        bbwarn "REPLACE-DEFAULT MODE: FIPS detected in config, forcing reconfigure without FIPS"
        cd "${B}"
        # Get the target from the original config
        target=$(grep "our \$config{target}" "${B}/configdata.pm" 2>/dev/null | sed "s/.*'\(.*\)'.*/\1/" || echo "linux-x86_64")
        # Reconfigure without enable-fips
        HASHBANGPERL="/usr/bin/env perl" PERL=perl PERL5LIB="${S}/external/perl/Text-Template-1.46/lib/" \
        perl "${S}/Configure" no-fips shared ${EXTRA_OECONF} ${DEPRECATED_CRYPTO_FLAGS} \
            --prefix=${prefix} --openssldir=${libdir}/ssl-3 --libdir=${libdir} "$target"
        perl "${B}/configdata.pm" --dump
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


