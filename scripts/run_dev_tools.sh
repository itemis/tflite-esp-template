#!/bin/bash

# activate IDF environment
get_idf

# requirements
$IDF_PATH/tools/idf_tools.py install xtensa-clang
. $IDF_PATH/export.sh

# configure project with idf cmake, not system cmake
cmake -B build -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-clang-esp32.cmake -DTARGET=esp32 -GNinja

# build project
cmake --build build --target app

# copy compile commands from build dir to project root
cp build/compile_commands.json .

# remove compile flags unknown to clang from compile_commands.json
sed -i 's/-mlongcalls/ /g' compile_commands.json
sed -i 's/-fno-tree-switch-conversion/ /g' compile_commands.json
sed -i 's/-fstrict-volatile-bitfields/ /g' compile_commands.json

echo "---- ---- ---- ---- ---- ----"
echo "---- ---- ---- CLANG-FORMAT"
echo "---- ---- ---- ---- ---- ----"

# format all files with clang-format
find main -regex '.*\.\(cpp\|hpp\|cc\|cxx\|c\|h\)' -exec clang-format -style=file -i {} \;

echo "---- ---- ---- ---- ---- ----"
echo "---- ---- ---- CLANG-TIDY"
echo "---- ---- ---- ---- ---- ----"

# lint with clang-tidy
find main -regex '.*\.\(cpp\|hpp\|cc\|cxx\|c\|h\)' -exec clang-tidy \
-extra-arg=-Wno-unknown-warning-option \
{} \;
