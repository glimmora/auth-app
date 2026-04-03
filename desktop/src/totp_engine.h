#ifndef TOTP_ENGINE_H
#define TOTP_ENGINE_H

#include <string>
#include <cstdint>

namespace AuthVault {

class TotpEngine {
public:
    static std::string generate(const std::string& secret, uint64_t time = 0);
    
private:
    static std::string generateHotp(const uint8_t* key, size_t keyLen, uint64_t counter, int digits);
    static void hmacSha1(const uint8_t* key, size_t keyLen, const uint8_t* data, size_t dataLen, uint8_t* out);
    static uint64_t bytesToUint64(const uint8_t* bytes);
};

} // namespace AuthVault

#endif // TOTP_ENGINE_H
