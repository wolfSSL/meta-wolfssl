#Adjust these as needed
WOLFENGINE_VERSION ?= ""

WOLF_LICENSE="WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLF_LICENSE_MD5="be28609dc681e98236c52428fadf04dd"
WOLFENGINE_SRC ?= ""
WOLFENGINE_SRC_SHA ?= ""
WOLFENGINE_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFENGINE_VERSION}"

BBFILE_PRIORITY='1'