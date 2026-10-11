package main_desktop

import game ".."
import rl "vendor:raylib"

main :: proc() {
	game.init()
	for !rl.WindowShouldClose() do game.update()
	game.shutdown()
}
