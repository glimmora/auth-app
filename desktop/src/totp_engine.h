#ifndef TOTP_ENGINE_H
#define TOTP_ENGINE_H

#include <string>
#include <cstdint>
#include <vector>

namespace AuthVault {

enum class HashAlgorithm {
    SHA1,
    SHA256,
    SHA512
};

struct OtpParameters {
    std::string secret;
    HashAlgorithm algorithm = HashAlgorithm::SHA1;
    int digits = 6;
    int period = 30;
    uint64_t counter = 0;
    int offset = 0;
};

class TotpEngine {
public:
    static std::string generateTOTP(const OtpParameters& params, uint64_t time = 0);
    static std::string generateHOTP(const OtpParameters& params);
    static std::string generateSteamGuard(const OtpParameters& params, uint64_t time = 0);
    static int getRemainingSeconds(int period = 30, uint64_t time = 0);
    
private:
    static std::string generateHotpInternal(const uint8_t* key, size_t keyLen, uint64_t counter, 
                                           int digits, HashAlgorithm algorithm);
    static void hmac(const uint8_t* key, size_t keyLen, const uint8_t* data, size_t dataLen, 
                     uint8_t* out, HashAlgorithm algorithm);
    static std::vector<uint8_t> longToBytes(uint64_t value);
};

} // namespace AuthVault

#endif // TOTP_ENGINE_H
