extends Panel
## Tuş atama penceresi: bir satıra tıkla, sonra yeni tuşa bas (Esc = vazgeç).

var game
var rows := {}
var waiting := ""

func _init() -> void:
	size = Vector2(380, 590)
	visible = false
	z_index = 40
	add_theme_stylebox_override("panel", _box())
	var t := Label.new()
	t.text = "Tuş Atama"
	t.position = Vector2(16, 10)
	t.add_theme_font_size_override("font_size", 20)
	t.add_theme_color_override("font_color", Color("f2c75c"))
	add_child(t)

func _box() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.04, 0.03, 0.97)
	s.border_color = Color("c9a24a")
	s.set_border_width_all(3)
	s.set_corner_radius_all(8)
	return s

func build() -> void:
	var y := 46.0
	for a in game.BIND_NAMES:
		var l := Label.new()
		l.text = game.BIND_NAMES[a]
		l.position = Vector2(20, y + 3)
		l.add_theme_color_override("font_color", Color("e9eef2"))
		add_child(l)
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(220, y)
		b.size = Vector2(140, 26)
		b.pressed.connect(func(): _wait(a))
		add_child(b)
		rows[a] = b
		y += 29.0
	var rb := Button.new()
	rb.text = "Varsayılan"
	rb.focus_mode = Control.FOCUS_NONE
	rb.position = Vector2(20, size.y - 40)
	rb.size = Vector2(150, 28)
	rb.pressed.connect(func():
		game.reset_binds()
		refresh())
	add_child(rb)
	var cb := Button.new()
	cb.text = "Kapat"
	cb.focus_mode = Control.FOCUS_NONE
	cb.position = Vector2(size.x - 170, size.y - 40)
	cb.size = Vector2(150, 28)
	cb.pressed.connect(close)
	add_child(cb)
	refresh()

func refresh() -> void:
	for a in rows:
		(rows[a] as Button).text = "..." if waiting == a else OS.get_keycode_string(game.binds[a])

func _wait(a: String) -> void:
	waiting = a
	refresh()

func open() -> void:
	var vs := get_viewport().get_visible_rect().size
	position = ((vs - size) * 0.5).round()
	waiting = ""
	refresh()
	visible = true

func close() -> void:
	visible = false
	waiting = ""
	game.save_settings()

func _input(ev: InputEvent) -> void:
	if not visible or waiting == "":
		return
	if ev is InputEventKey and ev.pressed and not ev.echo:
		if ev.keycode != KEY_ESCAPE:
			game.set_bind(waiting, ev.keycode)
		waiting = ""
		refresh()
		get_viewport().set_input_as_handled()
