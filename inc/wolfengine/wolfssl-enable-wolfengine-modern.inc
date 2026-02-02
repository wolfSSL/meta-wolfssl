# Configuration to enable wolfengine support in wolfssl

python() {
    # Get the package revision (PR) for wolfssl
    wolfssl_pr = d.getVar('PR', True)

    # Based on the revision, conditionally append to EXTRA_OECONF
    if wolfssl_pr == 'commerical.fips':
        d.appendVar('EXTRA_OECONF', ' --enable-engine=fips-v5')
    elif wolfssl_pr == 'fipsReady':
        d.appendVar('EXTRA_OECONF', ' --enable-engine=fips-ready')
    else:
        d.appendVar('EXTRA_OECONF', ' --enable-engine=no-fips')
}
