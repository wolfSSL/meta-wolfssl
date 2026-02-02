# Check Yocto version and include appropriate file
def wolfssl_get_wolfcrypt_py_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("wolfssl-enable-wolfcrypt-py.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

    # Check if version is 3.1 or newer (dunfell and later)
    use_modern = False
    if layerseries:
        series_list = layerseries.split()
        modern_series = ['dunfell', 'gatesgarth', 'hardknott', 'honister', 'kirkstone', 'langdale', 'mickledore', 'nanbield', 'scarthgap']
        for series in series_list:
            if series in modern_series:
                use_modern = True
                break

    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if use_modern:
        inc_file = os.path.join(layerdir, 'inc/wolfcrypt-py/wolfssl-enable-wolfcrypt-py-modern.inc')
    else:
        inc_file = os.path.join(layerdir, 'inc/wolfcrypt-py/wolfssl-enable-wolfcrypt-py-legacy.inc')

    bb.note("wolfssl-enable-wolfcrypt-py.inc: Including file: %s" % inc_file)
    return inc_file

# Include the appropriate file
require ${@wolfssl_get_wolfcrypt_py_inc(d)}