/* engine_by_id_example.c
 *
 * Copyright (C) 2019-2023 wolfSSL Inc.
 *
 * This file is part of wolfengine.
 *
 * wolfengine is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * wolfengine is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1335, USA
 */

#include <stdio.h>

#include <openssl/engine.h>

/* From https://www.openssl.org/docs/man3.0/man3/EVP_MD_CTX_new.html:
 *
 * The EVP_MD_CTX_create() and EVP_MD_CTX_destroy() functions were renamed to
 * EVP_MD_CTX_new() and EVP_MD_CTX_free() in OpenSSL 1.1.0, respectively.
 */
#if OPENSSL_VERSION_NUMBER < 0x10100000L
    #define EVP_MD_CTX_new  EVP_MD_CTX_create
    #define EVP_MD_CTX_free EVP_MD_CTX_destroy
#endif

int main()
{
    ENGINE* wolfEngine = NULL;
#if OPENSSL_VERSION_NUMBER >= 0x10100000L
    const char* engineID = "libwolfengine";
#else
    const char* engineID = "wolfengine";
#endif
    unsigned char someData[] = {0xDE, 0xAD, 0xBE, 0xEF};
    unsigned char digest[SHA256_DIGEST_LENGTH];
    unsigned int digestBufLen = sizeof(digest);
    EVP_MD_CTX *ctx;
    const EVP_MD* sha256 = EVP_sha256();
    const EVP_MD* md5 = EVP_md5();

    /*
     * Load OpenSSL's "dynamic" engine. This is an engine that loads other
     * engines at runtime. It's used implicitly below to load wolfEngine.
     */
    ENGINE_load_dynamic();

    /* 
     * Load wolfEngine. libwolfengine.so must be located in the directory
     * pointed to by environment variable OPENSSL_ENGINES for this to succeed.
     * For example, if you just ran "make" in the wolfEngine source code
     * directory, .libs/ should contain libwolfengine.so.
     */
    wolfEngine = ENGINE_by_id(engineID);
    if (wolfEngine == NULL) {
        fprintf(stderr, "ENGINE_by_id failed.\n");
        return -1;
    }

    /*
     * Turn on wolfEngine debug messages. These will print to stderr.
     */
    if (ENGINE_ctrl_cmd(wolfEngine, "enable_debug", 1, NULL, NULL, 0) != 1) {
        fprintf(stderr, "ENGINE_ctrl_cmd enable_debug failed.\n");
        return -1;
    }

    /* 
     * Make wolfEngine the default engine for all algorithms it supports.
     */
    ENGINE_set_default(wolfEngine, ENGINE_METHOD_ALL);

    /*
     * Compute a digest/hash over the data in the "someData" buffer. wolfEngine
     * provides SHA-256, and since it's the default engine for everything it
     * provides, we should see wolfEngine debug messages print out. If you
     * don't see those messages, make sure wolfEngine was built with
     * --enable-debug (-DWOLFENGINE_DEBUG).
     */
    if ((ctx = EVP_MD_CTX_new()) == NULL) {
        fprintf(stderr, "EVP_MD_CTX_new SHA-256 failed.\n");
        return -1;
    }
    if (EVP_DigestInit(ctx, sha256) != 1) {
        fprintf(stderr, "EVP_DigestInit SHA-256 failed.\n");
        return -1;
    }
    if (EVP_DigestUpdate(ctx, someData, sizeof(someData)) != 1) {
        fprintf(stderr, "EVP_DigestUpdate SHA-256 failed.\n");
        return -1;
    }
    if (EVP_DigestFinal_ex(ctx, digest, &digestBufLen) != 1) {
        fprintf(stderr, "EVP_DigestFinal_ex SHA-256 failed.\n");
        return -1;
    }

    EVP_MD_CTX_free(ctx);

    /*
     * MD5 is not considered a secure hash algorithm and isn't FIPS-approved.
     * wolfEngine doesn't provide support for it. The digest computation below
     * shouldn't print any wolfEngine debug messages. It will be handled by
     * OpenSSL's non-FIPS-verified MD5 implementation.
     */
    if ((ctx = EVP_MD_CTX_new()) == NULL) {
        fprintf(stderr, "EVP_MD_CTX_new MD5 failed.\n");
        return -1;
    }
    if (EVP_DigestInit(ctx, md5) != 1) {
        fprintf(stderr, "EVP_DigestInit MD5 failed.\n");
        return -1;
    }
    if (EVP_DigestUpdate(ctx, someData, sizeof(someData)) != 1) {
        fprintf(stderr, "EVP_DigestUpdate MD5 failed.\n");
        return -1;
    }
    if (EVP_DigestFinal_ex(ctx, digest, &digestBufLen) != 1) {
        fprintf(stderr, "EVP_DigestFinal_ex MD5 failed.\n");
        return -1;
    }

    EVP_MD_CTX_free(ctx);

    ENGINE_free(wolfEngine);

    printf("Everything worked!\n");

    return 0;
}