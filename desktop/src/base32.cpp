#include "base32.h"
#include <stdexcept>
#include <algorithm>
#include <cctype>

namespace AuthVault {

const std::string Base32::BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

std::vector<uint8_t> Base32::decode(const std::string& encoded) {
    std::string upperEncoded = encoded;
    std::transform(upperEncoded.begin(), upperEncoded.end(), upperEncoded.begin(), ::toupper);
    upperEncoded.erase(std::remove(upperEncoded.begin(), upperEncoded.end(), '='), upperEncoded.end());
    
    uint64_t buffer = 0;
    int bitsLeft = 0;
    std::vector<uint8_t> result;
    
    for (char c : upperEncoded) {
        size_t index = BASE32_CHARS.find(c);
        if (index == std::string::npos) {
            throw std::invalid_argument("Invalid Base32 character: " + std::string(1, c));
        }
        buffer = (buffer << 5) | index;
        bitsLeft += 5;
        if (bitsLeft >= 8) {
            bitsLeft -= 8;
            result.push_back(static_cast<uint8_t>(buffer >> bitsLeft));
        }
    }
    
    return result;
}

} // namespace AuthVault
