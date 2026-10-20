# Altera's libfcs recipes install only the versioned runtime library. Add the
# linker name so dependent recipes can use -lFCS from their sysroots.
do_install:append() {
    for lib in ${D}${prefix}/lib/libFCS.so.[0-9]*; do
        [ -e "$lib" ] || continue
        name="$(basename "$lib")"
        install -d ${D}${libdir}
        if [ "${libdir}" = "${prefix}/lib" ]; then
            ln -sfn "$name" ${D}${libdir}/libFCS.so
        else
            ln -sfn "../lib/$name" ${D}${libdir}/libFCS.so
        fi
        break
    done
}
