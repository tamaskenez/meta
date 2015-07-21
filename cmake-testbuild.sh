#!/bin/sh

# - Builds and installs the library in one build tree
# - Builds and runs the tests in another build tree, finds meta
#   with find_package so the config module is also tested

set -ex

# install the library in one build tree
cmake -H. -Bout/build_lib \
    -DCMAKE_INSTALL_PREFIX=${PWD}/out -DCMAKE_BUILD_TYPE=Release \
    -DMETA_ENABLE_TEST=0 -DMETA_CUSTOM_CXX_FLAGS=0

cmake --build out/build_lib --target install --config Release

for c in Debug Relase; do
    # build and run tests in another build tree
    cmake -H. -Bout/build_test \
        -DCMAKE_PREFIX_PATH=${PWD}/out -DCMAKE_BUILD_TYPE=$c \
        -DMETA_CUSTOM_CXX_FLAGS=0 -DMETA_ENABLE_LIBRARY=0

    cmake --build out/build_test --config $c --clean-first
    cmake --build out/build_test --target RUN_TESTS --config $c \
        || cmake --build out/build_test --target test --config $c
done


