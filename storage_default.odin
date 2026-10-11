#+build !wasm32
#+build !wasm64p32

package game

import "core:os"
import "core:strconv"

data_path :: proc(name: string) -> string {
	dir: string
	when ODIN_OS == .Windows {
		dir = os.get_env("APPDATA", context.temp_allocator)
	} else {
		dir = os.get_env("XDG_DATA_HOME", context.temp_allocator)
		if dir == "" {
			home := os.get_env("HOME", context.temp_allocator)
			dir, _ = os.join_path({home, ".local", "share"}, context.temp_allocator)
		}
	}
	dir, _ = os.join_path({dir, "xolz"}, context.temp_allocator)
	os.make_directory_all(dir)
	path, _ := os.join_path({dir, name}, context.temp_allocator)
	return path
}

load_int :: proc(name: string, default: int) -> int {
	data, err := os.read_entire_file(data_path(name), context.temp_allocator)
	if err != nil do return default
	n, ok := strconv.parse_int(string(data))
	if !ok do return default
	return n
}

save_int :: proc(name: string, n: int) {
	buf: [32]u8
	_ = os.write_entire_file(data_path(name), strconv.write_int(buf[:], i64(n), 10))
}
