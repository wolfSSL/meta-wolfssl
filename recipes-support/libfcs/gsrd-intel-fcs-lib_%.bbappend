# The Agilex 5 GSRD recipe installs only the versioned runtime library. Add the
# development linker name so dependent recipes can use -lFCS from their
# recipe-specific sysroots.
do_install:append() {
    if [ -e ${D}${prefix}/lib/libFCS.so.3 ]; then
        install -d ${D}${libdir}
        if [ "${libdir}" = "${prefix}/lib" ]; then
            ln -sfn libFCS.so.3 ${D}${libdir}/libFCS.so
        else
            ln -sfn ../lib/libFCS.so.3 ${D}${libdir}/libFCS.so
        fi
    fi
}
