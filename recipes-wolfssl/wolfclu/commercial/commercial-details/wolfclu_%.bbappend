#Adjust these as needed
WOLFCLU_VERSION ?= ""

WOLF_LICENSE="WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLF_LICENSE_MD5="be28609dc681e98236c52428fadf04dd"
WOLFCLU_SRC ?= ""
WOLFCLU_SRC_SHA ?= ""
WOLFCLU_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFCLU_VERSION}"

BBFILE_PRIORITY='1'
