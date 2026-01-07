# Check Yocto version and include appropriate file
def openssl_get_wolfprovider_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("openssl-enable-wolfprovider.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

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

    # Try codename-specific directory first, fallback to scarthgap (most recent stable)
    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if codename:
        codename_dir = os.path.join(layerdir, 'inc/wolfprovider/openssl/%s' % codename)
        if os.path.isdir(codename_dir):
            # Use codename-specific file
            inc_file = os.path.join(codename_dir, 'openssl-enable-wolfprovider-%s.inc' % file_type)
        else:
            # Fallback to scarthgap (most recent stable version)
            inc_file = os.path.join(layerdir, 'inc/wolfprovider/openssl/scarthgap/openssl-enable-wolfprovider-%s.inc' % file_type)
    else:
        # If no codename detected, use scarthgap as default
        inc_file = os.path.join(layerdir, 'inc/wolfprovider/openssl/scarthgap/openssl-enable-wolfprovider-%s.inc' % file_type)

    bb.note("openssl-enable-wolfprovider.inc: Including file: %s" % inc_file)
    return inc_file

# Include the appropriate file
require ${@openssl_get_wolfprovider_inc(d)}