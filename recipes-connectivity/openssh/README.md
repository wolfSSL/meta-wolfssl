# OpenSSH with wolfSSL

openssh_%.bbappend sets up the OpenSSH recipe to use wolfSSL instead of OpenSSL.
wolfSSL should be configured with `--enable-openssh`. OpenSSH also needs to be
patched, which is accomplished with the patch at
files/wolfssl-openssh-8.5p1.patch. This patch comes from [the wolfSSL OSP (open
source projects) repo](https://github.com/wolfSSL/osp). For other OpenSSH
version patches, check out the OSP repo.
