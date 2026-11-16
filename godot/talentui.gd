extends Control
## Yetenek ağacı penceresi (N). Üç dal, dört sıra; her sıra için daldaki puan şartı vardır.

const Glyph = preload("res://glyph.gd")
const GOLD := Color("f2c75c")
const TREE_COL := [Color("c8602a"), Color("c8a82a"), Color("3a7ac8")]

class Btn extends Control:
	signal clicked(id: String)
	signal hovered(id: String, on: bool)
	const Glyph = preload("res://glyph.gd")
	var id := ""
	var kind := "strike"
	var rank := 0
	var maxr := 1
	var open := false
	var col := Color.WHITE

	func _init() -> void:
		custom_minimum_size = Vector2(46, 46)
		size = Vector2(46, 46)

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(id)
			accept_event()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_ENTER:
			hovered.emit(id, true)
		elif what == NOTIFICATION_MOUSE_EXIT:
			hovered.emit(id, false)

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		Glyph.draw(self, kind, r.grow(-3))
		if not open and rank == 0:
			draw_rect(r, Color(0, 0, 0, 0.62))
		var border := Color("5a4a2a")
		if rank >= maxr:
			border = Color("ffe45c")
		elif rank > 0 or open:
			border = Color("5ae07a")
		draw_rect(r, Color("0e0a05"), false, 2.0)
		draw_rect(r.grow(-1), border, false, 2.0)
		var f := ThemeDB.fallback_font
		var t := "%d/%d" % [rank, maxr]
		draw_string_outline(f, Vector2(0, 43), t, HORIZONTAL_ALIGNMENT_RIGHT, 43, 12, 4, Color.BLACK)
		draw_string(f, Vector2(0, 43), t, HORIZONTAL_ALIGNMENT_RIGHT, 43, 12, Color("ffe45c") if rank > 0 else Color("c8c8c8"))

var game
var win: Panel
var pts_lbl: Label
var desc: RichTextLabel
var reset_btn: Button
var btns := {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	win = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.05, 0.04, 0.96)
	sb.border_color = Color("8a6a30")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(6)
	win.add_theme_stylebox_override("panel", sb)
	win.visible = false
	win.mouse_filter = Control.MOUSE_FILTER_STOP
	win.set_anchors_preset(Control.PRESET_CENTER)
	win.size = Vector2(420, 430)
	win.position = Vector2(-210, -215)
	add_child(win)
	var t := _label("Yetenekler", 16, GOLD)
	t.position = Vector2(14, 6)
	win.add_child(t)
	var x := Button.new()
	x.text = "X"
	x.focus_mode = Control.FOCUS_NONE
	x.position = Vector2(386, 5)
	x.size = Vector2(24, 22)
	x.pressed.connect(func(): game.toggle_win("tal"))
	win.add_child(x)
	pts_lbl = _label("", 14, Color("9be8a8"))
	pts_lbl.position = Vector2(14, 34)
	win.add_child(pts_lbl)
	var names := ["Silahlar", "Öfke", "Koruma"]
	for tix in 3:
		var hx := 18 + tix * 132
		var h := _label(names[tix], 15, TREE_COL[tix])
		h.position = Vector2(hx, 62)
		win.add_child(h)
		var tp := _label("", 12, Color("c8c8c8"))
		tp.name = "tp%d" % tix
		tp.position = Vector2(hx + 80, 65)
		win.add_child(tp)
	var ti := 0
	for td in game.TALENTS:
		var b := Btn.new()
		b.id = td["id"]
		b.kind = td["icon"]
		b.maxr = td["max"]
		b.position = Vector2(18 + td["tree"] * 132 + 24, 92 + td["row"] * 62)
		b.clicked.connect(_on_click)
		b.hovered.connect(_on_hover)
		win.add_child(b)
		btns[td["id"]] = b
		ti += 1
	desc = RichTextLabel.new()
	desc.bbcode_enabled = true
	desc.fit_content = false
	desc.scroll_active = false
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.position = Vector2(14, 346)
	desc.size = Vector2(392, 44)
	desc.add_theme_font_size_override("normal_font_size", 13)
	win.add_child(desc)
	reset_btn = Button.new()
	reset_btn.focus_mode = Control.FOCUS_NONE
	reset_btn.position = Vector2(14, 396)
	reset_btn.size = Vector2(200, 26)
	reset_btn.pressed.connect(func():
		game.tal_reset()
		refresh())
	win.add_child(reset_btn)
	refresh()

func _label(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _on_click(id: String) -> void:
	game.tal_learn(id)
	refresh()

func _on_hover(id: String, on: bool) -> void:
	if not on:
		desc.text = ""
		return
	var td: Dictionary = game.talent_def(id)
	var rk: int = game.trk(id)
	var s := "[color=#ffd100]%s[/color]  (%d/%d)\n" % [td["name"], rk, td["max"]]
	s += td["fmt"] % (td["v"] * maxi(rk, 1))
	if rk < td["max"] and rk > 0:
		s += "  [color=#9be8a8]Sonraki: %s[/color]" % (td["fmt"] % (td["v"] * (rk + 1)))
	var need: int = td["row"] * 2
	if game.tal_tree_pts(td["tree"]) < need:
		s += "\n[color=#ff8a7a]Bu daldan %d puan gerekir.[/color]" % need
	desc.text = s

func refresh() -> void:
	if win == null or game == null or game.P.is_empty():
		return
	var pts: int = game.tal_points()
	pts_lbl.text = "Kullanılabilir puan: %d" % pts
	for tix in 3:
		(win.get_node("tp%d" % tix) as Label).text = "(%d)" % game.tal_tree_pts(tix)
	for td in game.TALENTS:
		var b: Btn = btns[td["id"]]
		b.rank = game.trk(td["id"])
		b.open = game.tal_can(td["id"])
		b.queue_redraw()
	var cost: int = game.tal_reset_cost()
	reset_btn.text = "Sıfırla (%s)" % game.Items.money_plain(cost)
	reset_btn.disabled = game.tal_spent() == 0
