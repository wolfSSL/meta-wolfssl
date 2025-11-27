# fips-image-minimal

Minimal demo image showcasing FIPS integration with libgcrypt, gnutls, and wolfProvider. All components use wolfSSL FIPS as their cryptographic backend.

## Configuration

In `build/conf/local.conf`:

```bitbake
WOLFSSL_DEMOS = "fips-image-minimal"
require /path/to/meta-wolfssl/conf/wolfssl-fips.conf
```

Build:

```bash
bitbake fips-image-minimal
```

Run in QEMU:

```bash
runqemu fips-image-minimal nographic
```

## Testing

### 1. Testing libgcrypt

libgcrypt is a cryptographic library that provides low-level cryptographic primitives. In this image, it's configured to use wolfSSL FIPS as its backend.

**How the testing works:**

The libgcrypt package includes a ptest suite that exercises all cryptographic functions. When you run the tests, they call libgcrypt's API, which internally uses the wolfSSL FIPS backend. The tests verify that all cryptographic algorithms work correctly, key generation produces valid keys, encryption/decryption operations succeed, hash functions produce correct outputs, and digital signatures can be created and verified.

**Run libgcrypt tests:**

```bash
ptest-runner libgcrypt
```

**Expected Output:**

```
START: ptest-runner
BEGIN: /usr/lib/libgcrypt/ptest
PASS: basic
PASS: mpitests
PASS: t-mpi-bit
PASS: curves
PASS: fips186-dsa
...
END: /usr/lib/libgcrypt/ptest
STOP: ptest-runner
```

All tests should pass, confirming that libgcrypt is correctly using the wolfSSL FIPS backend.

**Verify library linking:**

```bash
ldd /usr/lib/libgcrypt.so.20
readelf -d /usr/lib/libgcrypt.so.20 | grep NEEDED
```

You should see `libwolfssl` in the dependency list.

**Library locations:**
- Main library: `/usr/lib/libgcrypt.so.20`
- Development library: `/usr/lib/libgcrypt.so` (symlink)

### 2. Testing gnutls

gnutls is a TLS/SSL library that implements secure communication protocols. In this image, it's configured to use wolfSSL FIPS as its cryptographic backend through the `wolfssl-gnutls-wrapper`, which intercepts gnutls cryptographic calls and routes them to wolfSSL.

**How the testing works:**

The gnutls test suite in `/opt/wolfssl-gnutls-wrapper/tests/` performs various TLS/SSL operations including TLS handshake establishment, certificate validation, cipher suite negotiation, data encryption/decryption over TLS connections, and key exchange operations. When these tests run, gnutls makes cryptographic calls that are intercepted by the wrapper and forwarded to wolfSSL FIPS. The wrapper logs all cryptographic operations, allowing you to see exactly when and how wolfSSL is being used.

**Run gnutls tests:**

**Note:** The RAM needs to be increased for tests to pass. Ensure QEMU has sufficient memory allocated.

```bash
cd /opt/wolfssl-gnutls-wrapper/tests/
make run_fips
```

**Expected Output:**

The test suite will run various TLS/SSL operations and print ✔️/❌ for each test, followed by a summary. All tests should pass, confirming that gnutls is correctly using the wolfSSL FIPS backend. You'll see wrapper log messages showing cryptographic operations being routed to wolfSSL.

**Verify library linking:**

The main gnutls library doesn't directly link to wolfSSL. Instead, the wrapper library links to both gnutls and wolfSSL:

```bash
ldd /opt/wolfssl-gnutls-wrapper/lib/libgnutls-wolfssl-wrapper.so
```

You should see both `libgnutls.so.30` and `libwolfssl.so.44` in the dependency list, confirming the wrapper links to both libraries.

**Library locations:**
- Main gnutls library: `/usr/lib/libgnutls.so.30`
- Development library: `/usr/lib/libgnutls.so` (symlink)
- Wrapper library: `/opt/wolfssl-gnutls-wrapper/lib/libgnutls-wolfssl-wrapper.so`
- Additional gnutls libraries: `/usr/lib/libgnutls-openssl.so.27`, `/usr/lib/libgnutls-dane.so.0`

### 3. Testing wolfProvider

**TODO:** Add testing instructions for wolfProvider.
