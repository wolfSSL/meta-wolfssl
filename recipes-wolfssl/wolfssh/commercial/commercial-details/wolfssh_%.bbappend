#Adjust these as needed
WOLFSSH_VERSION ?= ""

WOLFSSH_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLFSSH_LICENSE_MD5 ?= "be28609dc681e98236c52428fadf04dd"
WOLFSSH_SRC ?= ""
WOLFSSH_SRC_SHA ?= ""
WOLFSSH_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFSSH_VERSION}"

BBFILE_PRIORITY='1'
