extends CanvasLayer
## WoW tarzı arayüz: kodla kurulur.

const Parts = preload("res://ui_parts.gd")
const Glyph = preload("res://glyph.gd")

signal start_pressed(continue_game: bool)
signal resume_pressed
signal quit_pressed
signal volume_changed(v: float)
signal fullscreen_pressed
signal ability_pressed(i: int)
signal talk_pressed
signal bag_pressed
signal menu_pressed
signal help_pressed
signal char_pressed

const GOLD := Color("f2c75c")
const PARCH := Color("d8c192")
const INK := Color("3a2410")

## Savaşçı yetenekleri. 0-8 = tuş 1-9, 9 = iksir (tuş 0 / F)
const ABIL := [
	{"name": "Kahramanlık Darbesi", "kind": "strike", "cost": 15, "cd": 0.0, "lvl": 1, "rng": "Yakın menzil", "desc": "Hedefe silahınla güçlü bir darbe indirir."},
	{"name": "Hamle", "kind": "charge", "cost": 0, "cd": 14.0, "lvl": 1, "rng": "8-25 metre", "desc": "Hedefe atılır, onu 1,5 sn sersemletir ve 15 öfke verir."},
	{"name": "Yaralama", "kind": "rend", "cost": 10, "cd": 0.0, "lvl": 2, "rng": "Yakın menzil", "desc": "Hedefi kanatır; 8 sn boyunca her 2 sn'de hasar verir."},
	{"name": "Savaş Narası", "kind": "shout", "cost": 10, "cd": 3.0, "lvl": 2, "rng": "Kendin", "desc": "Saldırı gücünü 60 sn boyunca %25 artırır."},
	{"name": "Gök Gürültüsü", "kind": "clap", "cost": 20, "cd": 8.0, "lvl": 3, "rng": "6 metre", "desc": "Yakındaki tüm düşmanlara hasar verir ve onları 8 sn yavaşlatır."},
	{"name": "Kalkan Bloğu", "kind": "shield", "cost": 10, "cd": 12.0, "lvl": 3, "rng": "Kendin", "desc": "5 sn boyunca aldığın hasarı %70 azaltır."},
	{"name": "İnfaz", "kind": "execute", "cost": 15, "cd": 0.0, "lvl": 4, "rng": "Yakın menzil", "desc": "Yalnızca canı %20'nin altındaki hedefe kullanılır. Çok büyük hasar verir."},
	{"name": "Ölümcül Darbe", "kind": "mortal", "cost": 30, "cd": 6.0, "lvl": 5, "rng": "Yakın menzil", "desc": "Hedefe devasa bir vuruş indirir."},
	{"name": "Kasırga", "kind": "whirl", "cost": 25, "cd": 10.0, "lvl": 6, "rng": "5 metre", "desc": "Dönerek çevrendeki tüm düşmanlara vurur."},
]

var root: Control
var pf_name: Label
var pf_portrait
var hp_bar: ProgressBar
var hp_lbl: Label
var rage_bar: ProgressBar
var rage_lbl: Label
var xp_bar: ProgressBar
var xp_lbl: Label
var tf: Control
var tf_portrait
var tf_name: Label
var tf_bar: ProgressBar
var tf_lbl: Label
var log_box: VBoxContainer
var quest_box: VBoxContainer
var banner_lbl: Label
var banner_sub: Label
var banner_tween: Tween
var slots: Array = []
var tip: PanelContainer
var tip_name: Label
var tip_cost: Label
var tip_desc: Label
var tip_note: Label
var tip_idx := -1
var minimap
var zone_lbl: Label
var coord_lbl: Label
var buff_box: HBoxContainer
var buffs := {}
var dlg: PanelContainer
var dlg_title: Label
var dlg_sub: Label
var dlg_body: Label
var dlg_buttons: VBoxContainer
var talk_lbl: Label
var dead_lbl: Label
var title_box: Control
var continue_btn: Button
var pause_box: PanelContainer
var vol_slider: HSlider
var help_box: PanelContainer
var plates := {}

# ---------- stil yardımcıları ----------
func _box(bg: Color, border: Color = Color("6a5528"), bw: int = 2, radius: int = 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 7
	s.content_margin_bottom = 7
	return s

func _bar(color: Color, h: float = 16.0, w: float = 176.0) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = Vector2(w, h)
	b.size = Vector2(w, h)
	b.max_value = 100
	b.value = 100
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.06, 0.05, 0.04, 0.9)
	bg.border_color = Color("0e0a05")
	bg.set_border_width_all(1)
	var fg := StyleBoxFlat.new()
	fg.bg_color = color
	fg.border_color = color.darkened(0.35)
	fg.set_border_width_all(1)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fg)
	return b

func _label(text: String, size: int = 14, color: Color = Color("e9eef2"), outline: int = 4) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", outline)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _overlay_label(bar: ProgressBar, size: int = 11) -> Label:
	var l := _label("", size)
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_constant_override("outline_size", 3)
	bar.add_child(l)
	return l

func _place(c: Control, l: float, t: float, r: float, b: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = l
	c.anchor_top = t
	c.anchor_right = r
	c.anchor_bottom = b
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob

func _wood_panel(rect: Rect2, _alpha: float = 0.88) -> Control:
	var p = Parts.Frame.new()
	p.position = rect.position
	p.size = rect.size
	return p

# ---------- kurulum ----------
func _ready() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_player_frame()
	_build_target_frame()
	_build_minimap()
	_build_quest_tracker()
	_build_chat()
	_build_actionbar()
	_build_bag()
	_build_tip()
	_build_dialog()
	_build_banner()
	_build_help()
	_build_pause()
	_build_title()
	talk_lbl = _label("", 18, Color("9be8a8"))
	_place(talk_lbl, 0.5, 1.0, 0.5, 1.0, -200, -150, 200, -126)
	talk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(talk_lbl)
	dead_lbl = _label("Öldün… Kamp ateşinde canlanıyorsun", 34, Color("ffb0a0"), 8)
	_place(dead_lbl, 0.5, 0.4, 0.5, 0.4, -400, 0, 400, 60)
	dead_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dead_lbl.visible = false
	root.add_child(dead_lbl)
	_set_hud_visible(false)

var _hud_nodes: Array = []

func _set_hud_visible(v: bool) -> void:
	for n in _hud_nodes:
		n.visible = v

func _reg(n: Control) -> Control:
	_hud_nodes.append(n)
	return n

func _build_player_frame() -> void:
	var f := Control.new()
	f.position = Vector2(14, 14)
	f.size = Vector2(270, 72)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_reg(f))
	f.add_child(_wood_panel(Rect2(40, 8, 224, 58)))
	pf_portrait = Parts.Portrait.new()
	pf_portrait.kind = "dwarf"
	f.add_child(pf_portrait)
	pf_name = _label("Cüce Savaşçı", 15, GOLD)
	pf_name.position = Vector2(78, 9)
	f.add_child(pf_name)
	hp_bar = _bar(Color("2fb552"), 17.0, 178.0)
	hp_bar.position = Vector2(78, 28)
	hp_lbl = _overlay_label(hp_bar)
	f.add_child(hp_bar)
	rage_bar = _bar(Color("c22a1c"), 13.0, 178.0)
	rage_bar.position = Vector2(78, 47)
	rage_lbl = _overlay_label(rage_bar, 10)
	f.add_child(rage_bar)

func _build_target_frame() -> void:
	tf = Control.new()
	tf.position = Vector2(300, 14)
	tf.size = Vector2(270, 72)
	tf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tf.visible = false
	root.add_child(tf)
	tf.add_child(_wood_panel(Rect2(6, 8, 224, 58)))
	tf_portrait = Parts.Portrait.new()
	tf_portrait.position = Vector2(200, 0)
	tf.add_child(tf_portrait)
	tf_name = _label("", 15)
	tf_name.position = Vector2(16, 9)
	tf.add_child(tf_name)
	tf_bar = _bar(Color("2fb552"), 17.0, 178.0)
	tf_bar.position = Vector2(16, 28)
	tf_lbl = _overlay_label(tf_bar)
	tf.add_child(tf_bar)
	var hint := _label("", 10, Color("b8c6d1"), 3)
	hint.position = Vector2(16, 47)
	hint.name = "hint"
	tf.add_child(hint)

func _build_minimap() -> void:
	var zr = Parts.Frame.new()
	zr.rivets = false
	_place(zr, 1.0, 0.0, 1.0, 0.0, -176, 8, -16, 30)
	root.add_child(_reg(zr))
	zone_lbl = _label("Kar Dağı Vadisi", 13, GOLD, 3)
	zone_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	zone_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	zr.add_child(zone_lbl)
	minimap = Parts.Minimap.new()
	_place(minimap, 1.0, 0.0, 1.0, 0.0, -176, 34, -26, 184)
	root.add_child(_reg(minimap))
	coord_lbl = _label("", 11, Color("d9e4ee"), 3)
	_place(coord_lbl, 1.0, 0.0, 1.0, 0.0, -176, 186, -26, 202)
	coord_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_reg(coord_lbl))
	buff_box = HBoxContainer.new()
	buff_box.add_theme_constant_override("separation", 4)
	buff_box.alignment = BoxContainer.ALIGNMENT_END
	buff_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_place(buff_box, 1.0, 0.0, 1.0, 0.0, -420, 40, -190, 90)
	root.add_child(_reg(buff_box))

func _build_quest_tracker() -> void:
	quest_box = VBoxContainer.new()
	quest_box.add_theme_constant_override("separation", 2)
	quest_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quest_box.custom_minimum_size = Vector2(254, 0)
	_place(quest_box, 1.0, 0.0, 1.0, 0.0, -270, 214, -16, 340)
	root.add_child(_reg(quest_box))

func _build_chat() -> void:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", _box(Color(0.0, 0.0, 0.0, 0.45), Color(0.0, 0.0, 0.0, 0.0), 0, 0))
	_place(p, 0.0, 1.0, 0.0, 1.0, 12, -200, 380, -34)
	for i in 2:
		var tab := Panel.new()
		tab.add_theme_stylebox_override("panel", _box(Color(0.08, 0.07, 0.05, 0.9 if i == 0 else 0.55), Color("6a5528") if i == 0 else Color("3a3020"), 1, 2))
		tab.position = Vector2(2 + i * 84, -22)
		tab.size = Vector2(82, 20)
		tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_child(tab)
		var tl := _label("Genel" if i == 0 else "Savaş Kaydı", 11, GOLD if i == 0 else Color("8a8270"), 3)
		tl.set_anchors_preset(Control.PRESET_FULL_RECT)
		tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tab.add_child(tl)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_reg(p))
	log_box = VBoxContainer.new()
	log_box.alignment = BoxContainer.ALIGNMENT_END
	log_box.add_theme_constant_override("separation", 0)
	log_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	log_box.clip_contents = true
	log_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	log_box.offset_left = 6
	log_box.offset_top = 4
	log_box.offset_right = -6
	log_box.offset_bottom = -4
	p.add_child(log_box)

func _build_actionbar() -> void:
	var holder := Control.new()
	_place(holder, 0.5, 1.0, 0.5, 1.0, -258, -96, 258, -12)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_reg(holder))
	holder.add_child(_wood_panel(Rect2(0, 0, 516, 64), 0.92))
	var wl = Parts.Wing.new()
	wl.position = Vector2(-66, -8)
	wl.flip = true
	wl.size = Vector2(70, 80)
	holder.add_child(wl)
	var wr = Parts.Wing.new()
	wr.position = Vector2(512, -8)
	holder.add_child(wr)
	for i in 10:
		var s = Parts.Slot.new()
		s.idx = i
		s.position = Vector2(8 + i * 50, 9)
		s.key_text = str((i + 1) % 10)
		if i < 9:
			s.kind = ABIL[i]["kind"]
		else:
			s.kind = "potion"
		s.clicked.connect(func(k): ability_pressed.emit(k))
		s.hovered.connect(_on_slot_hover)
		holder.add_child(s)
		slots.append(s)
	# tecrübe çubuğu
	xp_bar = _bar(Color("8a3ad8"), 11.0, 516.0)
	xp_bar.position = Vector2(0, 68)
	xp_lbl = _overlay_label(xp_bar, 9)
	holder.add_child(xp_bar)
	var tk = Parts.Ticks.new()
	tk.set_anchors_preset(Control.PRESET_FULL_RECT)
	xp_bar.add_child(tk)

func _build_bag() -> void:
	var holder := Control.new()
	_place(holder, 1.0, 1.0, 1.0, 1.0, -244, -60, -14, -14)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_reg(holder))
	var kinds := ["char", "help", "menu"]
	var tips := ["Karakter (C)", "Yardım (H)", "Menü (Esc)"]
	for i in 3:
		var mb = Parts.MicroBtn.new()
		mb.kind = kinds[i]
		mb.position = Vector2(i * 24, 6)
		mb.tooltip_text = tips[i]
		mb.pressed.connect(func():
			if i == 0:
				char_pressed.emit()
			elif i == 1:
				help_pressed.emit()
			else:
				menu_pressed.emit())
		holder.add_child(mb)
	var bb = Parts.BagBar.new()
	bb.position = Vector2(80, 3)
	bb.tooltip_text = "Çanta (B)"
	bb.pressed.connect(func(): bag_pressed.emit())
	holder.add_child(bb)

func _build_tip() -> void:
	tip = PanelContainer.new()
	tip.add_theme_stylebox_override("panel", _box(Color(0.02, 0.03, 0.06, 0.96), Color("c9a24a"), 2, 4))
	tip.visible = false
	tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip.z_index = 20
	root.add_child(tip)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 3)
	tip.add_child(v)
	tip_name = _label("", 16, Color.WHITE)
	tip_cost = _label("", 12, Color("e9eef2"), 3)
	tip_desc = _label("", 13, GOLD, 3)
	tip_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_desc.custom_minimum_size = Vector2(250, 0)
	tip_note = _label("", 12, Color("ff8a7a"), 3)
	v.add_child(tip_name)
	v.add_child(tip_cost)
	v.add_child(tip_desc)
	v.add_child(tip_note)

func _build_dialog() -> void:
	dlg = PanelContainer.new()
	dlg.add_theme_stylebox_override("panel", _box(PARCH, Color("5a3a1a"), 5, 6))
	_place(dlg, 0.5, 1.0, 0.5, 1.0, -270, -420, 270, -110)
	dlg.visible = false
	dlg.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(dlg)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	dlg.add_child(v)
	dlg_title = _label("", 22, Color("6a1c0c"), 0)
	dlg_sub = _label("", 12, Color("6a5030"), 0)
	dlg_body = _label("", 15, INK, 0)
	dlg_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dlg_body.custom_minimum_size = Vector2(500, 0)
	dlg_buttons = VBoxContainer.new()
	dlg_buttons.add_theme_constant_override("separation", 6)
	v.add_child(dlg_title)
	v.add_child(dlg_sub)
	v.add_child(HSeparator.new())
	v.add_child(dlg_body)
	v.add_child(dlg_buttons)

func _build_banner() -> void:
	banner_lbl = _label("", 46, GOLD, 8)
	_place(banner_lbl, 0.5, 0.0, 0.5, 0.0, -400, 150, 400, 210)
	banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_lbl.modulate.a = 0.0
	root.add_child(banner_lbl)
	banner_sub = _label("", 18, Color("cfe3f5"))
	_place(banner_sub, 0.5, 0.0, 0.5, 0.0, -400, 212, 400, 240)
	banner_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_sub.modulate.a = 0.0
	root.add_child(banner_sub)

func _menu_button(text: String, size: int = 20) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(240, 52)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_stylebox_override("normal", _box(Color("5a3a1a"), Color("d8ae4a"), 3, 6))
	b.add_theme_stylebox_override("hover", _box(Color("7a5226"), Color("f2c75c"), 3, 6))
	b.add_theme_stylebox_override("pressed", _box(Color("3a2410"), Color("f2c75c"), 3, 6))
	b.add_theme_color_override("font_color", Color("f2e2b0"))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.focus_mode = Control.FOCUS_NONE
	return b

func _build_pause() -> void:
	pause_box = PanelContainer.new()
	pause_box.add_theme_stylebox_override("panel", _box(Color(0.05, 0.04, 0.03, 0.96), Color("c9a24a"), 3, 8))
	_place(pause_box, 0.5, 0.5, 0.5, 0.5, -160, -170, 160, 170)
	pause_box.visible = false
	pause_box.z_index = 30
	root.add_child(pause_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	pause_box.add_child(v)
	var t := _label("Oyun Menüsü", 24, GOLD, 5)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var rb := _menu_button("Devam et")
	rb.pressed.connect(func(): resume_pressed.emit())
	v.add_child(rb)
	var fb := _menu_button("Tam ekran")
	fb.pressed.connect(func(): fullscreen_pressed.emit())
	v.add_child(fb)
	var vl := _label("Ses", 14, Color("e9eef2"), 3)
	vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(vl)
	vol_slider = HSlider.new()
	vol_slider.min_value = 0.0
	vol_slider.max_value = 1.0
	vol_slider.step = 0.05
	vol_slider.value = 0.8
	vol_slider.custom_minimum_size = Vector2(240, 22)
	vol_slider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vol_slider.value_changed.connect(func(x): volume_changed.emit(x))
	v.add_child(vol_slider)
	var qb := _menu_button("Kaydet ve çık")
	qb.pressed.connect(func(): quit_pressed.emit())
	v.add_child(qb)

func set_paused(v: bool) -> void:
	pause_box.visible = v

func set_has_save(v: bool) -> void:
	continue_btn.visible = v

func _build_help() -> void:
	help_box = PanelContainer.new()
	help_box.add_theme_stylebox_override("panel", _box(Color(0.04, 0.035, 0.03, 0.95), Color("c9a24a"), 2, 6))
	_place(help_box, 0.5, 0.5, 0.5, 0.5, -230, -215, 230, 215)
	help_box.visible = false
	root.add_child(help_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	help_box.add_child(v)
	v.add_child(_label("Kontroller", 22, GOLD))
	var rows := [
		["W A S D", "Yürü"], ["Boşluk", "Zıpla"], ["Sağ tık basılı", "Kamerayı çevir"], ["Sol tık", "Hedef seç"],
		["Tekerlek", "Yakınlaştır / uzaklaştır"], ["Q  E", "Kamerayı döndür"], ["R", "Otomatik saldırı"],
		["1 - 9", "Yetenekler"], ["0  veya  F", "Can iksiri"], ["Tab", "En yakın düşmanı hedefle"],
		["G", "NPC ile konuş / ganimeti al"], ["B  C", "Çanta / Karakter"], ["Sağ tık (eşya)", "Giy / kullan / sat"], ["Esc", "Hedefi bırak / pencereyi kapat"], ["F11", "Tam ekran"], ["H", "Bu pencere"],
	]
	for r in rows:
		var h := HBoxContainer.new()
		var a := _label(r[0], 14, GOLD, 3)
		a.custom_minimum_size = Vector2(150, 0)
		h.add_child(a)
		h.add_child(_label(r[1], 14, Color("e9eef2"), 3))
		v.add_child(h)
	v.add_child(_label("Yeni yetenekler seviye atlayınca açılır.", 13, Color("93d4a0"), 3))

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
	var t := _label("CÜCE SAVAŞÇI", 72, GOLD, 12)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var s := _label("Karlı vadide kurt, domuz ve ayı avla. Demirkazan şehrinde görev al.", 20, Color("d5e1ea"))
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(s)
	continue_btn = _menu_button("DEVAM ET", 24)
	continue_btn.visible = false
	continue_btn.pressed.connect(func():
		start_game_without_click()
		start_pressed.emit(true))
	v.add_child(continue_btn)
	var nb := _menu_button("YENİ OYUN", 24)
	nb.pressed.connect(func():
		start_game_without_click()
		start_pressed.emit(false))
	v.add_child(nb)
	var h := _label("WASD yürü · Boşluk zıpla · Sağ tık basılı tut: kamera · Sol tık: hedef · H: yardım", 14, Color("93a1ad"))
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(h)

# ---------- tooltip ----------
func _on_slot_hover(i: int, on: bool) -> void:
	if not on:
		if tip_idx == i:
			tip.visible = false
			tip_idx = -1
		return
	tip_idx = i
	if i == 9:
		tip_name.text = "Can İksiri"
		tip_name.add_theme_color_override("font_color", Color("43d17f"))
		tip_cost.text = "Bekleme: 20 sn"
		tip_desc.text = "Canının %45'ini geri verir. Düşmanlardan ve satıcıdan edinilir."
		tip_note.text = ""
	else:
		var a: Dictionary = ABIL[i]
		tip_name.text = a["name"]
		tip_name.add_theme_color_override("font_color", Color.WHITE)
		var c := ("Öfke %d" % a["cost"]) if a["cost"] > 0 else "Öfke gerektirmez"
		tip_cost.text = "%s  ·  %s" % [c, a["rng"]]
		if a["cd"] > 0.0:
			tip_cost.text += "\nBekleme: %d sn" % a["cd"]
		tip_desc.text = a["desc"]
		tip_note.text = ("Seviye %d'de öğrenilir" % a["lvl"]) if a["lvl"] > _lvl else ""
	tip.visible = true
	tip.reset_size()
	await get_tree().process_frame
	if tip_idx != i:
		return
	var s: Control = slots[i]
	tip.position = Vector2(clampf(s.global_position.x - 100, 8, 1000), s.global_position.y - tip.size.y - 8)

# ---------- dışarıdan çağrılanlar ----------
var _lvl := 1

func start_game_without_click() -> void:
	title_box.visible = false
	_set_hud_visible(true)

func update_player(d: Dictionary) -> void:
	_lvl = d["lvl"]
	pf_portrait.lvl = d["lvl"]
	pf_portrait.queue_redraw()
	hp_bar.value = clampf(d["hp"] / d["maxhp"] * 100.0, 0.0, 100.0)
	hp_lbl.text = "%d / %d" % [maxi(0, roundi(d["hp"])), d["maxhp"]]
	rage_bar.value = d["rage"]
	rage_lbl.text = "Öfke %d" % roundi(d["rage"])
	xp_bar.value = 100.0 if d["lvl"] >= 10 else d["xp"] / d["xpneed"] * 100.0
	xp_lbl.text = "Seviye 10 (en yüksek)" if d["lvl"] >= 10 else "Tecrübe %d / %d" % [roundi(d["xp"]), roundi(d["xpneed"])]
	var gcd: float = d["gcd"]
	for i in 9:
		var s = slots[i]
		var a: Dictionary = ABIL[i]
		var cd: float = d["cd"][i]
		var f := 0.0
		var txt := ""
		if cd > 0.0:
			f = cd / maxf(a["cd"], 0.01)
			txt = ("%d" % ceili(cd)) if cd > 2.0 else ("%.1f" % cd)
		elif gcd > 0.0:
			f = gcd / 1.0
		s.locked = a["lvl"] if d["lvl"] < a["lvl"] else 0
		s.frac = f
		s.cd_text = txt
		s.norage = d["rage"] < a["cost"]
		s.glow = (i == 6 and d["exec_ok"])
		s.queue_redraw()
	var ps = slots[9]
	ps.count = str(d["pot"])
	var pc: float = d["potcd"]
	ps.frac = pc / 20.0 if pc > 0.0 else 0.0
	ps.cd_text = ("%d" % ceili(pc)) if pc > 0.0 else ""
	ps.norage = d["pot"] <= 0
	ps.queue_redraw()
	# buff'lar
	var seen := {}
	for b in d["buffs"]:
		seen[b["kind"]] = true
		if not buffs.has(b["kind"]):
			var nb = Parts.Buff.new()
			nb.kind = b["kind"]
			buff_box.add_child(nb)
			buffs[b["kind"]] = nb
		buffs[b["kind"]].t = b["t"]
		buffs[b["kind"]].queue_redraw()
	for k in buffs.keys():
		if not seen.has(k):
			buffs[k].queue_free()
			buffs.erase(k)

func update_target(d: Dictionary) -> void:
	if d.is_empty():
		tf.visible = false
		return
	tf.visible = true
	tf_name.text = d["name"]
	tf_name.add_theme_color_override("font_color", d["color"])
	tf_portrait.kind = d["kind"]
	tf_portrait.lvl = d["lvl"]
	tf_portrait.lvl_color = d["color"]
	tf_portrait.queue_redraw()
	tf_bar.value = clampf(d["hp"] / d["maxhp"] * 100.0, 0.0, 100.0)
	tf_lbl.text = "%d / %d" % [maxi(0, roundi(d["hp"])), roundi(d["maxhp"])]
	(tf.get_node("hint") as Label).text = d.get("hint", "")

func update_minimap(d: Dictionary) -> void:
	minimap.px = d["px"]
	minimap.pz = d["pz"]
	minimap.cam_yaw = d["cam_yaw"]
	minimap.pyaw = d["pyaw"]
	minimap.mobs = d["mobs"]
	minimap.npcs = d["npcs"]
	minimap.swamp = d.get("swamp", false)
	minimap.queue_redraw()
	coord_lbl.text = "%d, %d   %s" % [roundi(d["px"]), roundi(-d["pz"]), Time.get_time_string_from_system().substr(0, 5)]

func set_zone(s: String) -> void:
	zone_lbl.text = s

func say(text: String, color: Color = Color("e9eef2")) -> void:
	var l := _label(text, 13, color, 3)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(350, 0)
	log_box.add_child(l)
	while log_box.get_child_count() > 9:
		var old := log_box.get_child(0)
		log_box.remove_child(old)
		old.queue_free()

func set_quests(lines: Array) -> void:
	for c in quest_box.get_children():
		quest_box.remove_child(c)
		c.queue_free()
	if lines.is_empty():
		return
	var h := _label("Görevler", 15, GOLD, 4)
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quest_box.add_child(h)
	for ln in lines:
		var ready: bool = ln.find("Teslim") >= 0
		var l := _label(ln, 13, Color("7fe08a") if ready else Color("f2e2a8"), 3)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		quest_box.add_child(l)

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
		b.custom_minimum_size = Vector2(0, 38)
		b.disabled = bd.get("disabled", false)
		b.add_theme_stylebox_override("normal", _box(Color("5a3a1a"), Color("2a1a08"), 2, 4))
		b.add_theme_stylebox_override("hover", _box(Color("7a5226"), Color("f2c75c"), 2, 4))
		b.add_theme_stylebox_override("pressed", _box(Color("3a2410"), Color("f2c75c"), 2, 4))
		b.add_theme_stylebox_override("disabled", _box(Color("8a7a60"), Color("5a4a30"), 2, 4))
		b.add_theme_color_override("font_color", Color("f6e8bb"))
		b.add_theme_color_override("font_hover_color", Color.WHITE)
		b.add_theme_color_override("font_disabled_color", Color("c9bb9a"))
		b.pressed.connect(bd["cb"])
		dlg_buttons.add_child(b)
	dlg.visible = true
	dlg.reset_size()

func hide_dialog() -> void:
	dlg.visible = false

func toggle_help() -> void:
	help_box.visible = not help_box.visible

func set_prompt(text: String) -> void:
	talk_lbl.text = text

func show_dead(v: bool) -> void:
	dead_lbl.visible = v

# ---------- dünyadaki isim levhaları ----------
func _make_plate() -> Dictionary:
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_END
	box.add_theme_constant_override("separation", 0)
	var mark := _label("", 28, GOLD, 6)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var nm := _label("", 14)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub := _label("", 11, Color("c9d6e0"), 3)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bar := _bar(Color("d44444"), 7.0, 74.0)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
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
