package game

import "core:math"
import rl "vendor:raylib"

PLACE_WAV :: #load("sfx/place.wav")
place_sfx: rl.Sound

COLUMN_NOTES := [COLS]f32{0, 2, 4, 7, 9, 12, 14, 16, 19}

play_place_sound :: proc(col: int) {
	pitch := math.pow(2, COLUMN_NOTES[col] / 12)
	rl.SetSoundPitch(place_sfx, pitch)
	rl.SetSoundVolume(place_sfx, 1)
	rl.PlaySound(place_sfx)
}

play_toggle_sound :: proc(on: bool) {
	rl.SetSoundPitch(place_sfx, 2 if on else 0.7)
	rl.SetSoundVolume(place_sfx, 1 if on else 0.4)
	rl.PlaySound(place_sfx)
}

BREAK_WAV :: #load("sfx/break.wav")
break_sfx: rl.Sound

play_break_sound :: proc() {
	rl.PlaySound(break_sfx)
}

GAME_OVER_WAV :: #load("sfx/game_over.wav")
game_over_sfx: rl.Sound

play_game_over_sound :: proc() {
	rl.PlaySound(game_over_sfx)
}
