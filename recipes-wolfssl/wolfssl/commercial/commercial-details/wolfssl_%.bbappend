#Adjust these as needed
WOLFSSL_VERSION ?= ""

WOLFSSL_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLFSSL_LICENSE_MD5 ?= "be28609dc681e98236c52428fadf04dd"
WOLFSSL_SRC ?= ""
WOLFSSL_SRC_SHA ?= ""
WOLFSSL_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFSSL_VERSION}"

BBFILE_PRIORITY='1'
