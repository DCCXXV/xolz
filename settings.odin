package main

import rl "vendor:raylib"

VOLUME_LEVELS :: COLS
VOLUME_DEFAULT :: 7
volume: int
unmuted_volume := VOLUME_DEFAULT

VOLUME_LABEL :: "VOLUME"
VOLUME_LABEL_GAP :: 4

BACK_HINT :: "PRESS ESC TO GO BACK"
BACK_HINT_MARGIN :: 3
BACK_HINT_Y :: SCREEN_H - BACK_HINT_MARGIN - FONT_CAP_H
VOLUME_ROW_W :: (VOLUME_LEVELS - 1) * PITCH + GLYPH_SIZE
VOLUME_BOX_W :: VOLUME_ROW_W + INSET * 2
VOLUME_BOX_H :: GLYPH_SIZE + INSET * 2

SETTINGS_H :: FONT_CAP_H + VOLUME_LABEL_GAP + VOLUME_BOX_H
VOLUME_LABEL_Y :: (SCREEN_H - SETTINGS_H) / 2
VOLUME_BOX_X :: (SCREEN_W - VOLUME_BOX_W) / 2
VOLUME_BOX_Y :: VOLUME_LABEL_Y + FONT_CAP_H + VOLUME_LABEL_GAP
VOLUME_ROW_X :: VOLUME_BOX_X + INSET
VOLUME_ROW_Y :: VOLUME_BOX_Y + INSET

set_volume :: proc(level: int, save := true) {
	volume = clamp(level, 0, VOLUME_LEVELS)
	rl.SetMasterVolume(f32(volume) / VOLUME_LEVELS)
	if save do save_int("volume", volume)
}

change_volume :: proc(level: int) {
	set_volume(level)
	if volume > 0 do play_place_sound(volume - 1)
}

toggle_mute :: proc() {
	if volume > 0 {
		unmuted_volume = volume
		set_volume(0, save = false)
	} else {
		set_volume(unmuted_volume, save = false)
	}
}

volume_dice_rect :: proc(i: int) -> rl.Rectangle {
	return {f32(VOLUME_ROW_X + i * PITCH), VOLUME_ROW_Y, PITCH, GLYPH_SIZE}
}

update_settings :: proc(mouse: rl.Vector2) {
	left := rl.IsKeyPressed(.LEFT) || rl.IsKeyPressedRepeat(.LEFT) || rl.IsKeyPressed(.A)
	right := rl.IsKeyPressed(.RIGHT) || rl.IsKeyPressedRepeat(.RIGHT) || rl.IsKeyPressed(.D)
	if left && volume > 0 do change_volume(volume - 1)
	if right && volume < VOLUME_LEVELS do change_volume(volume + 1)

	if rl.IsMouseButtonPressed(.LEFT) {
		for i in 0 ..< VOLUME_LEVELS {
			if !rl.CheckCollisionPointRec(mouse, volume_dice_rect(i)) do continue
			level := i + 1
			if level == 1 && volume == 1 do level = 0
			change_volume(level)
		}
	}
}

draw_settings :: proc(target: rl.RenderTexture2D) {
	rl.BeginTextureMode(target)
	rl.ClearBackground(rl.BLACK)

	draw_text_centered(VOLUME_LABEL, VOLUME_LABEL_Y, rl.WHITE)

	box := rl.Rectangle{VOLUME_BOX_X, VOLUME_BOX_Y, VOLUME_BOX_W, VOLUME_BOX_H}
	rl.DrawRectangleLinesEx(box, BORDER, rl.WHITE)

	for i in 0 ..< VOLUME_LEVELS {
		color := rl.WHITE if i < volume else rl.DARKGRAY
		draw_pattern(VOLUME_ROW_X + i * PITCH, VOLUME_ROW_Y, DICE_DIGITS[i], color)
	}

	draw_text_centered(BACK_HINT, BACK_HINT_Y, rl.GRAY)

	rl.EndTextureMode()
}
