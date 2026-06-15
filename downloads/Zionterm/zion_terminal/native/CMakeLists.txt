# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                         Zion OS Terminal                                   ║
# ║                    CMake Build Configuration                              ║
# ║                                                                            ║
# ║  Author: MiniMax Agent                                                     ║
# ║  Version: 1.0.0                                                            ║
# ║  Description: ملف تكوين CMake لبناء المكتبات الأصلية                       ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

cmake_minimum_required(VERSION 3.18.1)

project(zion_terminal_native LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# ═══════════════════════════════════════════════════════════════════════════
#                      إعدادات البناء
# ═══════════════════════════════════════════════════════════════════════════

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

# ═══════════════════════════════════════════════════════════════════════════
#                      المكتبات المطلوبة
# ═══════════════════════════════════════════════════════════════════════════

find_library(ANDROID log-lib log)
find_library(ANDROID bionic-lib bionic)
find_library(ANDROID utils-lib utils)
find_library(ANDROID android-lib android)

# ═══════════════════════════════════════════════════════════════════════════
#                      PTY Handler
# ═══════════════════════════════════════════════════════════════════════════

add_library(
    pty_handler
    SHARED
    pty_handler.c
)

target_link_libraries(
    pty_handler
    ${ANDROID log-lib}
    ${ANDROID bionic-lib}
    ${ANDROID utils-lib}
)

target_include_directories(
    pty_handler
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# ═══════════════════════════════════════════════════════════════════════════
#                      إعدادات إضافية
# ═══════════════════════════════════════════════════════════════════════════

set_target_properties(
    pty_handler
    PROPERTIES
    LINKER_LANGUAGE C
    POSITION_INDEPENDENT_CODE ON
)

# ═══════════════════════════════════════════════════════════════════════════
#                      تصحيح الأخطاء
# ═══════════════════════════════════════════════════════════════════════════

if(CMAKE_BUILD_TYPE MATCHES Debug)
    target_compile_options(pty_handler PRIVATE -g -O0 -Wall -Wextra)
else()
    target_compile_options(pty_handler PRIVATE -O2 -Wall -Wextra)
endif()

# ═══════════════════════════════════════════════════════════════════════════
#                      نهاية الملف
# ═══════════════════════════════════════════════════════════════════════════