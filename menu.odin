package game

import "core:math/rand"
import rl "vendor:raylib"

Scene :: enum {
	Menu,
	Game,
	Settings,
}

scene: Scene

Menu_Item :: enum {
	Play,
	Settings,
}

MENU_LABELS := [Menu_Item]cstring {
	.Play     = "PLAY",
	.Settings = "SETTINGS",
}

menu_selected: Menu_Item

BUTTON_PAD :: 1
BUTTON_H :: (BORDER + BUTTON_PAD) * 2 + FONT_CAP_H
BUTTON_GAP :: 3
BUTTONS_H :: len(Menu_Item) * BUTTON_H + (len(Menu_Item) - 1) * BUTTON_GAP

LOGO_GRID :: 7
logo_glyphs: [LOGO_GRID][LOGO_GRID]Glyph
logo_shape: Glyph
logo_shape_x, logo_shape_y: int

LOGO_GRID_SIZE :: (LOGO_GRID - 1) * PITCH + GLYPH_SIZE
LOGO_PAD :: INSET + GAP
LOGO_SIZE :: LOGO_GRID_SIZE + LOGO_PAD * 2
LOGO_BUTTONS_GAP :: 5

MENU_H :: LOGO_SIZE + LOGO_BUTTONS_GAP + BUTTONS_H
LOGO_X :: (SCREEN_W - LOGO_SIZE) / 2
LOGO_Y :: (SCREEN_H - MENU_H) / 2
BUTTONS_Y :: LOGO_Y + LOGO_SIZE + LOGO_BUTTONS_GAP

randomize_logo :: proc() {
	for &row in logo_glyphs {
		for &g in row do g = Glyph(rand.int_max(GLYPH_COUNT) + 1)
	}
	logo_shape, _ = rand.choice_bit_set(enabled_glyphs)
	logo_shape_x = rand.int_max(LOGO_GRID - GLYPH_SIZE + 1)
	logo_shape_y = rand.int_max(LOGO_GRID - GLYPH_SIZE + 1)
	for cy in 0 ..< GLYPH_SIZE {
		for cx in 0 ..< GLYPH_SIZE {
			if !in_logo_shape(logo_shape_x + cx, logo_shape_y + cy) do continue
			logo_glyphs[logo_shape_y + cy][logo_shape_x + cx] = logo_shape
		}
	}
}

in_logo_shape :: proc(x, y: int) -> bool {
	cx, cy := x - logo_shape_x, y - logo_shape_y
	if cx < 0 || cy < 0 || cx >= GLYPH_SIZE || cy >= GLYPH_SIZE do return false
	return PATTERNS[logo_shape][cy][cx]
}

draw_logo :: proc(px, py: int) {
	rl.DrawRectangleLinesEx({f32(px), f32(py), LOGO_SIZE, LOGO_SIZE}, BORDER, rl.WHITE)
	for row, y in logo_glyphs {
		for g, x in row {
			color := COLORS[g] if in_logo_shape(x, y) else rl.DARKGRAY
			draw_pattern(px + LOGO_PAD + x * PITCH, py + LOGO_PAD + y * PITCH, PATTERNS[g], color)
		}
	}
}

text_width :: proc(text: cstring) -> int {
	w := 0
	x := 0
	for c in string(text) {
		i := rl.GetGlyphIndex(font, c)
		w = x + int(font.glyphs[i].offsetX) + int(font.recs[i].width)
		x += int(font.glyphs[i].advanceX) + FONT_SPACING
	}
	return w
}

button_width :: proc() -> int {
	w := 0
	for label in MENU_LABELS do w = max(w, text_width(label))
	return w + (BORDER + BUTTON_PAD) * 2
}

button_rect :: proc(item: Menu_Item) -> rl.Rectangle {
	w := button_width()
	x := (SCREEN_W - w) / 2
	y := BUTTONS_Y + int(item) * (BUTTON_H + BUTTON_GAP)
	return {f32(x), f32(y), f32(w), BUTTON_H}
}

activate_menu_item :: proc(item: Menu_Item) {
	switch item {
	case .Play:
		clear_board()
		scene = .Game
	case .Settings:
		scene = .Settings
	}
}

update_menu :: proc(mouse: rl.Vector2) {
	if rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W) {
		menu_selected = Menu_Item((int(menu_selected) + len(Menu_Item) - 1) % len(Menu_Item))
	}
	if rl.IsKeyPressed(.DOWN) || rl.IsKeyPressed(.S) {
		menu_selected = Menu_Item((int(menu_selected) + 1) % len(Menu_Item))
	}
	if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
		activate_menu_item(menu_selected)
		return
	}

	for item in Menu_Item {
		if !rl.CheckCollisionPointRec(mouse, button_rect(item)) do continue
		if rl.GetMouseDelta() != {} do menu_selected = item
		if rl.IsMouseButtonPressed(.LEFT) {
			menu_selected = item
			activate_menu_item(item)
		}
	}
}

draw_menu :: proc() {
	draw_logo(LOGO_X, LOGO_Y)

	for item in Menu_Item {
		draw_button(button_rect(item), MENU_LABELS[item], item == menu_selected)
	}
}

draw_button :: proc(rect: rl.Rectangle, label: cstring, inverted: bool) {
	fg, bg := rl.WHITE, rl.BLACK
	if inverted do fg, bg = bg, fg

	rl.DrawRectangleRec(rect, bg)
	rl.DrawRectangleLinesEx(rect, BORDER, rl.WHITE)

	x := int(rect.x) + (int(rect.width) - text_width(label)) / 2
	y := int(rect.y) + (BUTTON_H - FONT_CAP_H) / 2 - FONT_CAP_TOP
	rl.DrawTextEx(font, label, {f32(x), f32(y)}, FONT_SIZE, FONT_SPACING, fg)
}
