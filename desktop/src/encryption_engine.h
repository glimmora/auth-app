#ifndef ENCRYPTION_ENGINE_H
#define ENCRYPTION_ENGINE_H

#include <string>
#include <vector>
#include <cstdint>

namespace AuthVault {

struct EncryptedData {
    std::vector<uint8_t> ciphertext;
    std::vector<uint8_t> iv;
    std::vector<uint8_t> salt;
};

class EncryptionEngine {
public:
    static EncryptedData encryptAES256GCM(const std::vector<uint8_t>& plaintext, 
                                          const std::vector<uint8_t>& key);
    static std::vector<uint8_t> decryptAES256GCM(const EncryptedData& data, 
                                                 const std::vector<uint8_t>& key);
    
    static std::vector<uint8_t> deriveKeyPBKDF2(const std::string& password, 
                                                const std::vector<uint8_t>& salt,
                                                int iterations = 310000);
    
    static std::vector<uint8_t> generateRandomBytes(size_t length);
    
    static std::string toBase64(const std::vector<uint8_t>& data);
    static std::vector<uint8_t> fromBase64(const std::string& base64);
};

} // namespace AuthVault

#endif // ENCRYPTION_ENGINE_H
