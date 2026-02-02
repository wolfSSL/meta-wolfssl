# Check Yocto version and include appropriate file
def libssh_get_libgcrypt_wolfssl_inc(d):
    import os
    layerseries = d.getVar('LAYERSERIES_CORENAMES') or ""

    bb.note("libssh-enable-libgcrypt-wolfssl.inc: LAYERSERIES_CORENAMES = %s" % layerseries)

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
        inc_file = os.path.join(layerdir, 'inc/libssh/%s/libssh-enable-libgcrypt-wolfssl-modern.inc' % codename)
    else:
        inc_file = os.path.join(layerdir, 'inc/libssh/%s/libssh-enable-libgcrypt-wolfssl-legacy.inc' % codename)

    bb.note("libssh-enable-libgcrypt-wolfssl.inc: Including file: %s" % inc_file)
    return inc_file

# Include the appropriate file
require ${@libssh_get_libgcrypt_wolfssl_inc(d)}
