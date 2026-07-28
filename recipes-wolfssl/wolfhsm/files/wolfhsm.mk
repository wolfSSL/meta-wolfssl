## wolfhsm.mk - build fragment for consumers of the staged wolfHSM sources.
##
## wolfHSM has no build system of its own; it is compiled into the application
## that supplies wolfhsm_cfg.h. Include this fragment to get the source lists
## and include paths for doing that:
##
##     include $(SDKTARGETSYSROOT)/usr/share/wolfhsm/wolfhsm.mk
##     CFLAGS += $(WOLFHSM_INC) -DWOLFHSM_CFG -I$(MY_CONFIG_DIR)
##     SRC    += $(WOLFHSM_SRC) $(WOLFHSM_PORT_SRC)
##
## $(MY_CONFIG_DIR) must contain your wolfhsm_cfg.h. -DWOLFHSM_CFG is what
## makes wolfhsm/wh_settings.h include it.

# Resolved from this fragment's own location, so it is correct whether it is
# read out of a recipe sysroot, an SDK sysroot, or a plain copy.
WOLFHSM_DIR      ?= $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

# Which platform port to compile. Only ports listed in WOLFHSM_PORTS at
# recipe-build time are present here.
WOLFHSM_PORT     ?= posix
WOLFHSM_PORT_DIR ?= $(WOLFHSM_DIR)/port/$(WOLFHSM_PORT)

WOLFHSM_SRC      := $(wildcard $(WOLFHSM_DIR)/src/*.c)
WOLFHSM_PORT_SRC := $(wildcard $(WOLFHSM_PORT_DIR)/*.c)
WOLFHSM_INC      := -I$(WOLFHSM_DIR) -I$(WOLFHSM_PORT_DIR)
