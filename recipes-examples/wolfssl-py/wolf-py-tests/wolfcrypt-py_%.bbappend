WOLFCRYPT_PY_TEST_DIR = "${S}/*"                                                
WOLFCRYPT_PY_TEST_TARGET_DIR = "${D}/home/root/wolf-py-tests/wolfcrypt-py-test"

do_install:append() {
    bbnote "Installing wolfCrypt-py tests"                                     
    install -m 0755 -d ${WOLFCRYPT_PY_TEST_TARGET_DIR}                      
    cp -r ${WOLFCRYPT_PY_TEST_DIR}/* ${WOLFCRYPT_PY_TEST_TARGET_DIR}        
}

# Python Specific option
export PYTHONDONTWRITEBYTECODE = "1" 

FILES:${PN} += "  /home/root/wolf-py-tests/wolfcrypt-py-test/*"
