package game

import rl "vendor:raylib"

VOLUME_LEVELS :: COLS
VOLUME_DEFAULT :: 7
volume: int
unmuted_volume := VOLUME_DEFAULT

Settings_Item :: enum {
	Volume,
	Glyphs,
}

settings_selected: Settings_Item

VOLUME_LABEL :: "VOLUME"
GLYPHS_LABEL :: "GLYPHS"
SETTINGS_LABEL_GAP :: 4
SETTINGS_ITEM_GAP :: 6

CHECKBOX_INNER :: 5
CHECKBOX_SIZE :: CHECKBOX_INNER + BORDER * 2
CHECKBOX_PAD :: BORDER + (CHECKBOX_INNER - GLYPH_SIZE) / 2

BACK_HINT :: "PRESS ESC TO GO BACK"
BACK_HINT_MARGIN :: 3
BACK_HINT_Y :: SCREEN_H - BACK_HINT_MARGIN - FONT_CAP_H
VOLUME_ROW_W :: (VOLUME_LEVELS - 1) * PITCH + GLYPH_SIZE
VOLUME_BOX_W :: VOLUME_ROW_W + INSET * 2
VOLUME_BOX_H :: GLYPH_SIZE + INSET * 2

SETTINGS_H ::
	FONT_CAP_H +
	SETTINGS_LABEL_GAP +
	VOLUME_BOX_H +
	SETTINGS_ITEM_GAP +
	FONT_CAP_H +
	SETTINGS_LABEL_GAP +
	GLYPH_GRID_H
VOLUME_LABEL_Y :: (BACK_HINT_Y - SETTINGS_H) / 2
VOLUME_BOX_X :: (SCREEN_W - VOLUME_BOX_W) / 2
VOLUME_BOX_Y :: VOLUME_LABEL_Y + FONT_CAP_H + SETTINGS_LABEL_GAP
VOLUME_ROW_X :: VOLUME_BOX_X + INSET
VOLUME_ROW_Y :: VOLUME_BOX_Y + INSET

GLYPHS_LABEL_Y :: VOLUME_BOX_Y + VOLUME_BOX_H + SETTINGS_ITEM_GAP
GLYPH_GRID_X :: (SCREEN_W - GLYPH_GRID_W) / 2
GLYPH_GRID_Y :: GLYPHS_LABEL_Y + FONT_CAP_H + SETTINGS_LABEL_GAP

GLYPH_COUNT :: len(Glyph) - 1
GLYPH_GRID_COLS :: 6
GLYPH_GRID_ROWS :: GLYPH_COUNT / GLYPH_GRID_COLS
GLYPH_GRID_PITCH :: CHECKBOX_SIZE - BORDER
GLYPH_GRID_W :: GLYPH_GRID_COLS * GLYPH_GRID_PITCH + BORDER
GLYPH_GRID_H :: GLYPH_GRID_ROWS * GLYPH_GRID_PITCH + BORDER

glyph_cursor: int

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

toggle_glyph :: proc(g: Glyph) {
	if g in enabled_glyphs {
		if card(enabled_glyphs) == 1 do return

		enabled_glyphs -= {g}
	} else {
		enabled_glyphs += {g}
	}

	play_toggle_sound(g in enabled_glyphs)
	save_int("glyphs", int(transmute(u16)enabled_glyphs))
}

glyph_rect :: proc(i: int) -> rl.Rectangle {
	x := GLYPH_GRID_X + i % GLYPH_GRID_COLS * GLYPH_GRID_PITCH
	y := GLYPH_GRID_Y + i / GLYPH_GRID_COLS * GLYPH_GRID_PITCH
	return {f32(x), f32(y), CHECKBOX_SIZE, CHECKBOX_SIZE}
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
	case .Glyphs:
		if left do glyph_cursor = (glyph_cursor + GLYPH_COUNT - 1) % GLYPH_COUNT
		if right do glyph_cursor = (glyph_cursor + 1) % GLYPH_COUNT
		if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
			toggle_glyph(Glyph(glyph_cursor + 1))
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
		for i in 0 ..< GLYPH_COUNT {
			if !rl.CheckCollisionPointRec(mouse, glyph_rect(i)) do continue
			settings_selected = .Glyphs
			glyph_cursor = i
			toggle_glyph(Glyph(i + 1))
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
	rl.DrawRectangleLinesEx(box, BORDER, settings_label_color(.Volume))

	for i in 0 ..< VOLUME_LEVELS {
		color := rl.WHITE if i < volume else rl.DARKGRAY
		draw_pattern(VOLUME_ROW_X + i * PITCH, VOLUME_ROW_Y, DICE_DIGITS[i], color)
	}

	draw_text_centered(GLYPHS_LABEL, GLYPHS_LABEL_Y, settings_label_color(.Glyphs))

	for i in 0 ..< GLYPH_COUNT {
		g := Glyph(i + 1)
		r := glyph_rect(i)
		rl.DrawRectangleLinesEx(r, BORDER, rl.GRAY)
		color := COLORS[g] if g in enabled_glyphs else rl.DARKGRAY
		draw_pattern(int(r.x) + CHECKBOX_PAD, int(r.y) + CHECKBOX_PAD, PATTERNS[g], color)
	}
	if settings_selected == .Glyphs {
		rl.DrawRectangleLinesEx(glyph_rect(glyph_cursor), BORDER, rl.WHITE)
	}

	draw_text_centered(BACK_HINT, BACK_HINT_Y, rl.GRAY)

	rl.EndTextureMode()
}
