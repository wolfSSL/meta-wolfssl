#Adjust these as needed
WOLFCLU_VERSION ?= ""

WOLFCLU_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLFCLU_LICENSE_MD5 ?= "be28609dc681e98236c52428fadf04dd"
WOLFCLU_SRC ?= ""
WOLFCLU_SRC_SHA ?= ""
WOLFCLU_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFCLU_VERSION}"

BBFILE_PRIORITY='1'
