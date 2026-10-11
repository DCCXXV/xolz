#!/bin/bash -eu

OUT_DIR="build/desktop"
mkdir -p $OUT_DIR
odin build main_desktop -out:$OUT_DIR/xolz
echo "Desktop build created in ${OUT_DIR}"
