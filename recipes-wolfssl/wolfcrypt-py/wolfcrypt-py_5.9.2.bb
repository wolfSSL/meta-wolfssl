SUMMARY = "wolfCrypt Python, a.k.a. wolfcrypt is a Python module that \
           encapsulates wolfSSL's wolfCrypt API."

DESCRIPTION = "wolfCrypt is a lightweight, portable, C-language-based crypto \
               library targeted at IoT, embedded, and RTOS environments \
               primarily because of its size, speed, and feature set. It works \
               seamlessly in desktop, enterprise, and cloud environments as \
               well. It is the crypto engine behind wolfSSL's embedded ssl \
               library."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssl"
BUGTRACKER = "https://github.com/wolfSSL/wolfcrypt-py/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSING.rst;md5=d71e0db8cc0e980314b646228d44d3d9"

SRC_URI = "git://github.com/wolfSSL/wolfcrypt-py.git;nobranch=1;protocol=https;rev=f82dbb6e110675118e7ecceda3402df01a8ba694"

# 5.9.2 declares its license the PEP 639 way, which only setuptools >= 77 accepts.
# Apply the PEP 621 table-form compat patch only on the Yocto releases whose setuptools
# is in the 61..76 window; kirkstone and older ignore [project], wrynose (>= 77) is
# native. Gated on the release codename so newer series keep the upstream metadata.
WOLFCRYPT_PY_LICENSE_COMPAT_SERIES = "langdale mickledore nanbield scarthgap styhead walnascar"
python () {
    affected = set((d.getVar('WOLFCRYPT_PY_LICENSE_COMPAT_SERIES') or '').split())
    series = set((d.getVar('LAYERSERIES_CORENAMES') or '').split())
    if affected & series:
        d.appendVar('SRC_URI', ' file://wolfcrypt-py-pyproject-license-compat.patch')
}

# wolfcrypt-py imports typing_extensions.override (needs typing-extensions >= 4.4).
# These releases ship an older version, so patch in a no-op fallback decorator.
WOLFCRYPT_PY_TYPING_COMPAT_SERIES = "sumo thud warrior zeus dunfell gatesgarth hardknott honister kirkstone langdale"
python () {
    affected = set((d.getVar('WOLFCRYPT_PY_TYPING_COMPAT_SERIES') or '').split())
    series = set((d.getVar('LAYERSERIES_CORENAMES') or '').split())
    if affected & series:
        d.appendVar('SRC_URI', ' file://wolfcrypt-py-typing-extensions-compat.patch')
}

DEPENDS += " virtual/wolfssl \
            python3-pip-native \
            python3-cffi-native \
            python3-cffi \
            python3-native \
            python3 \
            "

inherit setuptools3 wolfssl-compatibility

python __anonymous() {
    wolfssl_varAppend(d, 'RDEPENDS', '${PN}', ' wolfssl python3 python3-cffi python3-typing-extensions')
}

python () {
    if d.getVar('UNPACKDIR', False):
        d.setVar('S', '${UNPACKDIR}/${BP}')
    else:
        d.setVar('S', '${WORKDIR}/git')
}

export USE_LOCAL_WOLFSSL="${STAGING_EXECPREFIXDIR}"
# Add reproducible build flags
CFLAGS += " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
CXXFLAGS += " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."
LDFLAGS += " -Wl,--build-id=none"


# Ensure consistent locale for build reproducibility
export LC_ALL = "C"

