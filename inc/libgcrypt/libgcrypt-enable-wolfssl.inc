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

    if use_modern:
        require_file = os.path.join(d.getVar('WOLFSSL_LAYERDIR'), f'inc/libgcrypt/{codename}/libgcrypt-enable-wolfssl-modern.inc')
    else:
        require_file = os.path.join(d.getVar('WOLFSSL_LAYERDIR'), f'inc/libgcrypt/{codename}/libgcrypt-enable-wolfssl-legacy.inc')

    # Include the appropriate file
    bb.parse.handle(require_file, d, True)
}