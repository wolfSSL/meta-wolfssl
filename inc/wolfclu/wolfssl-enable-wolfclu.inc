# Per-release variant selection (lists in conf/layer.conf)
def _wsel_inc_wolfclu_wolfssl_enable_wolfclu(d):
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
    return os.path.join(d.getVar('WOLFSSL_LAYERDIR'), 'inc/wolfclu/wolfssl-enable-wolfclu-{variant}.inc'.format(variant=variant, codename=codename))
require ${@_wsel_inc_wolfclu_wolfssl_enable_wolfclu(d)}
