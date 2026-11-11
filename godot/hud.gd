extends CanvasLayer
## Arayüz: kodla kurulur (sahne dosyası gerekmez).

signal start_pressed
signal ability_pressed(i: int)
signal potion_pressed
signal talk_pressed

const GOLD := Color("f2c75c")
const ABIL_NAMES := ["Güçlü Vuruş", "Savuruş", "Kalkan Çarpması"]
const ABIL_COST := [15, 25, 12]

var root: Control
var pf_name: Label
var hp_bar: ProgressBar
var hp_lbl: Label
var rage_bar: ProgressBar
var rage_lbl: Label
var xp_bar: ProgressBar
var gold_lbl: Label
var tf: PanelContainer
var tf_name: Label
var tf_lvl: Label
var tf_bar: ProgressBar
var tf_lbl: Label
var log_box: VBoxContainer
var quest_lbl: Label
var banner_lbl: Label
var banner_sub: Label
var banner_tween: Tween
var abil_btns: Array = []
var pot_btn: Button
var dlg: PanelContainer
var dlg_title: Label
var dlg_sub: Label
var dlg_body: Label
var dlg_buttons: VBoxContainer
var talk_lbl: Label
var dead_lbl: Label
var title_box: Control
var help_lbl: Label

func _panel_style(border: Color = Color("3b4b59"), alpha: float = 0.82) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.05, 0.07, 0.1, alpha)
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 7
	s.content_margin_bottom = 7
	return s

func _bar(color: Color, h: float = 16.0) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(210, h)
	b.max_value = 100
	b.value = 100
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.55)
	bg.set_corner_radius_all(3)
	var fg := StyleBoxFlat.new()
	fg.bg_color = color
	fg.set_corner_radius_all(3)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fg)
	return b

func _label(text: String, size: int = 14, color: Color = Color("e9eef2")) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _overlay_label(bar: ProgressBar) -> Label:
	var l := _label("", 11)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_constant_override("outline_size", 3)
	bar.add_child(l)
	return l

func _ready() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_player_frame()
	_build_target_frame()
	_build_log()
	_build_actions()
	_build_dialog()
	_build_banner()
	_build_title()
	talk_lbl = _label("", 18, Color("9be8a8"))
	talk_lbl.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	talk_lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	talk_lbl.position = Vector2(0, -170)
	talk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(talk_lbl)
	dead_lbl = _label("Öldün… Kamp ateşinde canlanıyorsun", 34, Color("ffb0a0"))
	dead_lbl.set_anchors_preset(Control.PRESET_CENTER)
	dead_lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dead_lbl.visible = false
	root.add_child(dead_lbl)
	help_lbl = _label("WASD yürü · Sağ tık basılı tut: kamera · Sol tık: hedef seç · Boşluk: otomatik saldırı · 1 2 3 yetenekler · F iksir · G konuş · Tekerlek: yakınlaştır", 12, Color("b8c6d1"))
	help_lbl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	help_lbl.position = Vector2(12, -24)
	help_lbl.visible = false
	root.add_child(help_lbl)

func _build_player_frame() -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _panel_style())
	p.position = Vector2(12, 12)
	root.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	p.add_child(v)
	pf_name = _label("Cüce Savaşçı  Sv 1", 15)
	v.add_child(pf_name)
	hp_bar = _bar(Color("3fbf6a"))
	hp_lbl = _overlay_label(hp_bar)
	v.add_child(hp_bar)
	rage_bar = _bar(Color("d8442f"))
	rage_lbl = _overlay_label(rage_bar)
	v.add_child(rage_bar)
	xp_bar = _bar(Color("a35cf0"), 6.0)
	v.add_child(xp_bar)
	gold_lbl = _label("Altın 0", 14, GOLD)
	v.add_child(gold_lbl)

func _build_target_frame() -> void:
	tf = PanelContainer.new()
	tf.add_theme_stylebox_override("panel", _panel_style(Color("6b3b3b")))
	tf.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tf.grow_horizontal = Control.GROW_DIRECTION_BOTH
	tf.position = Vector2(0, 12)
	tf.visible = false
	root.add_child(tf)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	tf.add_child(v)
	var h := HBoxContainer.new()
	tf_name = _label("", 15)
	tf_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tf_lvl = _label("", 13, Color("93a1ad"))
	h.add_child(tf_name)
	h.add_child(tf_lvl)
	v.add_child(h)
	tf_bar = _bar(Color("d44444"))
	tf_lbl = _overlay_label(tf_bar)
	v.add_child(tf_bar)

func _build_log() -> void:
	log_box = VBoxContainer.new()
	log_box.position = Vector2(12, 160)
	log_box.custom_minimum_size = Vector2(380, 0)
	log_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(log_box)
	quest_lbl = _label("", 13, GOLD)
	quest_lbl.position = Vector2(12, 128)
	root.add_child(quest_lbl)

func _build_actions() -> void:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	bar.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bar.position = Vector2(0, -14)
	root.add_child(bar)
	for i in 3:
		var b := Button.new()
		b.custom_minimum_size = Vector2(96, 64)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 12)
		b.text = "%d  %s\nÖfke %d" % [i + 1, ABIL_NAMES[i], ABIL_COST[i]]
		b.pressed.connect(func(): ability_pressed.emit(i))
		bar.add_child(b)
		abil_btns.append(b)
	pot_btn = Button.new()
	pot_btn.custom_minimum_size = Vector2(80, 64)
	pot_btn.focus_mode = Control.FOCUS_NONE
	pot_btn.add_theme_font_size_override("font_size", 12)
	pot_btn.pressed.connect(func(): potion_pressed.emit())
	bar.add_child(pot_btn)

func _build_dialog() -> void:
	dlg = PanelContainer.new()
	dlg.add_theme_stylebox_override("panel", _panel_style(GOLD, 0.95))
	dlg.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dlg.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dlg.grow_vertical = Control.GROW_DIRECTION_BEGIN
	dlg.position = Vector2(0, -100)
	dlg.custom_minimum_size = Vector2(520, 0)
	dlg.visible = false
	root.add_child(dlg)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	dlg.add_child(v)
	dlg_title = _label("", 20, GOLD)
	dlg_sub = _label("", 12, Color("93a1ad"))
	dlg_body = _label("", 15)
	dlg_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dlg_body.custom_minimum_size = Vector2(500, 0)
	dlg_buttons = VBoxContainer.new()
	dlg_buttons.add_theme_constant_override("separation", 6)
	v.add_child(dlg_title)
	v.add_child(dlg_sub)
	v.add_child(dlg_body)
	v.add_child(dlg_buttons)

func _build_banner() -> void:
	banner_lbl = _label("", 46, GOLD)
	banner_lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner_lbl.position = Vector2(0, 150)
	banner_lbl.add_theme_constant_override("outline_size", 8)
	banner_lbl.modulate.a = 0.0
	root.add_child(banner_lbl)
	banner_sub = _label("", 18, Color("cfe3f5"))
	banner_sub.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_sub.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner_sub.position = Vector2(0, 212)
	banner_sub.modulate.a = 0.0
	root.add_child(banner_sub)

func _build_title() -> void:
	title_box = Control.new()
	title_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(title_box)
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.04, 0.06, 0.45)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_box.add_child(shade)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_CENTER)
	v.grow_horizontal = Control.GROW_DIRECTION_BOTH
	v.grow_vertical = Control.GROW_DIRECTION_BOTH
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 14)
	title_box.add_child(v)
	var t := _label("CÜCE SAVAŞÇI", 72, GOLD)
	t.add_theme_constant_override("outline_size", 12)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var s := _label("Karlı vadide kurt, domuz ve ayı avla. Demirkazan şehrinde görev al.", 20, Color("d5e1ea"))
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(s)
	var b := Button.new()
	b.text = "BAŞLA"
	b.custom_minimum_size = Vector2(220, 56)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 24)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(func():
		title_box.visible = false
		help_lbl.visible = true
		start_pressed.emit())
	v.add_child(b)
	var h := _label("WASD yürü · Sağ tık basılı tut: kamera · Sol tık: hedef · Boşluk: otomatik saldırı", 14, Color("93a1ad"))
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(h)

# ---------- dışarıdan çağrılanlar ----------
func start_game_without_click() -> void:
	title_box.visible = false
	help_lbl.visible = true

func update_player(d: Dictionary) -> void:
	pf_name.text = "Cüce Savaşçı  Sv %d" % d["lvl"]
	hp_bar.value = clampf(d["hp"] / d["maxhp"] * 100.0, 0.0, 100.0)
	hp_lbl.text = "%d / %d" % [maxi(0, roundi(d["hp"])), d["maxhp"]]
	rage_bar.value = d["rage"]
	rage_lbl.text = "Öfke %d" % roundi(d["rage"])
	xp_bar.value = 100.0 if d["lvl"] >= 10 else d["xp"] / d["xpneed"] * 100.0
	gold_lbl.text = "Altın %d" % d["gold"]
	for i in 3:
		var b: Button = abil_btns[i]
		var cd: float = d["cd"][i]
		var ok: bool = d["rage"] >= ABIL_COST[i]
		b.text = "%d  %s\n%s" % [i + 1, ABIL_NAMES[i], ("%.1f sn" % cd) if cd > 0.0 else ("Öfke %d" % ABIL_COST[i])]
		b.modulate = Color(1, 1, 1, 1) if (ok and cd <= 0.0) else Color(1, 1, 1, 0.5)
	pot_btn.text = "F İksir x%d\n%s" % [d["pot"], ("%d sn" % ceili(d["potcd"])) if d["potcd"] > 0.0 else "hazır"]
	pot_btn.modulate = Color(1, 1, 1, 1) if (d["pot"] > 0 and d["potcd"] <= 0.0) else Color(1, 1, 1, 0.5)

func update_target(d: Dictionary) -> void:
	if d.is_empty():
		tf.visible = false
		return
	tf.visible = true
	tf_name.text = d["name"]
	tf_name.add_theme_color_override("font_color", d["color"])
	tf_lvl.text = "Sv %d" % d["lvl"]
	tf_bar.value = clampf(d["hp"] / d["maxhp"] * 100.0, 0.0, 100.0)
	tf_lbl.text = "%d / %d" % [maxi(0, roundi(d["hp"])), roundi(d["maxhp"])]

func say(text: String, color: Color = Color("e9eef2")) -> void:
	var l := _label(text, 13, color)
	log_box.add_child(l)
	while log_box.get_child_count() > 6:
		var old := log_box.get_child(0)
		log_box.remove_child(old)
		old.queue_free()
	var tw := create_tween()
	tw.tween_interval(9.0)
	tw.tween_property(l, "modulate:a", 0.0, 1.5)
	tw.tween_callback(l.queue_free)

## Dünyadaki isim levhaları (canavar / NPC). id → {box, name, bar, sub, mark}
var plates := {}

func _make_plate() -> Dictionary:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_END
	box.add_theme_constant_override("separation", 0)
	var mark := _label("", 26, GOLD)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var nm := _label("", 14)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub := _label("", 11, Color("c9d6e0"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bar := _bar(Color("d44444"), 6.0)
	bar.custom_minimum_size = Vector2(70, 6)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(mark)
	box.add_child(nm)
	box.add_child(sub)
	box.add_child(bar)
	root.add_child(box)
	root.move_child(box, 0)
	return {"box": box, "name": nm, "bar": bar, "sub": sub, "mark": mark}

func plate(id, pos: Vector2, text: String, color: Color, ratio: float, sub: String = "", mark: String = "", selected: bool = false) -> void:
	if not plates.has(id):
		plates[id] = _make_plate()
	var p: Dictionary = plates[id]
	var box: Control = p["box"]
	box.visible = true
	(p["name"] as Label).text = text
	(p["name"] as Label).add_theme_color_override("font_color", color)
	(p["name"] as Label).add_theme_font_size_override("font_size", 16 if selected else 14)
	(p["bar"] as Control).visible = ratio >= 0.0
	if ratio >= 0.0:
		(p["bar"] as ProgressBar).value = clampf(ratio, 0.0, 1.0) * 100.0
	(p["sub"] as Label).text = sub
	(p["sub"] as Label).visible = sub != ""
	(p["mark"] as Label).text = mark
	(p["mark"] as Label).visible = mark != ""
	box.reset_size()
	box.position = pos - Vector2(box.size.x * 0.5, box.size.y)

func plate_hide(id) -> void:
	if plates.has(id):
		(plates[id]["box"] as Control).visible = false

func set_quests(lines: Array) -> void:
	var s := ""
	for ln in lines:
		s += ln + "\n"
	quest_lbl.text = s.strip_edges()

func banner(title: String, sub: String = "") -> void:
	banner_lbl.text = title
	banner_sub.text = sub
	if banner_tween:
		banner_tween.kill()
	banner_lbl.modulate.a = 1.0
	banner_sub.modulate.a = 1.0
	banner_tween = create_tween()
	banner_tween.tween_interval(1.6)
	banner_tween.set_parallel(true)
	banner_tween.tween_property(banner_lbl, "modulate:a", 0.0, 2.0)
	banner_tween.tween_property(banner_sub, "modulate:a", 0.0, 2.0)

func show_dialog(title: String, sub: String, body: String, buttons: Array) -> void:
	dlg_title.text = title
	dlg_sub.text = sub
	dlg_body.text = body
	for c in dlg_buttons.get_children():
		dlg_buttons.remove_child(c)
		c.queue_free()
	for bd in buttons:
		var b := Button.new()
		b.text = bd["label"]
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 40)
		b.disabled = bd.get("disabled", false)
		b.pressed.connect(bd["cb"])
		dlg_buttons.add_child(b)
	dlg.visible = true

func hide_dialog() -> void:
	dlg.visible = false

func set_prompt(text: String) -> void:
	talk_lbl.text = text

func show_dead(v: bool) -> void:
	dead_lbl.visible = v
