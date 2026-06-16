cmake_minimum_required(VERSION 3.22.1)
project("pty_bridge")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(pty_bridge SHARED
    pty_bridge.c
)

target_include_directories(pty_bridge PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(pty_bridge
    log
    pthread
)

# استخدام NDK للبناء
find_library(log-lib log)
target_link_libraries(pty_bridge ${log-lib})
