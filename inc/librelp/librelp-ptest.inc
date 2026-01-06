# Check Yocto version and include appropriate file
def librelp_get_ptest_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("librelp-ptest.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

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

    # Use codename-specific path
    layerdir = d.getVar('WOLFSSL_LAYERDIR')
    inc_file = os.path.join(layerdir, 'inc/librelp/%s/librelp-ptest-%s.inc' % (codename, file_type))

    bb.note("librelp-ptest.inc: Including file: %s" % inc_file)
    return inc_file

# Include the appropriate file
require ${@librelp_get_ptest_inc(d)}
