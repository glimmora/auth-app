#include <gtest/gtest.h>
#include "../src/totp_engine.h"
#include "../src/base32.h"
#include "../src/encryption_engine.h"

TEST(TotpTest, GeneratesValidCode) {
    AuthVault::OtpParameters params;
    params.secret = "JBSWY3DPEHPK3PXP";
    params.algorithm = AuthVault::HashAlgorithm::SHA1;
    params.digits = 6;
    params.period = 30;
    
    std::string code = AuthVault::TotpEngine::generateTOTP(params, 1000);
    EXPECT_EQ(code.length(), 6);
}

TEST(SteamGuardTest, GeneratesAlphanumericCode) {
    AuthVault::OtpParameters params;
    params.secret = "JBSWY3DPEHPK3PXP";
    
    std::string code = AuthVault::TotpEngine::generateSteamGuard(params, 1000);
    EXPECT_EQ(code.length(), 5);
}

TEST(EncryptionTest, EncryptDecrypt) {
    std::vector<uint8_t> key = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
                                 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
                                 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f};
    
    std::vector<uint8_t> plaintext = {0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64};
    
    auto encrypted = AuthVault::EncryptionEngine::encryptAES256GCM(plaintext, key);
    auto decrypted = AuthVault::EncryptionEngine::decryptAES256GCM(encrypted, key);
    
    EXPECT_EQ(plaintext, decrypted);
}

TEST(Base32Test, DecodesCorrectly) {
    std::string encoded = "JBSWY3DPEHPK3PXP";
    auto decoded = AuthVault::Base32::decode(encoded);
    EXPECT_FALSE(decoded.empty());
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
