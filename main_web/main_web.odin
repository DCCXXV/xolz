package main_web

import game ".."
import "base:runtime"

web_context: runtime.Context

@(export)
main_start :: proc "c" () {
	context = runtime.default_context()
	web_context = context
	game.init()
}

@(export)
main_update :: proc "c" () {
	context = web_context
	game.update()
}
