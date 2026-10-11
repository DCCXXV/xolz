#+build wasm32, wasm64p32

package game

import "core:fmt"

@(default_calling_convention = "c")
foreign _ {
	emscripten_run_script :: proc(script: cstring) ---
	emscripten_run_script_int :: proc(script: cstring) -> i32 ---
}

load_int :: proc(name: string, default: int) -> int {
	buf: [128]u8
	js := fmt.bprintf(buf[:], "+(localStorage.getItem('xolz_%s') ?? %d)\x00", name, default)
	return int(emscripten_run_script_int(cstring(raw_data(js))))
}

save_int :: proc(name: string, n: int) {
	buf: [128]u8
	js := fmt.bprintf(buf[:], "localStorage.setItem('xolz_%s', %d)\x00", name, n)
	emscripten_run_script(cstring(raw_data(js)))
}
