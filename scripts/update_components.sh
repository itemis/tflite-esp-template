#!/bin/bash
git submodule update --init --recursive # download submodules

# TFMICRO and ESP-NN components
# delete old components
rm -r components/tfmicro
rm -r components/esp-nn
# extract new components from submodule
cp -r components/sources/tflite-micro-esp-examples/components/tflite-lib components/tfmicro
cp -r components/sources/tflite-micro-esp-examples/components/esp-nn components/esp-nn

# add code for other dependencies here 