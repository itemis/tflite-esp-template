#!/bin/bash

source "magic_wand_c_array.h"
copy $magic_wand_c_array
destdir=../main/src/micro_model.cpp
echo "$magic_wand_c_array" > "$destdir"