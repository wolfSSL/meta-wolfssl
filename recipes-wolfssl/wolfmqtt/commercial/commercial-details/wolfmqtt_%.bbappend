#Adjust these as needed
WOLFMQTT_VERSION ?= ""

WOLFMQTT_LICENSE ?= "WolfSSL_LicenseAgmt_JAN-2022.pdf"
WOLFMQTT_LICENSE_MD5 ?= "be28609dc681e98236c52428fadf04dd"
WOLFMQTT_SRC ?= ""
WOLFMQTT_SRC_SHA ?= ""
WOLFMQTT_SRC_PASS ?= ""

#Do not adjust these variables
PR = "commercial"
PV = "${WOLFMQTT_VERSION}"

BBFILE_PRIORITY='1'
