cmake_minimum_required(VERSION 3.20)
project(LunaPikafish LANGUAGES CXX)

find_package(Threads REQUIRED)

file(GLOB_RECURSE PIKAFISH_SOURCES CONFIGURE_DEPENDS Vendor/src/*.cpp)
list(FILTER PIKAFISH_SOURCES EXCLUDE REGEX "/main\\.cpp$")
list(FILTER PIKAFISH_SOURCES EXCLUDE REGEX "/universal/")

add_library(luna_pikafish STATIC ${PIKAFISH_SOURCES} Bridge/LunaPikafish.cpp)
target_compile_features(luna_pikafish PUBLIC cxx_std_17)
target_include_directories(luna_pikafish PUBLIC Bridge PRIVATE Vendor/src)
target_compile_definitions(luna_pikafish PRIVATE NNUE_EMBEDDING_OFF=1 ZSTD_DISABLE_ASM=1)
target_link_libraries(luna_pikafish PUBLIC Threads::Threads)
set_target_properties(luna_pikafish PROPERTIES POSITION_INDEPENDENT_CODE ON)

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    target_compile_definitions(luna_pikafish PRIVATE IS_64BIT)
endif()
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|aarch64|ARM64)$")
    target_compile_definitions(luna_pikafish PRIVATE USE_NEON=8 USE_POPCNT)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64|amd64)$")
    target_compile_definitions(luna_pikafish PRIVATE USE_SSE2)
endif()

option(LUNA_PIKAFISH_BUILD_SMOKE "Build the portable bridge integration check" ON)
if(LUNA_PIKAFISH_BUILD_SMOKE)
    enable_testing()
    add_executable(luna_pikafish_smoke Tests/bridge_smoke.cpp)
    target_link_libraries(luna_pikafish_smoke PRIVATE luna_pikafish)
    add_test(NAME pikafish_bridge
        COMMAND luna_pikafish_smoke "${CMAKE_CURRENT_SOURCE_DIR}/Resources/pikafish.nnue")
    set_tests_properties(pikafish_bridge PROPERTIES TIMEOUT 60)
endif()
