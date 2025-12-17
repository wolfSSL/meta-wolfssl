# Check Yocto version and include appropriate file
python() {
    import os

    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    # Check if version is 3.1 or newer (dunfell and later)
    use_modern = False
    codename = None
    if layerseries:
        series_list = layerseries.split()
        modern_series = ['dunfell', 'gatesgarth', 'hardknott', 'honister', 'kirkstone', 'langdale', 'mickledore', 'nanbield', 'scarthgap']
        for series in series_list:
            codename = series
            if series in modern_series:
                use_modern = True
                break

    # Determine file type
    file_type = 'modern' if use_modern else 'legacy'

    # Try codename-specific path first, fallback to generic
    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if codename:
        codename_file = os.path.join(layerdir, f'inc/wolfprovider/openssl/{codename}/openssl-enable-wolfprovider-{file_type}.inc')
        if os.path.exists(codename_file):
            require_file = codename_file
        else:
            # Fallback to generic modern/legacy at root
            require_file = os.path.join(layerdir, f'inc/wolfprovider/openssl/openssl-enable-wolfprovider-{file_type}.inc')
    else:
        require_file = os.path.join(layerdir, f'inc/wolfprovider/openssl/openssl-enable-wolfprovider-{file_type}.inc')

    # Include the appropriate file
    bb.parse.handle(require_file, d, True)
}