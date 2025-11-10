#Adjust these as needed
WOLFMQTT_VERSION ?= ""

WOLF_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2024.pdf"
WOLF_LICENSE_MD5 ?= "9b56a02d020e92a4bd49d0914e7d7db8"
WOLFMQTT_SRC ?= ""
WOLFMQTT_SRC_SHA ?= ""
WOLFMQTT_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFMQTT_VERSION}"

BBFILE_PRIORITY='1'
