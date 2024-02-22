WOLFSSL_PY_TEST_DIR = "${S}/*"                                                  
WOLFSSL_PY_TEST_TARGET_DIR = "${D}/home/root/wolf-py-tests/wolfssl-py-test"

do_install:append() {                                                            
    bbnote "Installing wolfssl-py Tests"                                    
    install -m 0755 -d ${WOLFSSL_PY_TEST_TARGET_DIR}                        
    cp -r ${WOLFSSL_PY_TEST_DIR}/* ${WOLFSSL_PY_TEST_TARGET_DIR}            
}       

# Python Specific option                                                        
export PYTHONDONTWRITEBYTECODE = "1" 

FILES:${PN} += " /home/root/wolf-py-tests/wolfssl-py-test/* "
