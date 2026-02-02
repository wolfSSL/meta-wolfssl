#Adjust these as needed
WOLFSSH_VERSION ?= ""

WOLFSSH_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2024.pdf"
WOLFSSH_LICENSE_MD5 ?= "9b56a02d020e92a4bd49d0914e7d7db8"
WOLFSSH_SRC ?= ""
WOLFSSH_SRC_SHA ?= ""
WOLFSSH_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFSSH_VERSION}"

BBFILE_PRIORITY='1'
