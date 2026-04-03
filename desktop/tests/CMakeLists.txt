cmake_minimum_required(VERSION 3.14)
project(AuthVaultTests)

set(CMAKE_CXX_STANDARD 17)

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

add_executable(authvault_tests
    test_main.cpp
    ../src/totp_engine.cpp
    ../src/base32.cpp
)

target_include_directories(authvault_tests PRIVATE ${CMAKE_SOURCE_DIR}/..)

find_package(OpenSSL REQUIRED)
target_link_libraries(authvault_tests GTest::gtest_main OpenSSL::Crypto)

include(GoogleTest)
gtest_discover_tests(authvault_tests)
