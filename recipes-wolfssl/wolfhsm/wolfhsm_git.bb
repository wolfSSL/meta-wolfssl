SUMMARY = "wolfHSM hardware security module framework (source staging)"
DESCRIPTION = "wolfHSM provides a client/server protocol for offloading key \
storage and cryptographic operations to a secure processor or enclave, plus \
platform ports supplying the transport, flash, time and lock primitives. \
This recipe stages the wolfHSM sources and headers for other recipes to \
compile in-tree; it does not build a library. See the note below."

# WHY THIS STAGES SOURCE INSTEAD OF BUILDING A LIBRARY
#
# wolfHSM is configured by the application that uses it: wolfhsm/wh_settings.h
# does `#include "wolfhsm_cfg.h"` whenever WOLFHSM_CFG is defined, and that
# header selects the transport, the NVM backend, buffer sizes, whether crypto
# is compiled in at all, and much else. Two consumers with different
# wolfhsm_cfg.h files do not share an ABI, so there is no single libwolfhsm
# that would be correct to ship.
#
# wolfHSM also has no build system to drive: its top-level Makefile only
# recurses into test/, benchmark/, tools/ and examples/, each of which brings
# its own wolfhsm_cfg.h. Upstream expects you to compile src/*.c and one
# port/*/ directory directly into your application, which is what this recipe
# makes possible from a Yocto build.
#
# Consumers therefore DEPEND on wolfhsm and point their build at
# ${STAGING_DATADIR}/wolfhsm, supplying their own wolfhsm_cfg.h. See README.md.

require wolfhsm.inc

# For wolfssl_varSet(): the package variables below have to be written with
# either ':' or '_' depending on the Yocto release, and this layer still
# supports both (LAYERSERIES_COMPAT reaches back to sumo).
inherit wolfssl-compatibility

SRC_URI += "file://wolfhsm.mk"

# Which port/ directories to stage. wolfHSM ships ports for posix, skeleton,
# microchip, infineon, stmicro, renesas and ti; staging all of them would put
# a lot of unrelated vendor code in every sysroot. Override in local.conf or a
# bbappend, e.g. WOLFHSM_PORTS = "posix infineon".
WOLFHSM_PORTS ?= "posix"

PV = "1.4.0+git"

# Nothing to build. See the note above.
do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    install -d ${D}${datadir}/wolfhsm

    # Headers and core sources. Consumers add -I${STAGING_DATADIR}/wolfhsm so
    # that #include "wolfhsm/wh_client.h" resolves, which is why the wolfhsm/
    # directory is preserved rather than flattened.
    cp -R --no-dereference --preserve=mode,timestamps \
        ${S}/wolfhsm ${S}/src ${D}${datadir}/wolfhsm/

    install -d ${D}${datadir}/wolfhsm/port
    for port in ${WOLFHSM_PORTS}; do
        if [ ! -d ${S}/port/$port ]; then
            bbfatal "WOLFHSM_PORTS names '$port' but ${S}/port/$port does not exist."
        fi
        cp -R --no-dereference --preserve=mode,timestamps \
            ${S}/port/$port ${D}${datadir}/wolfhsm/port/
    done

    # Also expose the headers at the conventional include path, for consumers
    # that only need to call the client API against a library someone else
    # already compiled (e.g. an application linking a vendor's libwolfhsm).
    install -d ${D}${includedir}/wolfhsm
    install -m 0644 ${S}/wolfhsm/*.h ${D}${includedir}/wolfhsm/

    # ${WORKDIR}, not ${UNPACKDIR}: the layer still supports pre-styhead
    # releases (LAYERSERIES_COMPAT reaches back to sumo) where file:// SRC_URI
    # entries unpack straight into ${WORKDIR}.
    install -m 0644 ${WORKDIR}/wolfhsm.mk ${D}${datadir}/wolfhsm/wolfhsm.mk
}

# ${datadir} is already part of the default SYSROOT_DIRS; named explicitly so
# the staging behaviour this recipe depends on is visible at a glance.
SYSROOT_DIRS += "${datadir}/wolfhsm"

python __anonymous() {
    # Everything lands in -dev. wolfHSM source has no business in a target
    # rootfs: it is a build input, not a runtime artifact. FILES for ${PN} is
    # emptied because the default value claims ${datadir}/${BPN}, which is
    # exactly our staging dir.
    wolfssl_varSet(d, 'FILES', '${PN}', '')
    wolfssl_varSet(d, 'FILES', '${PN}-dev',
                   d.expand('${datadir}/wolfhsm ${includedir}/wolfhsm'))

    # bitbake.conf defaults RDEPENDS for ${PN}-dev to "${PN} (= ${EXTENDPKGV})".
    # With no files in ${PN} that package is never produced, which would leave
    # wolfhsm-dev with an unsatisfiable runtime dependency at rootfs/SDK
    # install time. There is nothing at runtime to depend on, so clear it.
    wolfssl_varSet(d, 'RDEPENDS', '${PN}-dev', '')
}

BBCLASSEXTEND = "native nativesdk"
