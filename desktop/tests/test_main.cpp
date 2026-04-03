#include <gtest/gtest.h>
#include "src/totp_engine.h"
#include "src/base32.h"

TEST(TotpTest, GeneratesValidCode) {
    std::string secret = "JBSWY3DPEHPK3PXP";
    std::string code = AuthVault::TotpEngine::generate(secret, 1000);
    EXPECT_EQ(code.length(), 6);
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
