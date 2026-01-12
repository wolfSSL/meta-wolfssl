# Use Yocto's native GCS/tarball fetch path instead of the 7z helper when
# WOLFSSL_BUNDLE_GCS_URI is provided. This disables the custom commercial
# extraction task and lets BitBake handle download + unpack.
WOLFSSL_BUNDLE_GCS_URI ?= ""

python () {
    import bb
    import bb.build

    uri = d.getVar('WOLFSSL_BUNDLE_GCS_URI')
    if not uri or not uri.strip():
        return

    sha = d.getVar('WOLFSSL_SRC_SHA') or ''
    bundle_file = d.getVar('WOLFSSL_BUNDLE_FILE') or d.getVar('COMMERCIAL_BUNDLE_ARCHIVE') or ''

    flags = ''
    if bundle_file:
        flags += f';downloadfilename={bundle_file}'
    if sha:
        flags += f';sha256sum={sha}'

    d.setVar('SRC_URI', f"{uri}{flags}")

    # Use WOLFSSL_SRC_SUBDIR if set, otherwise fall back to WOLFSSL_SRC
    src_subdir = d.getVar('WOLFSSL_SRC_SUBDIR') or d.getVar('WOLFSSL_SRC')
    d.setVar('S', f"{d.getVar('WORKDIR')}/{src_subdir}")
    d.setVar('COMMERCIAL_BUNDLE_ENABLED', '0')
    d.setVar('COMMERCIAL_BUNDLE_DIR', '${DL_DIR}')

    # Only tarballs are expected on this path; rely on BitBake unpack
    bb.build.deltask('do_commercial_extract', d)
}
