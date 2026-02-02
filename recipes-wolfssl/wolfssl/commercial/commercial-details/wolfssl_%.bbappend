#Adjust these as needed
WOLFSSL_VERSION ?= ""

WOLFSSL_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2024.pdf"
WOLFSSL_LICENSE_MD5 ?= "9b56a02d020e92a4bd49d0914e7d7db8"
WOLFSSL_SRC ?= ""
WOLFSSL_SRC_SHA ?= ""
WOLFSSL_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFSSL_VERSION}"

BBFILE_PRIORITY='1'
