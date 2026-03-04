# Check Yocto version and include appropriate file
def wolfssl_linuxkm_get_sign_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("wolfssl-linuxkm-sign-module.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

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
        inc_file = os.path.join(layerdir, 'inc/wolfssl-linuxkm/%s/wolfssl-linuxkm-sign-module-modern.inc' % codename)
    else:
        inc_file = os.path.join(layerdir, 'inc/wolfssl-linuxkm/%s/wolfssl-linuxkm-sign-module-legacy.inc' % codename)

    bb.note("wolfssl-linuxkm-sign-module.inc: Including file: %s" % inc_file)
    return inc_file

require ${@wolfssl_linuxkm_get_sign_inc(d)}
