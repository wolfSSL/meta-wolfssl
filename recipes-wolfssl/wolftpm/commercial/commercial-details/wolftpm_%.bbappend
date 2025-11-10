#Adjust these as needed
WOLFTPM_VERSION ?= ""

WOLFTPM_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLFTPM_LICENSE_MD5 ?= "be28609dc681e98236c52428fadf04dd"
WOLFTPM_SRC ?= ""
WOLFTPM_SRC_SHA ?= ""
WOLFTPM_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFTPM_VERSION}"

BBFILE_PRIORITY='1'
