# wolfHSM (Yocto/OE recipe)

Stages [wolfHSM](https://github.com/wolfSSL/wolfHSM) sources and headers into
the sysroot so other recipes can compile them into their own binaries.

## Recipes

| Recipe | Purpose |
|---|---|
| `wolfhsm_git.bb` | Stages `wolfhsm/` (headers), `src/` and the selected `port/` directories to `${datadir}/wolfhsm`, plus a `wolfhsm.mk` build fragment. Also installs the headers at `${includedir}/wolfhsm`. |

## Why this stages source instead of building a library

wolfHSM is configured by the application that uses it. `wolfhsm/wh_settings.h`
does `#include "wolfhsm_cfg.h"` whenever `WOLFHSM_CFG` is defined, and that
header selects the transport, the NVM backend, buffer sizes, whether crypto is
compiled in at all, and much else besides. Two consumers with different
`wolfhsm_cfg.h` files do not share an ABI, so there is no single `libwolfhsm`
that would be correct to ship.

wolfHSM also has no build system to drive: its top-level `Makefile` only
recurses into `test/`, `benchmark/`, `tools/` and `examples/`, each of which
brings its own `wolfhsm_cfg.h`. Upstream expects you to compile `src/*.c` and
one `port/*/` directory directly into your application. This recipe makes that
possible from a Yocto build without vendoring a checkout.

## Consuming it from a recipe

```bitbake
DEPENDS += "wolfhsm"

do_compile() {
    oe_runmake WOLFHSM_DIR="${STAGING_DATADIR}/wolfhsm"
}
```

Your Makefile then compiles `$(WOLFHSM_DIR)/src/*.c` and
`$(WOLFHSM_DIR)/port/posix/*.c` with `-I$(WOLFHSM_DIR) -DWOLFHSM_CFG` and an
include path pointing at your own `wolfhsm_cfg.h`.

Alternatively, include the staged fragment and use the variables it defines:

```make
include $(WOLFHSM_DIR)/wolfhsm.mk
CFLAGS += $(WOLFHSM_INC) -DWOLFHSM_CFG -I$(MY_CONFIG_DIR)
SRC    += $(WOLFHSM_SRC) $(WOLFHSM_PORT_SRC)
```

`wolfhsm.mk` resolves `WOLFHSM_DIR` from its own location, so it works
unchanged from a recipe sysroot, an SDK sysroot, or a plain copy.

## Selecting ports

wolfHSM ships ports for `posix`, `skeleton`, `microchip`, `infineon`,
`stmicro`, `renesas` and `ti`. Only `posix` is staged by default; staging all
of them would put a lot of unrelated vendor code in every sysroot. Override in
`local.conf` or a bbappend:

```bitbake
WOLFHSM_PORTS = "posix infineon"
```

Naming a port that does not exist in the source tree is a `bbfatal` rather
than a silent no-op.

## Packaging

Everything lands in `wolfhsm-dev`; `FILES:${PN}` is explicitly emptied so the
default `${datadir}/${BPN}` claim cannot pull the staging directory into a
runtime package. wolfHSM source is a build input, not a runtime artifact, and
should never appear in a target rootfs. `RDEPENDS:${PN}-dev` is cleared for the
same reason: bitbake's default would make `wolfhsm-dev` depend on a runtime
`wolfhsm` package that is deliberately never produced.

To cross-compile a wolfHSM consumer from an SDK, have the consumer's own `-dev`
package pull the headers in:

```bitbake
RDEPENDS:${PN}-dev += "wolfhsm-dev"
```

or, if there is no such consumer package, add it to the SDK directly:

```bitbake
TOOLCHAIN_TARGET_TASK:append = " wolfhsm-dev"
```

## Pinning

`SRCREV` is pinned in `wolfhsm.inc`. Override per-build with:

```bitbake
SRCREV:pn-wolfhsm = "<sha>"
```
