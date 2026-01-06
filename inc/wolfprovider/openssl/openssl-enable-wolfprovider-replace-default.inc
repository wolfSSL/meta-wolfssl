# Check Yocto version and include appropriate file
def openssl_get_wolfprovider_replace_default_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("openssl-enable-wolfprovider-replace-default.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

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
        codename_file = os.path.join(layerdir, 'inc/wolfprovider/openssl/%s/openssl-enable-wolfprovider-replace-default-%s.inc' % (codename, file_type))
        if os.path.exists(codename_file):
            inc_file = codename_file
        else:
            # Fallback to generic modern/legacy at root
            inc_file = os.path.join(layerdir, 'inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default-%s.inc' % file_type)
    else:
        inc_file = os.path.join(layerdir, 'inc/wolfprovider/openssl/openssl-enable-wolfprovider-replace-default-%s.inc' % file_type)

    bb.note("openssl-enable-wolfprovider-replace-default.inc: Including file: %s" % inc_file)
    return inc_file

# Include the appropriate file
require ${@openssl_get_wolfprovider_replace_default_inc(d)}
