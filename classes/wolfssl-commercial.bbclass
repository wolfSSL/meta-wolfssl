# wolfssl-commercial.bbclass
#
# This class provides helper functions for commercial wolfSSL bundles
# including password-protected 7z extraction and autogen disabling
#
# Usage in recipe:
#   inherit wolfssl-commercial
#
# Required variables:
#   COMMERCIAL_BUNDLE_DIR - Directory containing the .7z file
#   COMMERCIAL_BUNDLE_NAME - Bundle filename without .7z extension
#   COMMERCIAL_BUNDLE_PASS - Password for the bundle
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

# Commercial bundles already ship generated configure scripts, so skip autoreconf
AUTOTOOLS_AUTORECONF = "no"

# Helper functions for conditional commercial bundle configuration
def get_commercial_src_uri(d):
    """Generate SRC_URI for commercial bundle if configured, dummy file otherwise"""
    bundle_dir = d.getVar('COMMERCIAL_BUNDLE_DIR')
    bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')
    bundle_sha = d.getVar('COMMERCIAL_BUNDLE_SHA')
    
    # Check if bundle_name is actually set (not empty, None, or unexpanded variable)
    if bundle_name and bundle_name.strip() and not bundle_name.startswith('${'):
        return f'file://{bundle_dir}/{bundle_name}.7z;unpack=false;sha256sum={bundle_sha}'
    
    # Return dummy placeholder file when not configured
    # Use the existing commercial/files/README.md
    return f'file://{bundle_dir}/README.md'

def get_commercial_source_dir(d):
    """Get source directory for commercial bundle if configured, WORKDIR otherwise"""
    bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')
    workdir = d.getVar('WORKDIR')
    
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
COMMERCIAL_BUNDLE_PASS ?= ""
COMMERCIAL_BUNDLE_SHA ?= ""
COMMERCIAL_BUNDLE_TARGET ?= "${WORKDIR}"

# Task to extract commercial bundle
python do_commercial_extract() {
    import os
    import bb
    
    bundle_dir = d.getVar('COMMERCIAL_BUNDLE_DIR')
    bundle_name = d.getVar('COMMERCIAL_BUNDLE_NAME')
    bundle_pass = d.getVar('COMMERCIAL_BUNDLE_PASS')
    target_dir = d.getVar('COMMERCIAL_BUNDLE_TARGET')
    
    if not bundle_dir:
        bb.fatal("COMMERCIAL_BUNDLE_DIR not set. Please set the directory containing the .7z bundle.")
    
    if not bundle_name:
        bb.fatal("COMMERCIAL_BUNDLE_NAME not set. Please set bundle filename (without .7z extension).")
    
    if not bundle_pass:
        bb.fatal("COMMERCIAL_BUNDLE_PASS not set. Please set bundle password.")
    
    bundle_path = os.path.join(bundle_dir, bundle_name + '.7z')
    
    if not os.path.exists(bundle_path):
        bb.fatal(f"Commercial bundle not found: {bundle_path}\n" +
                 "Please download the commercial bundle and place it in the appropriate directory.\n" +
                 "Contact support@wolfssl.com for access to commercial bundles.")
    
    # Copy bundle to target directory
    bb.plain(f"Extracting commercial bundle: {bundle_name}.7z")
    ret = os.system(f'cp -f "{bundle_path}" "{target_dir}"')
    if ret != 0:
        bb.fatal(f"Failed to copy bundle to {target_dir}")
    
    # Extract with password
    cmd = f'7za x "{target_dir}/{bundle_name}.7z" -p"{bundle_pass}" -o"{target_dir}" -aoa'
    ret = os.system(cmd)
    
    if ret != 0:
        bb.fatal(f"Failed to extract bundle. Check password and bundle integrity.")
    
    bb.plain("Commercial bundle extracted successfully")
}

# Add task after fetch, before patch
addtask commercial_extract after do_fetch before do_patch

# Conditionally add p7zip-native dependency only when commercial bundle variables are set
python __anonymous() {
    enabled = d.getVar('COMMERCIAL_BUNDLE_ENABLED')
    if enabled == "1":
        d.appendVar('DEPENDS', ' p7zip-native')
}

# Task to create stub autogen.sh for commercial bundles
do_commercial_stub_autogen() {
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

# Add task after commercial_extract, before configure
addtask commercial_stub_autogen after do_commercial_extract before do_configure