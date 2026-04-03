#ifndef BASE32_H
#define BASE32_H

#include <string>
#include <vector>
#include <cstdint>

namespace AuthVault {

class Base32 {
public:
    static std::vector<uint8_t> decode(const std::string& encoded);
    
private:
    static const std::string BASE32_CHARS;
};

} // namespace AuthVault

#endif // BASE32_H
