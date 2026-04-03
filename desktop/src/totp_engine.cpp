#include "totp_engine.h"
#include <openssl/hmac.h>
#include <cmath>
#include <cstring>
#include <ctime>
#include <stdexcept>

namespace AuthVault {

std::string TotpEngine::generate(const std::string& secret, uint64_t time) {
    if (time == 0) {
        time = static_cast<uint64_t>(std::time(nullptr));
    }
    
    uint64_t counter = time / 30;
    return generateHotp(reinterpret_cast<const uint8_t*>(secret.data()), 
                       secret.size(), counter, 6);
}

std::string TotpEngine::generateHotp(const uint8_t* key, size_t keyLen, uint64_t counter, int digits) {
    uint8_t counterBytes[8];
    for (int i = 7; i >= 0; --i) {
        counterBytes[i] = counter & 0xFF;
        counter >>= 8;
    }
    
    uint8_t hash[20];
    hmacSha1(key, keyLen, counterBytes, 8, hash);
    
    int offset = hash[19] & 0x0F;
    uint32_t binaryCode = ((hash[offset] & 0x7F) << 24) |
                         ((hash[offset + 1] & 0xFF) << 16) |
                         ((hash[offset + 2] & 0xFF) << 8) |
                         (hash[offset + 3] & 0xFF);
    
    uint32_t otp = binaryCode % static_cast<uint32_t>(std::pow(10, digits));
    
    char result[7];
    snprintf(result, sizeof(result), "%0*d", digits, otp);
    return std::string(result);
}

void TotpEngine::hmacSha1(const uint8_t* key, size_t keyLen, const uint8_t* data, size_t dataLen, uint8_t* out) {
    unsigned int len = 20;
    HMAC(EVP_sha1(), key, keyLen, data, dataLen, out, &len);
}

} // namespace AuthVault
