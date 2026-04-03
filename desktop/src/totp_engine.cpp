#include "totp_engine.h"
#include <openssl/hmac.h>
#include <cmath>
#include <cstring>
#include <ctime>
#include <stdexcept>
#include <cstdio>

namespace AuthVault {

const char* STEAM_ALPHABET = "23456789BCDFGHJKMNPQRTVWXY";

std::string TotpEngine::generateTOTP(const OtpParameters& params, uint64_t time) {
    if (time == 0) {
        time = static_cast<uint64_t>(std::time(nullptr));
    }
    
    uint64_t adjustedTime = time + params.offset;
    uint64_t counter = adjustedTime / params.period;
    
    OtpParameters hotpParams = params;
    hotpParams.counter = counter;
    
    return generateHOTP(hotpParams);
}

std::string TotpEngine::generateHOTP(const OtpParameters& params) {
    std::vector<uint8_t> decodedSecret(params.secret.begin(), params.secret.end());
    return generateHotpInternal(decodedSecret.data(), decodedSecret.size(), 
                               params.counter, params.digits, params.algorithm);
}

std::string TotpEngine::generateSteamGuard(const OtpParameters& params, uint64_t time) {
    if (time == 0) {
        time = static_cast<uint64_t>(std::time(nullptr));
    }
    
    uint64_t adjustedTime = time + params.offset;
    uint64_t counter = adjustedTime / 30;
    
    std::vector<uint8_t> decodedSecret(params.secret.begin(), params.secret.end());
    uint8_t counterBytes[8];
    for (int i = 7; i >= 0; --i) {
        counterBytes[i] = counter & 0xFF;
        counter >>= 8;
    }
    
    uint8_t hash[20];
    hmac(decodedSecret.data(), decodedSecret.size(), counterBytes, 8, hash, HashAlgorithm::SHA1);
    
    int offset = hash[19] & 0x0F;
    uint32_t fullCode = ((hash[offset] & 0x7F) << 24) |
                       ((hash[offset + 1] & 0xFF) << 16) |
                       ((hash[offset + 2] & 0xFF) << 8) |
                       (hash[offset + 3] & 0xFF);
    
    std::string result;
    for (int i = 0; i < 5; ++i) {
        result += STEAM_ALPHABET[fullCode % 26];
        fullCode /= 26;
    }
    
    return result;
}

int TotpEngine::getRemainingSeconds(int period, uint64_t time) {
    if (time == 0) {
        time = static_cast<uint64_t>(std::time(nullptr));
    }
    return period - (time % period);
}

std::string TotpEngine::generateHotpInternal(const uint8_t* key, size_t keyLen, uint64_t counter, 
                                             int digits, HashAlgorithm algorithm) {
    auto counterBytes = longToBytes(counter);
    
    int hashSize = 20;
    uint8_t hash[64]; // Max size for SHA512
    hmac(key, keyLen, counterBytes.data(), 8, hash, algorithm);
    
    int offset = hash[hashSize - 1] & 0x0F;
    uint32_t binaryCode = ((hash[offset] & 0x7F) << 24) |
                         ((hash[offset + 1] & 0xFF) << 16) |
                         ((hash[offset + 2] & 0xFF) << 8) |
                         (hash[offset + 3] & 0xFF);
    
    uint32_t otp = binaryCode % static_cast<uint32_t>(std::pow(10, digits));
    
    char result[9];
    snprintf(result, sizeof(result), "%0*d", digits, otp);
    return std::string(result);
}

void TotpEngine::hmac(const uint8_t* key, size_t keyLen, const uint8_t* data, size_t dataLen, 
                     uint8_t* out, HashAlgorithm algorithm) {
    unsigned int len = 20;
    const EVP_MD* md;
    
    switch (algorithm) {
        case HashAlgorithm::SHA1:
            md = EVP_sha1();
            len = 20;
            break;
        case HashAlgorithm::SHA256:
            md = EVP_sha256();
            len = 32;
            break;
        case HashAlgorithm::SHA512:
            md = EVP_sha512();
            len = 64;
            break;
        default:
            throw std::invalid_argument("Unknown hash algorithm");
    }
    
    HMAC(md, key, keyLen, data, dataLen, out, &len);
}

std::vector<uint8_t> TotpEngine::longToBytes(uint64_t value) {
    std::vector<uint8_t> result(8);
    for (int i = 7; i >= 0; --i) {
        result[i] = value & 0xFF;
        value >>= 8;
    }
    return result;
}

} // namespace AuthVault
