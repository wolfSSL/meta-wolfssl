# OpenSSL wolfProvider REPLACE-DEFAULT mode configuration
# This file is included when wolfProvider is configured to replace OpenSSL's default crypto provider
# It should be included from the image recipe when replace-default mode is desired

# Build OpenSSL as plain, non-FIPS OpenSSL
# wolfProvider will provide FIPS functionality using wolfSSL FIPS

PACKAGECONFIG:class-target = ""
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
        # Derive the correct OpenSSL Configure target from TARGET_ARCH (mirrors the recipe's mapping)
        case "${TARGET_ARCH}" in
            aarch64|arm64)      target="linux-aarch64" ;;
            arm*)               target="linux-armv4" ;;
            riscv64)            target="linux-generic64" ;;
            riscv32)            target="linux-generic32" ;;
            powerpc64le)        target="linux-ppc64le" ;;
            powerpc64)          target="linux-ppc64" ;;
            powerpc)            target="linux-ppc" ;;
            x86_64)             target="linux-x86_64" ;;
            i?86)               target="linux-x86" ;;
            *)                  bbwarn "REPLACE-DEFAULT MODE: unknown TARGET_ARCH=${TARGET_ARCH}, using linux-generic64"
                                target="linux-generic64" ;;
        esac
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

    # Export ossl_provider_* symbols by patching libcrypto.num
    # This is required for replace-default unit tests to link
    libcrypto_num = os.path.join(s, "util", "libcrypto.num")
    if os.path.exists(libcrypto_num):
        bb.note("REPLACE-DEFAULT MODE: Exporting ossl_provider_* symbols in libcrypto.num")
        try:
            # Read the file to find the last symbol number and version
            with open(libcrypto_num, 'r') as f:
                lines = f.readlines()

            # Find the last symbol number and version
            last_num = 0
            last_version = "3.0.0"
            for line in lines:
                parts = line.split()
                if len(parts) >= 2:
                    try:
                        num = int(parts[1])
                        if num > last_num:
                            last_num = num
                            if len(parts) >= 3:
                                last_version = parts[2]
                    except ValueError:
                        pass

            # Check if symbols are already added
            with open(libcrypto_num, 'r') as f:
                content = f.read()
                if 'ossl_provider_new' in content:
                    bb.note("REPLACE-DEFAULT MODE: ossl_provider_* symbols already in libcrypto.num")
                    return

            # Append the 6 provider symbols
            symbols_to_add = [
                ("ossl_provider_new", last_num + 1),
                ("ossl_provider_activate", last_num + 2),
                ("ossl_provider_deactivate", last_num + 3),
                ("ossl_provider_add_to_store", last_num + 4),
                ("ossl_provider_free", last_num + 5),
                ("ossl_default_provider_init", last_num + 6),
            ]

            with open(libcrypto_num, 'a') as f:
                for symbol_name, symbol_num in symbols_to_add:
                    # Format: symbol_name    NUM    VERSION    EXIST::FUNCTION:
                    f.write(f"{symbol_name:<40} {symbol_num}\t{last_version}\tEXIST::FUNCTION:\n")

            bb.note(f"REPLACE-DEFAULT MODE: Added {len(symbols_to_add)} provider symbols to libcrypto.num")
        except Exception as e:
            bb.warn(f"REPLACE-DEFAULT MODE: Error patching libcrypto.num: {e}")
    else:
        bb.warn(f"REPLACE-DEFAULT MODE: libcrypto.num not found at {libcrypto_num}")
}

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
    # Construct full path directly from layer directory (no need for FILESEXTRAPATHS)
    patch_path = os.path.join(d.getVar("WOLFSSL_LAYERDIR"), "inc/wolfprovider/openssl/files/openssl-disable-internal-keymgmt-tests.patch")
    # Check if patch file exists
    if not os.path.exists(patch_path):
        bb.warn(f"openssl-disable-internal-keymgmt-tests.patch not found at {patch_path}")
        return

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

do_install:append() {
    install -d ${D}${sysconfdir}/openssl
    echo "1" > ${D}${sysconfdir}/openssl/replace-default-enabled
}
