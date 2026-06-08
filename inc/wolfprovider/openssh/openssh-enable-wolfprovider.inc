# Per-release variant selection, codename dir with scarthgap fallback
def openssh_get_wolfprovider_inc(d):
    import os
    series = (d.getVar('LAYERSERIES_CORENAMES') or '').split()
    legacy = set((d.getVar('WOLFSSL_LEGACY_SERIES') or '').split())
    modern = set((d.getVar('WOLFSSL_MODERN_SERIES') or '').split())
    variant = 'modern'
    codename = series[-1] if series else ''
    for s in series:
        codename = s
        if s in legacy:
            variant = 'legacy'
            break
        if s in modern:
            variant = 'modern'
            break
    base = os.path.join(d.getVar('WOLFSSL_LAYERDIR'), 'inc/wolfprovider/openssh')
    cdir = os.path.join(base, codename)
    if codename and os.path.isdir(cdir):
        return os.path.join(cdir, 'openssh-enable-wolfprovider-%s.inc' % variant)
    return os.path.join(base, 'scarthgap', 'openssh-enable-wolfprovider-%s.inc' % variant)

require ${@openssh_get_wolfprovider_inc(d)}
