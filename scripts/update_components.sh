#!/bin/bash
echo "---- ---- ---- ---- ---- ----"
echo "---- ---- ---- UPDATING COMPONENTS"
echo "---- ---- ---- ---- ---- ----"

# make script executable form any path within project
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
COMPONENT_PATH=$SCRIPTPATH/../components

# download submodules
git submodule update --init --recursive

# TFMICRO and ESP-NN components
# delete old components if they exist
rm -rf $COMPONENT_PATH/tfmicro
rm -rf $COMPONENT_PATH/esp-nn
# extract new components from submodule
cp -r $COMPONENT_PATH/sources/tflite-micro-esp-examples/components/tflite-lib $COMPONENT_PATH/tfmicro
cp -r $COMPONENT_PATH/sources/tflite-micro-esp-examples/components/esp-nn $COMPONENT_PATH/esp-nn

# add code for other dependencies here 