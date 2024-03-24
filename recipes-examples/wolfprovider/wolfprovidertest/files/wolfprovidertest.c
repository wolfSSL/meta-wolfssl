#include <stdio.h>
#include <stdlib.h>
#include <openssl/provider.h>
#include <openssl/err.h>

int main(void) {
    OSSL_PROVIDER *prov = OSSL_PROVIDER_load(NULL, "libwolfprov");
    if (!prov) {
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }
    printf("Custom provider 'libwolfprov' loaded successfully.\n");
    OSSL_PROVIDER_unload(prov);
    return 0;
}