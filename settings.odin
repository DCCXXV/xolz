package game

import rl "vendor:raylib"

VOLUME_LEVELS :: COLS
VOLUME_DEFAULT :: 7
volume: int
unmuted_volume := VOLUME_DEFAULT

Settings_Item :: enum {
	Volume,
	Extra_Glyphs,
}

settings_selected: Settings_Item
extra_glyphs: bool

VOLUME_LABEL :: "VOLUME"
EXTRA_GLYPHS_LABEL :: "EXTRA GLYPHS"
SETTINGS_LABEL_GAP :: 4
SETTINGS_ITEM_GAP :: 6

CHECKBOX_INNER :: 5
CHECKBOX_SIZE :: CHECKBOX_INNER + BORDER * 2
CHECKBOX_PAD :: BORDER + (CHECKBOX_INNER - GLYPH_SIZE) / 2
CHECKBOX_GAP :: 3

BACK_HINT :: "PRESS ESC TO GO BACK"
BACK_HINT_MARGIN :: 3
BACK_HINT_Y :: SCREEN_H - BACK_HINT_MARGIN - FONT_CAP_H
VOLUME_ROW_W :: (VOLUME_LEVELS - 1) * PITCH + GLYPH_SIZE
VOLUME_BOX_W :: VOLUME_ROW_W + INSET * 2
VOLUME_BOX_H :: GLYPH_SIZE + INSET * 2

SETTINGS_H :: FONT_CAP_H + SETTINGS_LABEL_GAP + VOLUME_BOX_H + SETTINGS_ITEM_GAP + CHECKBOX_SIZE
VOLUME_LABEL_Y :: (SCREEN_H - SETTINGS_H) / 2
VOLUME_BOX_X :: (SCREEN_W - VOLUME_BOX_W) / 2
VOLUME_BOX_Y :: VOLUME_LABEL_Y + FONT_CAP_H + SETTINGS_LABEL_GAP
VOLUME_ROW_X :: VOLUME_BOX_X + INSET
VOLUME_ROW_Y :: VOLUME_BOX_Y + INSET

EXTRA_GLYPHS_Y :: VOLUME_BOX_Y + VOLUME_BOX_H + SETTINGS_ITEM_GAP
EXTRA_GLYPHS_LABEL_Y :: EXTRA_GLYPHS_Y + (CHECKBOX_SIZE - FONT_CAP_H) / 2

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

toggle_extra_glyphs :: proc() {
	extra_glyphs = !extra_glyphs
	save_int("extra_glyphs", int(extra_glyphs))
}

extra_glyphs_rect :: proc() -> rl.Rectangle {
	w := text_width(EXTRA_GLYPHS_LABEL) + CHECKBOX_GAP + CHECKBOX_SIZE
	return {f32((SCREEN_W - w) / 2), EXTRA_GLYPHS_Y, f32(w), CHECKBOX_SIZE}
}

draw_checkbox :: proc(x, y: int, checked: bool) {
	rl.DrawRectangleLinesEx({f32(x), f32(y), CHECKBOX_SIZE, CHECKBOX_SIZE}, BORDER, rl.WHITE)
	if checked do draw_pattern(x + CHECKBOX_PAD, y + CHECKBOX_PAD, PATTERNS[.Cross], rl.WHITE)
}

volume_dice_rect :: proc(i: int) -> rl.Rectangle {
	return {f32(VOLUME_ROW_X + i * PITCH), VOLUME_ROW_Y, PITCH, GLYPH_SIZE}
}

update_settings :: proc(mouse: rl.Vector2) {
	if rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W) {
		settings_selected = Settings_Item(
			(int(settings_selected) + len(Settings_Item) - 1) % len(Settings_Item),
		)
	}
	if rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.S) {
		settings_selected = Settings_Item((int(settings_selected) + 1) % len(Settings_Item))
	}

	left := rl.IsKeyPressed(.LEFT) || rl.IsKeyPressedRepeat(.LEFT) || rl.IsKeyPressed(.A)
	right := rl.IsKeyPressed(.RIGHT) || rl.IsKeyPressedRepeat(.RIGHT) || rl.IsKeyPressed(.D)
	switch settings_selected {
	case .Volume:
		if left && volume > 0 do change_volume(volume - 1)
		if right && volume < VOLUME_LEVELS do change_volume(volume + 1)
	case .Extra_Glyphs:
		if left || right || rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
			toggle_extra_glyphs()
		}
	}

	if rl.IsMouseButtonPressed(.LEFT) {
		for i in 0 ..< VOLUME_LEVELS {
			if !rl.CheckCollisionPointRec(mouse, volume_dice_rect(i)) do continue
			settings_selected = .Volume
			level := i + 1
			if level == 1 && volume == 1 do level = 0
			change_volume(level)
		}
		if rl.CheckCollisionPointRec(mouse, extra_glyphs_rect()) {
			settings_selected = .Extra_Glyphs
			toggle_extra_glyphs()
		}
	}
}

settings_label_color :: proc(item: Settings_Item) -> rl.Color {
	return rl.WHITE if item == settings_selected else rl.GRAY
}

draw_settings :: proc(target: rl.RenderTexture2D) {
	rl.BeginTextureMode(target)
	rl.ClearBackground(rl.BLACK)

	draw_text_centered(VOLUME_LABEL, VOLUME_LABEL_Y, settings_label_color(.Volume))

	box := rl.Rectangle{VOLUME_BOX_X, VOLUME_BOX_Y, VOLUME_BOX_W, VOLUME_BOX_H}
	rl.DrawRectangleLinesEx(box, BORDER, rl.WHITE)

	for i in 0 ..< VOLUME_LEVELS {
		color := rl.WHITE if i < volume else rl.DARKGRAY
		draw_pattern(VOLUME_ROW_X + i * PITCH, VOLUME_ROW_Y, DICE_DIGITS[i], color)
	}

	row := extra_glyphs_rect()
	label_pos := rl.Vector2{row.x, f32(EXTRA_GLYPHS_LABEL_Y - FONT_CAP_TOP)}
	color := settings_label_color(.Extra_Glyphs)
	rl.DrawTextEx(font, EXTRA_GLYPHS_LABEL, label_pos, FONT_SIZE, FONT_SPACING, color)
	draw_checkbox(int(row.x + row.width) - CHECKBOX_SIZE, EXTRA_GLYPHS_Y, extra_glyphs)

	draw_text_centered(BACK_HINT, BACK_HINT_Y, rl.GRAY)

	rl.EndTextureMode()
}
