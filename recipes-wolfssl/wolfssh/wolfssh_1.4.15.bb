SUMMARY = "wolfSSH Lightweight SSH Library"
DESCRIPTION = "wolfSSH is a lightweight SSHv2 library written in ANSI C and \
               targeted for embedded, RTOS, and resource-constrained \
               environments. wolfSSH supports client and server sides, and \
               includes support for SCP and SFTP."
HOMEPAGE = "https://www.wolfssl.com/products/wolfssh"
BUGTRACKER = "https://github.com/wolfssl/wolfssh/issues"
SECTION = "libs"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSING;md5=2c2d0ee3db6ceba278dd43212ed03733"

DEPENDS += "wolfssl"

SRC_URI = "git://github.com/wolfssl/wolfssh.git;nobranch=1;protocol=https;rev=60a29602e5893fd4e2ca0f4b6e2e05c6324154ed"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

EXTRA_OECONF = "--with-wolfssl=${COMPONENTS_DIR}/${PACKAGE_ARCH}/wolfssl/usr"

do_configure:prepend() {
    (cd ${S}; ./autogen.sh; cd -)
}

# Add reproducible build flags                                                  
CFLAGS:append = " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."                       
CXXFLAGS:append = " -g0 -O2 -ffile-prefix-map=${WORKDIR}=."                     
LDFLAGS:append = " -Wl,--build-id=none"                                         

# Ensure consistent locale                                                      
export LC_ALL = "C" 
