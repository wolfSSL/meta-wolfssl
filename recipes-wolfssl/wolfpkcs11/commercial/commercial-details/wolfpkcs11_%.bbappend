#Adjust these as needed
WOLFPKCS11_VERSION ?= ""

WOLF_LICENSE=""
WOLF_LICENSE_MD5=""
WOLFPKCS11_SRC ?= ""
WOLFPKCS11_SRC_SHA ?= ""
WOLFPKCS11_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFPKCS11_VERSION}"

BBFILE_PRIORITY='1'
