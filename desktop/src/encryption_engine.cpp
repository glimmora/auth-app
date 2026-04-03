#include "encryption_engine.h"
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/sha.h>
#include <stdexcept>
#include <vector>

namespace AuthVault {

const size_t KEY_SIZE = 32;
const size_t IV_SIZE = 12;
const size_t TAG_SIZE = 16;
const size_t SALT_SIZE = 16;

EncryptedData EncryptionEngine::encryptAES256GCM(const std::vector<uint8_t>& plaintext, 
                                                  const std::vector<uint8_t>& key) {
    if (key.size() != KEY_SIZE) {
        throw std::invalid_argument("Key must be 256 bits");
    }
    
    EncryptedData result;
    result.iv = generateRandomBytes(IV_SIZE);
    
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) throw std::runtime_error("Failed to create cipher context");
    
    if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, key.data(), result.iv.data())) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Failed to initialize encryption");
    }
    
    std::vector<uint8_t> ciphertext(plaintext.size() + TAG_SIZE);
    int outlen;
    
    if (1 != EVP_EncryptUpdate(ctx, ciphertext.data(), &outlen, 
                               plaintext.data(), plaintext.size())) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Encryption failed");
    }
    
    int ciphertext_len = outlen;
    
    if (1 != EVP_EncryptFinal_ex(ctx, ciphertext.data() + outlen, &outlen)) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Encryption finalization failed");
    }
    ciphertext_len += outlen;
    
    std::vector<uint8_t> tag(TAG_SIZE);
    if (1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, TAG_SIZE, tag.data())) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Failed to get authentication tag");
    }
    
    EVP_CIPHER_CTX_free(ctx);
    
    ciphertext.resize(ciphertext_len);
    ciphertext.insert(ciphertext.end(), tag.begin(), tag.end());
    result.ciphertext = ciphertext;
    
    return result;
}

std::vector<uint8_t> EncryptionEngine::decryptAES256GCM(const EncryptedData& data, 
                                                         const std::vector<uint8_t>& key) {
    if (key.size() != KEY_SIZE) {
        throw std::invalid_argument("Key must be 256 bits");
    }
    
    if (data.ciphertext.size() < TAG_SIZE) {
        throw std::invalid_argument("Ciphertext too short");
    }
    
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) throw std::runtime_error("Failed to create cipher context");
    
    if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_gcm(), NULL, key.data(), data.iv.data())) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Failed to initialize decryption");
    }
    
    size_t ciphertext_len = data.ciphertext.size() - TAG_SIZE;
    std::vector<uint8_t> ciphertext(data.ciphertext.begin(), 
                                    data.ciphertext.begin() + ciphertext_len);
    std::vector<uint8_t> tag(data.ciphertext.begin() + ciphertext_len, data.ciphertext.end());
    
    std::vector<uint8_t> plaintext(ciphertext_len);
    int outlen;
    
    if (1 != EVP_DecryptUpdate(ctx, plaintext.data(), &outlen, 
                               ciphertext.data(), ciphertext_len)) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Decryption failed");
    }
    
    int plaintext_len = outlen;
    
    if (1 != EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_TAG, TAG_SIZE, tag.data())) {
        EVP_CIPHER_CTX_free(ctx);
        throw std::runtime_error("Failed to set authentication tag");
    }
    
    int result = EVP_DecryptFinal_ex(ctx, plaintext.data() + outlen, &outlen);
    EVP_CIPHER_CTX_free(ctx);
    
    if (result != 1) {
        throw std::runtime_error("Authentication failed - invalid tag or key");
    }
    
    plaintext_len += outlen;
    plaintext.resize(plaintext_len);
    
    return plaintext;
}

std::vector<uint8_t> EncryptionEngine::deriveKeyPBKDF2(const std::string& password, 
                                                        const std::vector<uint8_t>& salt,
                                                        int iterations) {
    std::vector<uint8_t> key(KEY_SIZE);
    
    if (1 != PKCS5_PBKDF2_HMAC(password.c_str(), password.size(),
                                salt.data(), salt.size(), iterations,
                                EVP_sha256(), KEY_SIZE, key.data())) {
        throw std::runtime_error("PBKDF2 key derivation failed");
    }
    
    return key;
}

std::vector<uint8_t> EncryptionEngine::generateRandomBytes(size_t length) {
    std::vector<uint8_t> bytes(length);
    if (1 != RAND_bytes(bytes.data(), length)) {
        throw std::runtime_error("Failed to generate random bytes");
    }
    return bytes;
}

std::string EncryptionEngine::toBase64(const std::vector<uint8_t>& data) {
    if (data.empty()) return "";
    
    size_t encoded_len = 4 * ((data.size() + 2) / 3);
    std::string encoded(encoded_len, '\0');
    
    EVP_EncodeBlock(reinterpret_cast<unsigned char*>(&encoded[0]), 
                    data.data(), data.size());
    
    return encoded;
}

std::vector<uint8_t> EncryptionEngine::fromBase64(const std::string& base64) {
    if (base64.empty()) return {};
    
    size_t decoded_len = (base64.size() / 4) * 3;
    std::vector<uint8_t> decoded(decoded_len);
    
    int len = EVP_DecodeBlock(decoded.data(), 
                              reinterpret_cast<const unsigned char*>(base64.c_str()), 
                              base64.size());
    
    if (len < 0) throw std::runtime_error("Base64 decoding failed");
    decoded.resize(len);
    
    return decoded;
}

} // namespace AuthVault
