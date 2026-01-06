# Check Yocto version and include appropriate file
def nettle_get_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("nettle.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

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

    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    if use_modern:
        inc_file = os.path.join(layerdir, 'inc/nettle/%s/nettle-modern.inc' % codename)
    else:
        inc_file = os.path.join(layerdir, 'inc/nettle/%s/nettle-legacy.inc' % codename)

    bb.note("nettle.inc: Including file: %s" % inc_file)
    return inc_file

# Include the appropriate file
require ${@nettle_get_inc(d)}
