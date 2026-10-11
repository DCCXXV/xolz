#!/bin/sh -e
[ -f ~/emsdk/emsdk_env.sh ] && EMSDK_QUIET=1 . ~/emsdk/emsdk_env.sh
OUT=build/web
mkdir -p $OUT
odin build main_web -target:js_wasm32 -build-mode:obj -define:RAYLIB_WASM_LIB=env.o -out:$OUT/game.wasm.o
cp "$(odin root)/core/sys/wasm/js/odin.js" $OUT/
emcc -o $OUT/index.html $OUT/game.wasm.o "$(odin root)/vendor/raylib/wasm/libraylib.web.a" \
	-sUSE_GLFW=3 -sWASM_BIGINT -sWARN_ON_UNDEFINED_SYMBOLS=0 -sALLOW_MEMORY_GROWTH \
	--shell-file main_web/index_template.html
rm $OUT/game.wasm.o
