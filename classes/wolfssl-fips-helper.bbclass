# wolfSSL FIPS Helper Class
#
# This class provides automatic FIPS hash generation for wolfSSL FIPS builds.
# It performs a two-pass build:
#   1. Build with placeholder hash, run test binary to extract real hash
#   2. Reconfigure and rebuild with the extracted hash
#
# Usage in recipe:
#   inherit wolfssl-fips-helper
#   WOLFSSL_FIPS_HASH_MODE ?= "auto"  # or "manual" to use FIPS_HASH variable

# FIPS hash configuration
WOLFSSL_FIPS_HASH_MODE ?= "auto"
WOLFSSL_FIPS_HASH_MODE:class-native = "manual"
WOLFSSL_FIPS_HASH_MODE:class-nativesdk = "manual"
WOLFSSL_FIPS_PLACEHOLDER ?= "0000000000000000000000000000000000000000000000000000000000000000"

# This will be set by anonymous Python based on mode (manual: FIPS_HASH, auto: function call)
WOLFSSL_GET_HASH_METHOD ?= ""

# Test binary configuration
WOLFSSL_FIPS_TEST_BINARY ?= "${B}/wolfcrypt/test/.libs/testwolfcrypt"

# Helper function: Get FIPS hash value (callable from shell during build)
# This function performs the actual hash retrieval and returns the value
get_wolfssl_fips_hash() {
    local mode="${WOLFSSL_FIPS_HASH_MODE}"
    
    if [ "${mode}" != "auto" ]; then
        # Manual mode: return the configured hash
        echo "${FIPS_HASH}"
        return 0
    fi
    
    # Auto mode: perform hash extraction
    bbnote "wolfSSL FIPS auto mode: extracting hash from test binary"
    
    # Build test binary if not already built (configure should have enabled --enable-crypttests)
    if [ ! -x "${WOLFSSL_FIPS_TEST_BINARY}" ]; then
        bbnote "Building wolfCrypt test binary for FIPS hash generation"
        # Ensure we're in the build directory (where Makefiles are)
        cd ${B} || bbfatal "Failed to change to build directory ${B}"
        # Build everything needed for the test (redirect output to log files, not stdout)
        oe_runmake all 1>&2
    fi
    
    # Capture and return the hash directly (only hash goes to stdout)
    local hash=$(wolfssl_fips_capture_hash)
    local rc=$?
    if [ ${rc} -ne 0 ] || [ -z "${hash}" ]; then
        bberror "Failed to capture FIPS hash (rc=${rc})"
        return 1
    fi
    
    # Return only the hash to stdout (no other messages)
    echo "${hash}"
    return 0
}

# QEMU wrapper command for running target binaries
# This uses the qemu_target_binary function from qemu.bbclass
WOLFSSL_QEMU_BINARY = "${RECIPE_SYSROOT_NATIVE}/usr/bin/${@qemu_target_binary(d)}"
WOLFSSL_QEMU_WRAPPER = "PSEUDO_UNLOAD=1 ${WOLFSSL_QEMU_BINARY} ${QEMU_OPTIONS} -L ${RECIPE_SYSROOT} -E LD_LIBRARY_PATH=${B}/src/.libs:${B}/wolfcrypt/src/.libs"

# Clean function to prepend to do_configure
wolfssl_fips_clean_config() {
    # Clean any leftover config files from source directory to prevent "already configured" errors
    bbnote "wolfSSL FIPS: Cleaning config files from source directory"
    rm -f ${S}/config.status ${S}/config.log ${S}/Makefile ${S}/config.h ${S}/libtool
    rm -f ${S}/wolfssl/options.h ${S}/wolfssl/version.h
    # Also clean from subdirectories if they exist
    rm -f ${S}/wolfcrypt/src/fips_test.c.orig
}

# Dynamic variable setup - handles dependencies, class inheritance, and task ordering
python __anonymous () {
    import bb
    
    mode = d.getVar('WOLFSSL_FIPS_HASH_MODE')
    distro_version = d.getVar('DISTRO_VERSION')
    
    # Add clean function to do_configure (version-compatible based on DISTRO_VERSION)
    clean_command = 'wolfssl_fips_clean_config\n'
    
    if distro_version and (distro_version.startswith('2.') or distro_version.startswith('3.')):
        # For Dunfell (3.x) and earlier - use old style variable
        existing = d.getVar('do_configure_prepend') or ''
        d.setVar('do_configure_prepend', clean_command + existing)
    else:
        # For Kirkstone (4.x) and later - use prefuncs
        d.appendVarFlag('do_configure', 'prefuncs', ' wolfssl_fips_clean_config')
    
    # Only set up for auto mode
    if mode == 'auto':
        # Inherit qemu class for cross-compilation support
        bb.parse.BBHandler.inherit('qemu', '', 0, d)
        
        # Add qemu-native dependency
        d.appendVar('DEPENDS', ' qemu-native')
        
        # Include crypttests configuration for auto mode
        include_file = d.expand('${WOLFSSL_LAYERDIR}/inc/wolfcrypttest/wolfssl-enable-wolfcrypttest.inc')
        bb.parse.handle(include_file, d, True)
        
        bb.build.addtask('do_wolfssl_fips_capture_hash', 'do_compile', 'do_configure', d)
    else:
        # Manual mode task
        bb.build.addtask('do_wolfssl_fips_capture_hash_manual', 'do_compile', 'do_configure', d)
}

# Helper function: Capture FIPS hash from test binary
# Runs the test binary using QEMU for cross-builds or directly for native builds
# Returns 0 on success, 1 on failure
wolfssl_fips_capture_hash() {
    if [ ! -x "${WOLFSSL_FIPS_TEST_BINARY}" ]; then
        bberror "wolfCrypt test binary ${WOLFSSL_FIPS_TEST_BINARY} not found; cannot capture FIPS hash"
        return 1
    fi

    # Use temporary file for output
    local temp_log=$(mktemp)
    
    # Determine if we need QEMU (cross-compile) or can run natively
    local run_cmd=""
    if [ "${BUILD_ARCH}" = "${TARGET_ARCH}" ]; then
        # Native build - use dynamic linker explicitly to avoid "not found" errors
        bbnote "Native build detected - using host dynamic linker"
        run_cmd="/lib64/ld-linux-x86-64.so.2 --library-path ${B}/src/.libs:${B}/wolfcrypt/src/.libs ${WOLFSSL_FIPS_TEST_BINARY}"
    else
        # Cross-compile - use QEMU
        bbnote "Cross-compile detected - using QEMU wrapper"
        run_cmd="${WOLFSSL_QEMU_WRAPPER} ${WOLFSSL_FIPS_TEST_BINARY}"
    fi
    
    bbnote "Capturing wolfSSL FIPS hash from test binary"
    bbnote "Command: ${run_cmd}"
    
    set +e
    ${run_cmd} > ${temp_log} 2>&1
    local rc=$?
    set -e

    # Check if we got output
    if [ ! -s "${temp_log}" ]; then
        bberror "wolfCrypt test produced no output (rc=${rc})"
        bberror "Command was: ${run_cmd}"
        cat ${temp_log} 2>/dev/null || true
        rm -f ${temp_log}
        return 1
    fi

    # Parse the hash from output
    local parsed=$(grep -E "hash = " "${temp_log}" | tail -n1 | awk -F'=' '{print $2}' | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    
    # Debug: show output if parsing failed
    if [ -z "${parsed}" ]; then
        bberror "Failed to parse FIPS hash from test output"
        bberror "Test output (first 30 lines):"
        head -30 ${temp_log} || true
        rm -f ${temp_log}
        return 1
    fi
    
    rm -f ${temp_log}
    bbnote "wolfSSL FIPS hash extracted: ${parsed}"
    
    # Return the hash value
    echo "${parsed}"
    return 0
}

# Task: Capture FIPS hash (only runs for auto mode)
do_wolfssl_fips_capture_hash() {

    # Place a placeholder hash in fips_test.c before capturing
    PLACEHOLDER_HASH="FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    bbnote "Setting placeholder hash in fips_test.c: ${PLACEHOLDER_HASH}"
    
    if [ -f "${S}/wolfcrypt/src/fips_test.c" ]; then
        cp ${S}/wolfcrypt/src/fips_test.c ${S}/wolfcrypt/src/fips_test.c.orig
        sed "s/^\".*\";/\"${PLACEHOLDER_HASH}\";/" ${S}/wolfcrypt/src/fips_test.c.orig > ${S}/wolfcrypt/src/fips_test.c
        # Force rebuild by removing test binary and touching source
        rm -f ${B}/wolfcrypt/test/.libs/testwolfcrypt ${B}/wolfcrypt/test/testwolfcrypt
        touch ${S}/wolfcrypt/src/fips_test.c
    fi
    
    # Reconfigure to ensure placeholder is used
    do_configure


    # Capture the hash (eval to handle both function call and direct value)
    set +e
    CAPTURED_HASH=$(get_wolfssl_fips_hash)
    local rc=$?
    set -e

    if [ ${rc} -ne 0 ] || [ -z "${CAPTURED_HASH}" ]; then
        bberror "Failed to capture wolfSSL FIPS hash (rc=${rc})"
        bbfatal "FIPS hash capture failed - cannot continue"
    fi
    
    # Display the captured hash
    bbplain "=========================================="
    bbplain "wolfSSL FIPS Hash (auto mode): ${CAPTURED_HASH}"
    bbplain "=========================================="
    
    # Update fips_test.c with the captured hash (same as official fips-hash.sh)
    if [ ! -f "${S}/wolfcrypt/src/fips_test.c" ]; then
        bbfatal "fips_test.c not found at ${S}/wolfcrypt/src/fips_test.c"
    fi
    
    # Create backup of original if it doesn't exist yet
    if [ ! -f "${S}/wolfcrypt/src/fips_test.c.bak" ]; then
        bbnote "Creating backup of original fips_test.c"
        cp ${S}/wolfcrypt/src/fips_test.c ${S}/wolfcrypt/src/fips_test.c.bak
    fi
    
    bbnote "Updating fips_test.c with captured hash"
    sed "s/^\".*\";/\"${CAPTURED_HASH}\";/" ${S}/wolfcrypt/src/fips_test.c > ${S}/wolfcrypt/src/fips_test.c.tmp
    mv ${S}/wolfcrypt/src/fips_test.c.tmp ${S}/wolfcrypt/src/fips_test.c
    
    bbnote "Updated fips_test.c with hash: ${CAPTURED_HASH}"
    
    # Run configure again
    do_configure
}

do_wolfssl_fips_capture_hash_manual() {

    # Manual mode: just use the configured FIPS_HASH value
    CAPTURED_HASH=${FIPS_HASH}
    
    if [ -z "${CAPTURED_HASH}" ]; then
        bbfatal "FIPS_HASH is not set in manual mode"
    fi
    
    # Display the configured hash
    bbplain "=========================================="
    bbplain "wolfSSL FIPS Hash (manual mode): ${CAPTURED_HASH}"
    bbplain "=========================================="
    
    # Update fips_test.c with the configured hash
    if [ ! -f "${S}/wolfcrypt/src/fips_test.c" ]; then
        bbfatal "fips_test.c not found at ${S}/wolfcrypt/src/fips_test.c"
    fi
    
    # Create backup of original if it doesn't exist yet
    if [ ! -f "${S}/wolfcrypt/src/fips_test.c.bak" ]; then
        bbnote "Creating backup of original fips_test.c"
        cp ${S}/wolfcrypt/src/fips_test.c ${S}/wolfcrypt/src/fips_test.c.bak
    fi
    
    bbnote "Updating fips_test.c with configured hash"
    sed "s/^\".*\";/\"${CAPTURED_HASH}\";/" ${S}/wolfcrypt/src/fips_test.c > ${S}/wolfcrypt/src/fips_test.c.tmp
    mv ${S}/wolfcrypt/src/fips_test.c.tmp ${S}/wolfcrypt/src/fips_test.c
    
    bbnote "Updated fips_test.c with hash: ${CAPTURED_HASH}"
    
    # Reconfigure to pick up the updated hash
    # Note: wolfssl_fips_clean_config will run automatically via prefuncs
    do_configure
}


# Task metadata
do_wolfssl_fips_capture_hash[doc] = "Capture FIPS hash from test binary"
do_wolfssl_fips_capture_hash[dirs] = "${B} ${S}"
do_wolfssl_fips_capture_hash[nostamp] = "1"

