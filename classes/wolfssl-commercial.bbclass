# wolfssl-commercial.bbclass
#
# This class provides helper functions for commercial wolfSSL bundles
# including password-protected 7z extraction and autogen disabling
#
# Usage in recipe:
#   inherit wolfssl-commercial
#
# Required variables:
#   COMMERCIAL_BUNDLE_DIR - Directory containing the commercial archive
#   COMMERCIAL_BUNDLE_NAME - Logical bundle name (used as extracted directory)
#   COMMERCIAL_BUNDLE_PASS - Password for .7z bundles (optional for .tar.gz)
#   COMMERCIAL_BUNDLE_SHA - SHA256 checksum of the bundle
#   COMMERCIAL_BUNDLE_TARGET - Target directory for extraction (usually WORKDIR)
#
# Example:
#   COMMERCIAL_BUNDLE_DIR = "${@os.path.dirname(d.getVar('FILE'))}/commercial/files"
#   COMMERCIAL_BUNDLE_NAME = "${WOLFSSL_SRC}"
#   COMMERCIAL_BUNDLE_PASS = "${WOLFSSL_SRC_PASS}"
#   COMMERCIAL_BUNDLE_SHA = "${WOLFSSL_SRC_SHA}"
#   COMMERCIAL_BUNDLE_TARGET = "${WORKDIR}"
#
# Helper functions:
#   get_commercial_src_uri(d) - Generates conditional SRC_URI
#   get_commercial_source_dir(d) - Generates conditional source directory
#   get_commercial_bbclassextend(d) - Returns BBCLASSEXTEND only if bundle configured
#   get_commercial_bundle_archive(d) - Resolves bundle filename (supports .7z and .tar.gz)
#
# Optional format variables:
#   COMMERCIAL_BUNDLE_FILE - Bundle filename including extension (defaults to <NAME>.7z)
#   COMMERCIAL_BUNDLE_GCS_URI - gs:// path to the protected bundle
#   COMMERCIAL_BUNDLE_SRC_DIR - Direct path to already-extracted source directory (skips fetch/extract)

# Commercial bundles already ship generated configure scripts, so skip autoreconf
AUTOTOOLS_AUTORECONF = "no"

# Helper functions for conditional commercial bundle configuration
def append_libtool_sysroot(d):
    """Override the default autotools helper to drop --with-libtool-sysroot for commercial bundles."""
    if d.getVar('COMMERCIAL_BUNDLE_ENABLED') == "1":
        return ''
    import bb
    if not bb.data.inherits_class('native', d):
        return '--with-libtool-sysroot=${STAGING_DIR_HOST}'
    return ''

def get_commercial_bundle_archive(d):
    """Resolve the bundle filename with extension."""
    bundle_file = d.getVar('COMMERCIAL_BUNDLE_FILE')
    if bundle_file and bundle_file.strip() and not bundle_file.startswith('${'):
        return bundle_file
    bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')
    if bundle_name and bundle_name.strip() and not bundle_name.startswith('${'):
        return f'{bundle_name}.7z'
    return ''

def get_commercial_src_uri(d):
    """Generate SRC_URI for commercial bundle if configured, dummy file otherwise"""
    # Check for direct source directory first (skip fetch/extract)
    src_dir = d.getVar('COMMERCIAL_BUNDLE_SRC_DIR')
    if src_dir and src_dir.strip() and not src_dir.startswith('${'):
        # Direct source directory - no fetch needed
        return ""

    bundle_archive = d.getVar('COMMERCIAL_BUNDLE_ARCHIVE')
    bundle_sha = d.getVar('COMMERCIAL_BUNDLE_SHA')
    gcs_uri = d.getVar('COMMERCIAL_BUNDLE_GCS_URI')
    placeholder = d.getVar('COMMERCIAL_BUNDLE_PLACEHOLDER') or ''

    if gcs_uri and bundle_archive:
        unpack_flag = ';unpack=false' if bundle_archive.endswith('.7z') else ''
        sha_flag = f';sha256sum={bundle_sha}' if bundle_sha else ''
        filename_flag = f';downloadfilename={bundle_archive}'
        return f'{gcs_uri}{filename_flag}{unpack_flag}{sha_flag}'

    bundle_dir = d.getVar('COMMERCIAL_BUNDLE_DIR')

    if bundle_archive and not gcs_uri:
        unpack_flag = ';unpack=false' if bundle_archive.endswith('.7z') else ''
        return f'file://{bundle_dir}/{bundle_archive}{unpack_flag};sha256sum={bundle_sha}'

    # Return dummy placeholder file when not configured
    if placeholder:
        return f'file://{placeholder}'
    return ""

def get_commercial_source_dir(d):
    """Get source directory for commercial bundle if configured, WORKDIR otherwise"""
    workdir = d.getVar('WORKDIR')
    bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')

    # Check for direct source directory - return the copy location in WORKDIR
    src_dir = d.getVar('COMMERCIAL_BUNDLE_SRC_DIR')
    if src_dir and src_dir.strip() and not src_dir.startswith('${'):
        # do_commercial_extract will copy to WORKDIR/bundle_name
        if bundle_name and bundle_name.strip() and not bundle_name.startswith('${'):
            return f'{workdir}/{bundle_name}'
        # Fallback to workdir if bundle_name not set
        return workdir

    # Check if bundle_name is actually set (not empty, None, or unexpanded variable)
    if bundle_name and bundle_name.strip() and not bundle_name.startswith('${'):
        return f'{workdir}/{bundle_name}'
    return workdir

def get_commercial_bbclassextend(d):
    """Return BBCLASSEXTEND variants only when commercial bundle is configured"""
    bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')

    # Check if bundle_name is actually set (not empty, None, or unexpanded variable)
    if bundle_name and bundle_name.strip() and not bundle_name.startswith('${'):
        return 'native nativesdk'
    return ''

# Generic variables for commercial bundle extraction
COMMERCIAL_BUNDLE_ENABLED ?= "0"
COMMERCIAL_BUNDLE_DIR ?= ""
COMMERCIAL_BUNDLE_NAME ?= ""
COMMERCIAL_BUNDLE_FILE ?= ""
COMMERCIAL_BUNDLE_PASS ?= ""
COMMERCIAL_BUNDLE_SHA ?= ""
COMMERCIAL_BUNDLE_TARGET ?= "${WORKDIR}"
COMMERCIAL_BUNDLE_PLACEHOLDER ?= "${WOLFSSL_LAYERDIR}/recipes-wolfssl/wolfssl/commercial/files/README.md"
COMMERCIAL_BUNDLE_GCS_URI ?= ""
COMMERCIAL_BUNDLE_SRC_DIR ?= ""
COMMERCIAL_BUNDLE_ARCHIVE = "${@get_commercial_bundle_archive(d)}"

# Auto-detect extracted directory name from WOLFSSL_VERSION if not explicitly set
# This handles cases where tarball name differs from extracted directory
WOLFSSL_SRC_SUBDIR ?= "${@'wolfssl-' + d.getVar('WOLFSSL_VERSION') if d.getVar('WOLFSSL_VERSION') else d.getVar('WOLFSSL_SRC') or ''}"

# Task to extract commercial bundle
python do_commercial_extract() {
    import os
    import bb
    import bb.process
    import bb.build

    enabled = d.getVar('COMMERCIAL_BUNDLE_ENABLED')
    src_dir = d.getVar('COMMERCIAL_BUNDLE_SRC_DIR')
    bundle_dir = d.getVar('COMMERCIAL_BUNDLE_DIR')
    bundle_archive = d.getVar('COMMERCIAL_BUNDLE_ARCHIVE')
    bundle_pass = d.getVar('COMMERCIAL_BUNDLE_PASS')
    target_dir = d.getVar('COMMERCIAL_BUNDLE_TARGET')
    bundle_sha = d.getVar('COMMERCIAL_BUNDLE_SHA') or ''

    if enabled != "1":
        bb.note("COMMERCIAL_BUNDLE_ENABLED=0; skipping commercial extraction (standard fetch/unpack will run).")
        return

    # If direct source directory is provided, skip extraction
    if src_dir and src_dir.strip() and not src_dir.startswith('${'):
        bb.note(f"COMMERCIAL_BUNDLE_SRC_DIR={src_dir}; copying source directory to WORKDIR.")

        # Copy source directory to WORKDIR to avoid polluting the original
        import shutil
        bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')
        dest_dir = os.path.join(target_dir, bundle_name)

        if os.path.exists(dest_dir):
            bb.note(f"Removing existing build directory: {dest_dir}")
            shutil.rmtree(dest_dir)

        bb.note(f"Copying {src_dir} to {dest_dir}")
        shutil.copytree(src_dir, dest_dir, symlinks=True)
        bb.note("Source directory copied successfully")
        return

    if not bundle_dir:
        bb.fatal("COMMERCIAL_BUNDLE_DIR not set. Please set the directory containing the commercial bundle.")

    if not bundle_archive:
        bb.fatal("COMMERCIAL_BUNDLE_NAME/FILE not set. Please provide the bundle filename.")

    is_seven_zip = bundle_archive.endswith('.7z')
    is_tarball = bundle_archive.endswith('.tar.gz') or bundle_archive.endswith('.tgz')

    if is_seven_zip and not bundle_pass:
        bb.fatal("COMMERCIAL_BUNDLE_PASS not set. Please set bundle password for .7z archives.")

    if not is_seven_zip:
        bb.note("Non-7z commercial bundle detected; letting BitBake unpack the archive.")
        return

    bundle_path = os.path.join(bundle_dir, bundle_archive)

    if not os.path.exists(bundle_path):
        bb.fatal(f"Commercial bundle not found: {bundle_path}\n" +
                 "Please download the commercial bundle and place it in the appropriate directory.\n" +
                 "Contact support@wolfssl.com for access to commercial bundles.")

    # Verify checksum locally (BitBake's file:// fetcher may skip it)
    if bundle_sha:
        import hashlib
        h = hashlib.sha256()
        with open(bundle_path, 'rb') as f:
            for chunk in iter(lambda: f.read(1024 * 1024), b''):
                h.update(chunk)
        digest = h.hexdigest()
        if digest != bundle_sha:
            bb.fatal(f"SHA256 mismatch for {bundle_archive}:\n"
                     f"  expected: {bundle_sha}\n"
                     f"  actual:   {digest}\n"
                     "Update WOLFSSL_SRC_SHA/COMMERCIAL_BUNDLE_SHA to the correct value.")

    # Copy bundle to target directory
    bb.plain(f"Extracting commercial bundle: {bundle_archive}")
    ret = os.system(f'cp -f "{bundle_path}" "{target_dir}"')
    if ret != 0:
        bb.fatal(f"Failed to copy bundle to {target_dir}")

    archive_in_target = os.path.join(target_dir, bundle_archive)

    if is_seven_zip:
        # Locate 7zip binary from native sysroot or host
        path = d.getVar('PATH')
        seven_zip = bb.utils.which(path, '7za') or bb.utils.which(path, '7z')

        if not seven_zip:
            bb.fatal("Failed to find either '7za' or '7z' in PATH.\n"
                     "Ensure p7zip-native is available or install p7zip on the build host.")

        cmd = [seven_zip, 'x', archive_in_target, f"-p{bundle_pass}",
               f"-o{target_dir}", '-aoa']
    else:
        bb.fatal(f"Unsupported commercial bundle format: {bundle_archive}. Expected .7z.")

    try:
        bb.process.run(cmd)
    except bb.process.ExecutionError as exc:
        bb.fatal("Failed to extract bundle. Check credentials and bundle integrity.\n" + str(exc))

    bb.plain("Commercial bundle extracted successfully")
}

# Add task after fetch, before patch (place before do_patch so it still runs even if do_unpack is skipped)
addtask commercial_extract after do_fetch before do_patch

# Conditionally add p7zip-native dependency only when commercial bundle variables are set
python __anonymous() {
    enabled = d.getVar('COMMERCIAL_BUNDLE_ENABLED')
    src_dir = d.getVar('COMMERCIAL_BUNDLE_SRC_DIR')
    archive = d.getVar('COMMERCIAL_BUNDLE_ARCHIVE')

    # Skip p7zip and unpack tasks if using direct source directory
    # But keep commercial_extract to copy the source
    if enabled == "1" and src_dir and src_dir.strip() and not src_dir.startswith('${'):
        bb.build.deltask('do_fetch', d)
        bb.build.deltask('do_unpack', d)
        # do_commercial_extract will copy the source directory
        return

    if enabled == "1" and archive and archive.endswith('.7z'):
        d.appendVar('DEPENDS', ' p7zip-native')
        d.appendVarFlag('do_commercial_extract', 'depends', ' p7zip-native:do_populate_sysroot')
        # Older BitBake releases sometimes ignore 'unpack=false' on file:// URLs,
        # causing do_unpack to run with no password and wipe the extracted tree.
        # When we manage a passworded .7z ourselves, skip do_unpack entirely.
        bb.build.deltask('do_unpack', d)

    # Commercial bundles ship preconfigured scripts; drop libtool sysroot flag
    opts = d.getVar('CONFIGUREOPTS') or ''
    import shlex
    tokens = shlex.split(opts)
    tokens = [t for t in tokens if not t.startswith('--with-libtool-sysroot=')]
    d.setVar('CONFIGUREOPTS', ' '.join(tokens))
    d.setVar('CONFIGUREOPT_SYSROOT', '')
}

# Skip autoreconf for commercial bundles and rely on bundled configure script
do_configure() {
    bbnote "Commercial bundle detected, skipping autoreconf and running bundled configure"
    # Ensure libtool sysroot option is stripped (not accepted by commercial bundles)
    unset CONFIGUREOPT_SYSROOT
    CONFIGUREOPTS="$(echo ${CONFIGUREOPTS} | sed 's/--with-libtool-sysroot=[^ ]*//g')"
    if [ -e "${S}/configure.ac" ] && [ ! -f "${S}/stamp-h.in" ] && \
       grep -q "AC_CONFIG_FILES(\\[stamp-h\\]" "${S}/configure.ac"; then
        bbnote "stamp-h.in missing; generating stub for preconfigured commercial source"
        echo "timestamp" > "${S}/stamp-h.in"
    fi
    if [ -e "${CONFIGURE_SCRIPT}" ]; then
        oe_runconf
    else
        bbfatal "configure script not found at ${CONFIGURE_SCRIPT}"
    fi
}

# Task to create stub autogen.sh for commercial bundles
do_commercial_stub_autogen() {
    if [ "${COMMERCIAL_BUNDLE_ENABLED}" != "1" ]; then
        bbnote "Commercial bundle disabled; skipping autogen stub."
        exit 0
    fi

    if [ ! -d "${S}" ]; then
        bbwarn "Source directory ${S} missing before autogen stub; skipping."
        exit 0
    fi

    # Commercial bundles are pre-configured and don't need autogen.sh
    # Create a no-op autogen.sh to prevent automatic execution
    if [ ! -f ${S}/autogen.sh ]; then
        echo '#!/bin/sh' > ${S}/autogen.sh
        echo '# Commercial bundle - pre-configured, no autogen needed' >> ${S}/autogen.sh
        echo 'exit 0' >> ${S}/autogen.sh
        chmod +x ${S}/autogen.sh
        bbplain "Created stub autogen.sh for commercial bundle"
    else
        bbplain "Replacing existing autogen.sh with stub for commercial bundle"
        echo '#!/bin/sh' > ${S}/autogen.sh
        echo '# Commercial bundle - pre-configured, no autogen needed' >> ${S}/autogen.sh
        echo 'exit 0' >> ${S}/autogen.sh
        chmod +x ${S}/autogen.sh
    fi
}

# Add task after unpack (or commercial_extract for 7z), before configure
addtask commercial_stub_autogen after do_unpack before do_configure
