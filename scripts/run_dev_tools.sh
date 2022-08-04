#!/bin/bash

# make script executable form any path within project
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
MAIN_PATH=$SCRIPTPATH/../main
BUILD_PATH=$SCRIPTPATH/../build
ROOT_PATH=$SCRIPTPATH/.. # project root

# activate IDF environment
get_idf

# requirements
$IDF_PATH/tools/idf_tools.py install xtensa-clang
. $IDF_PATH/export.sh

# configure project with idf cmake, not system cmake
cmake -B build -DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-clang-esp32.cmake -DTARGET=esp32 -GNinja

# build project
cmake --build $BUILD_PATH --target app

# copy compile commands from build dir to project root
cp $BUILD_PATH/compile_commands.json $ROOT_PATH

# remove compile flags unknown to clang from compile_commands.json
sed -i 's/-mlongcalls/ /g' $ROOT_PATH/compile_commands.json
sed -i 's/-fno-tree-switch-conversion/ /g' $ROOT_PATH/compile_commands.json
sed -i 's/-fstrict-volatile-bitfields/ /g' $ROOT_PATH/compile_commands.json

echo "---- ---- ---- ---- ---- ----"
echo "---- ---- ---- CLANG-FORMAT"
echo "---- ---- ---- ---- ---- ----"

# format with clang-format
find $MAIN_PATH -regex '.*\.\(cpp\|hpp\|cc\|cxx\|c\|h\)' -exec clang-format -style=file -i {} \;

echo "---- ---- ---- ---- ---- ----"
echo "---- ---- ---- CLANG-TIDY"
echo "---- ---- ---- ---- ---- ----"

# lint with clang-tidy
find $MAIN_PATH -regex '.*\.\(cpp\|hpp\|cc\|cxx\|c\|h\)' -exec clang-tidy \
-extra-arg=-Wno-unknown-warning-option \
{} \;
