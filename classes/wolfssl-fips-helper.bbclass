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
WOLFSSL_FIPS_HASH_FILE ?= "${WORKDIR}/wolfssl-fips.hash"
WOLFSSL_FIPS_HASH_LOG ?= "${T}/wolfssl-fips-hash.log"

# Test binary configuration
WOLFSSL_FIPS_TEST_BINARY ?= "${B}/wolfcrypt/test/.libs/testwolfcrypt"
WOLFSSL_FIPS_TEST_ARGS ?= ""

# QEMU configuration
WOLFSSL_FIPS_QEMU_EXTRA ?= ""
WOLFSSL_FIPS_FORCE_NATIVE ?= "0"
WOLFSSL_FIPS_FORCE_QEMU ?= "0"
WOLFSSL_FIPS_LIBRARY_PATH ?= "${B}/src/.libs:${B}/wolfcrypt/src/.libs:${STAGING_DIR_TARGET}/lib:${STAGING_DIR_TARGET}/usr/lib:${STAGING_DIR_TARGET}/lib64:${STAGING_DIR_TARGET}/usr/lib64"

# Auto-detected variables
WOLFSSL_QEMU_SUFFIX ?= ""
WOLFSSL_QEMU_BINARY ?= "${STAGING_BINDIR_NATIVE}/qemu-${WOLFSSL_QEMU_SUFFIX}"
WOLFSSL_FIPS_INTERPRETER ?= "${WOLFSSL_FIPS_INTERPRETER_AUTO}"

# Dynamic variable setup
python __anonymous () {
    import bb
    import glob
    import os

    mode = d.getVar('WOLFSSL_FIPS_HASH_MODE')
    
    # If manual mode, just set the hash in CFLAGS and we're done
    if mode != 'auto':
        d.appendVar('TARGET_CFLAGS', ' -DWOLFCRYPT_FIPS_CORE_HASH_VALUE=%s' % d.getVar('FIPS_HASH'))
        return

    # Auto mode: detect architecture for QEMU
    arch = d.getVar('TARGET_ARCH')
    suffix_map = {
        "aarch64": "aarch64",
        "arm": "arm",
        "armeb": "armeb",
        "x86_64": "x86_64",
        "i586": "i386",
        "i686": "i386",
        "powerpc": "ppc",
        "powerpc64": "ppc64",
        "mips": "mips",
        "mipsel": "mipsel",
        "riscv64": "riscv64",
        "riscv32": "riscv32"
    }
    suffix = suffix_map.get(arch, "")
    if suffix:
        d.setVar('WOLFSSL_QEMU_SUFFIX', suffix)
    else:
        d.setVar('WOLFSSL_QEMU_SUFFIX', '')

    # Add qemu-native dependency for cross-compilation
    if mode == 'auto':
        d.appendVar('DEPENDS', ' qemu-native')

    # Auto-detect target interpreter
    staging_dir = d.getVar('STAGING_DIR_TARGET')
    interpreter = ""
    if staging_dir:
        search_paths = [
            os.path.join(staging_dir, 'lib', 'ld-linux*so*'),
            os.path.join(staging_dir, 'lib64', 'ld-linux*so*'),
            os.path.join(staging_dir, 'usr', 'lib', 'ld-linux*so*'),
            os.path.join(staging_dir, 'usr', 'lib64', 'ld-linux*so*'),
        ]
        for pattern in search_paths:
            matches = glob.glob(pattern)
            if matches:
                interpreter = matches[0]
                break
    d.setVar('WOLFSSL_FIPS_INTERPRETER_AUTO', interpreter)
}

# Ensure qemu-native is built if needed
do_compile[depends] += "${@bb.utils.contains('WOLFSSL_FIPS_HASH_MODE', 'auto', ' qemu-native:do_populate_sysroot', '', d)}"

# Exclude auto-detected variables from task hash to avoid non-deterministic builds
do_compile[vardepsexclude] += "WOLFSSL_FIPS_INTERPRETER_AUTO WOLFSSL_QEMU_SUFFIX"

# Helper function: Compile with specific hash
wolfssl_fips_compile_pass() {
    local hash="$1"
    export CFLAGS="${WOLFSSL_FIPS_BASE_CFLAGS} -DWOLFCRYPT_FIPS_CORE_HASH_VALUE=${hash}"
    export TARGET_CFLAGS="${WOLFSSL_FIPS_BASE_TARGET_CFLAGS} -DWOLFCRYPT_FIPS_CORE_HASH_VALUE=${hash}"
    autotools_do_compile
    export CFLAGS="${WOLFSSL_FIPS_BASE_CFLAGS}"
    export TARGET_CFLAGS="${WOLFSSL_FIPS_BASE_TARGET_CFLAGS}"
}

# Helper function: Configure with specific hash
wolfssl_fips_configure_pass() {
    local hash="$1"
    export CFLAGS="${WOLFSSL_FIPS_BASE_CFLAGS} -DWOLFCRYPT_FIPS_CORE_HASH_VALUE=${hash}"
    export TARGET_CFLAGS="${WOLFSSL_FIPS_BASE_TARGET_CFLAGS} -DWOLFCRYPT_FIPS_CORE_HASH_VALUE=${hash}"
    autotools_do_configure
    export CFLAGS="${WOLFSSL_FIPS_BASE_CFLAGS}"
    export TARGET_CFLAGS="${WOLFSSL_FIPS_BASE_TARGET_CFLAGS}"
}

# Helper function: Build the test binary
wolfssl_fips_build_test_binary() {
    if [ -x "${WOLFSSL_FIPS_TEST_BINARY}" ]; then
        return
    fi

    bbnote "Building wolfCrypt test binary for FIPS hash generation"
    oe_runmake -C ${B}/wolfcrypt/test testwolfcrypt
}

# Helper function: Capture FIPS hash from test binary
wolfssl_fips_capture_hash() {
    if [ ! -x "${WOLFSSL_FIPS_TEST_BINARY}" ]; then
        bbfatal "wolfCrypt test binary ${WOLFSSL_FIPS_TEST_BINARY} not found; cannot capture FIPS hash"
    fi

    export LD_LIBRARY_PATH="${B}/src/.libs:${B}/wolfcrypt/src/.libs:${LD_LIBRARY_PATH}"
    local runner=""
    local need_qemu=0
    
    # Determine if we need QEMU for cross-compilation
    if [ "${BUILD_ARCH}" != "${TARGET_ARCH}" ]; then
        need_qemu=1
        if [ "${WOLFSSL_FIPS_FORCE_NATIVE}" = "1" ]; then
            need_qemu=0
        fi
    elif [ "${WOLFSSL_FIPS_FORCE_QEMU}" = "1" ]; then
        need_qemu=1
    fi

    # Setup QEMU if needed
    if [ ${need_qemu} -eq 1 ]; then
        runner="${WOLFSSL_QEMU_BINARY}"
        if [ -z "${runner}" ] || [ ! -x "${runner}" ]; then
            if [ "${BUILD_ARCH}" != "${TARGET_ARCH}" ]; then
                bbfatal "No qemu binary available for ${TARGET_ARCH} (expected ${runner}). Set WOLFSSL_FIPS_HASH_MODE=\"manual\" or install qemu-user."
            else
                bbwarn "QEMU binary ${runner} not found; falling back to native execution for FIPS hash capture."
                runner=""
            fi
        else
            runner="${runner} ${WOLFSSL_FIPS_QEMU_EXTRA}"
            export QEMU_LD_PREFIX="${STAGING_DIR_TARGET}"
        fi
    fi

    # Check if we can use target interpreter for native builds
    local use_interpreter=0
    if [ -z "${runner}" ] && [ "${BUILD_ARCH}" = "${TARGET_ARCH}" ]; then
        if [ -n "${WOLFSSL_FIPS_INTERPRETER}" ] && [ -x "${WOLFSSL_FIPS_INTERPRETER}" ]; then
            use_interpreter=1
        fi
    fi

    if [ ${use_interpreter} -eq 1 ]; then
        bbnote "Capturing wolfSSL FIPS hash using target interpreter ${WOLFSSL_FIPS_INTERPRETER}"
    else
        bbnote "Capturing wolfSSL FIPS hash using ${runner:-native execution}"
    fi

    # Run the test binary to extract hash
    set +e
    if [ -n "${runner}" ]; then
        ${runner} ${WOLFSSL_FIPS_TEST_BINARY} ${WOLFSSL_FIPS_TEST_ARGS} > ${WOLFSSL_FIPS_HASH_LOG} 2>&1
    elif [ ${use_interpreter} -eq 1 ]; then
        ${WOLFSSL_FIPS_INTERPRETER} --library-path ${WOLFSSL_FIPS_LIBRARY_PATH} ${WOLFSSL_FIPS_TEST_BINARY} ${WOLFSSL_FIPS_TEST_ARGS} > ${WOLFSSL_FIPS_HASH_LOG} 2>&1
    else
        ${WOLFSSL_FIPS_TEST_BINARY} ${WOLFSSL_FIPS_TEST_ARGS} > ${WOLFSSL_FIPS_HASH_LOG} 2>&1
    fi
    local rc=$?
    set -e

    # Check if we got output
    if [ ! -s "${WOLFSSL_FIPS_HASH_LOG}" ]; then
        bbfatal "wolfCrypt test produced no output (rc=${rc}). See ${WOLFSSL_FIPS_HASH_LOG}"
    fi

    # Parse the hash from output
    local parsed=$(grep -E "hash = " "${WOLFSSL_FIPS_HASH_LOG}" | tail -n1 | awk -F'=' '{print $2}' | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    if [ -z "${parsed}" ]; then
        bbfatal "Unable to parse FIPS hash from ${WOLFSSL_FIPS_HASH_LOG}. Manually inspect the log and set FIPS_HASH if needed."
    fi

    echo "${parsed}" > "${WOLFSSL_FIPS_HASH_FILE}"
    bbnote "wolfSSL FIPS hash captured: ${parsed}"
}

# Override do_compile for two-pass FIPS build
do_compile() {
    # If manual mode, just do normal compile
    if [ "${WOLFSSL_FIPS_HASH_MODE}" != "auto" ]; then
        autotools_do_compile
        return
    fi

    # Save base CFLAGS for restoration between passes
    WOLFSSL_FIPS_BASE_CFLAGS="${CFLAGS}"
    WOLFSSL_FIPS_BASE_TARGET_CFLAGS="${TARGET_CFLAGS}"

    # First pass: Build with placeholder hash
    bbnote "wolfSSL FIPS auto mode: compiling placeholder image"
    wolfssl_fips_compile_pass "${WOLFSSL_FIPS_PLACEHOLDER}"
    wolfssl_fips_build_test_binary
    wolfssl_fips_capture_hash

    # Verify we got a hash
    if [ ! -f "${WOLFSSL_FIPS_HASH_FILE}" ]; then
        bbfatal "wolfSSL FIPS hash file ${WOLFSSL_FIPS_HASH_FILE} missing after capture step"
    fi

    FINAL_FIPS_HASH=$(cat "${WOLFSSL_FIPS_HASH_FILE}")
    if [ -z "${FINAL_FIPS_HASH}" ]; then
        bbfatal "wolfSSL FIPS hash capture produced an empty value"
    fi

    # Second pass: Reconfigure and rebuild with real hash
    bbnote "wolfSSL FIPS auto mode: reconfiguring and rebuilding with hash ${FINAL_FIPS_HASH}"
    rm -f ${B}/config.status ${B}/config.cache
    wolfssl_fips_configure_pass "${FINAL_FIPS_HASH}"
    wolfssl_fips_compile_pass "${FINAL_FIPS_HASH}"
}

