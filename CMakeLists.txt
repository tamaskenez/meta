cmake_minimum_required(VERSION 3.1)
set(CMAKE_LEGACY_CYGWIN_WIN32 0)

project(Meta CXX)

enable_testing()

option(META_ENABLE_TEST "Build tests, examples" ON)
option(META_CUSTOM_CXX_FLAGS "Set custom CXX flags for gcc and clang" ON)
option(META_ENABLE_LIBRARY "If OFF, import meta with find_package instead of using from build tree" ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_DEBUG_POSTFIX _d)

if(META_CUSTOM_CXX_FLAGS)
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11 -Wno-unused-function -ftemplate-backtrace-limit=0 -Wdocumentation")
    set(CMAKE_CXX_FLAGS_DEBUG "-O0 -fno-inline -g3 -fstack-protector-all")
    set(CMAKE_CXX_FLAGS_RELEASE "-Ofast -g0 -march=native -mtune=native -DNDEBUG")
  elseif(CMAKE_COMPILER_IS_GNUCXX)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++11 -Wno-unused-function")
  endif()
endif()

if(META_ENABLE_LIBRARY)
  add_library(meta INTERFACE)
  target_include_directories(meta INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
    )
  install(TARGETS meta EXPORT meta-targets)
  install(EXPORT meta-targets FILE meta-config.cmake DESTINATION share/cmake/meta)
  install(DIRECTORY include/meta DESTINATION include)
endif()

if(BIICODE)
    ADD_BIICODE_TARGETS()

    string(REPLACE " " ";" TARGET_CXX_FLAGS         ${CMAKE_CXX_FLAGS})
    string(REPLACE " " ";" TARGET_CXX_FLAGS_DEBUG   ${CMAKE_CXX_FLAGS_DEBUG})
    string(REPLACE " " ";" TARGET_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})     

    target_compile_options(${BII_LIB_TARGET} INTERFACE ${TARGET_CXX_FLAGS}
                           $<$<CONFIG:Debug>:${TARGET_CXX_FLAGS_DEBUG}>
                           $<$<CONFIG:Release>:${TARGET_CXX_FLAGS_RELEASE}>)

    return()
endif()

add_subdirectory(doc)

if(META_ENABLE_TEST)
  if(NOT TARGET meta)
    find_package(meta REQUIRED)
  endif()
  link_libraries(meta)
  add_subdirectory(example)
  add_subdirectory(test)
endif()

if(EXISTS "${CMAKE_SOURCE_DIR}/scratch")
    add_subdirectory(scratch)
endif()
