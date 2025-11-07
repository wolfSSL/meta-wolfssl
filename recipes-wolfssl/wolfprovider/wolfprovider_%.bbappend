# Enable quick test mode to skip some long-running tests
CFLAGS:append = " -DWOLFPROV_QUICKTEST"
CXXFLAGS:append = " -DWOLFPROV_QUICKTEST"

# Uncomment to enable debug for wolfProvider
# CFLAGS = " -I${S}/include -g -O0 -ffile-prefix-map=${WORKDIR}=."
# CXXFLAGS = " -I${S}/include -g -O0 -ffile-prefix-map=${WORKDIR}=."
# LDFLAGS = " -Wl,--build-id=none"
# EXTRA_OECONF += " --enable-debug"
