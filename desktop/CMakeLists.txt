cmake_minimum_required(VERSION 3.14)
project(AuthVault VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(CMAKE_VERSION VERSION_LESS "3.7.0")
    set(CMAKE_INCLUDE_CURRENT_DIR ON)
endif()

find_package(Qt5 COMPONENTS Widgets REQUIRED)

add_executable(authvault
    src/main.cpp
    src/mainwindow.cpp
    src/totp_engine.cpp
    src/base32.cpp
)

target_link_libraries(authvault Qt5::Widgets)

install(TARGETS authvault DESTINATION bin)
