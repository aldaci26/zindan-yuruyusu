extends Control
## Çanta, karakter, satıcı ve ganimet pencereleri + eşya ipuçları + imleçte taşınan eşya.

const Items = preload("res://items.gd")
const Glyph = preload("res://glyph.gd")
const Parts = preload("res://ui_parts.gd")
const GOLD := Color("f2c75c")

## Çanta / ekipman kutusu
class ItemSlot extends Control:
	signal clicked(kind: String, key, button: int)
	signal hovered(kind: String, key, on: bool)
	const Glyph = preload("res://glyph.gd")
	const Items = preload("res://items.gd")
	var kind := "bag"
	var key = 0
	var item := {}
	var count := 0
	var ghost := ""
	var dim := false
	var bad := false
	var interactive := true

	func _init(sz: float = 42.0) -> void:
		custom_minimum_size = Vector2(sz, sz)
		size = Vector2(sz, sz)

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and (ev.button_index == MOUSE_BUTTON_LEFT or ev.button_index == MOUSE_BUTTON_RIGHT):
			clicked.emit(kind, key, ev.button_index)
			accept_event()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_ENTER:
			hovered.emit(kind, key, true)
		elif what == NOTIFICATION_MOUSE_EXIT:
			hovered.emit(kind, key, false)

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color(0.05, 0.045, 0.04, 0.95))
		var inner := r.grow(-3)
		if item.is_empty():
			if ghost != "":
				Glyph.slot_ghost(self, ghost, inner)
			draw_rect(r, Color(0.36, 0.3, 0.2, 0.9), false, 2.0)
			return
		Glyph.item(self, item, inner)
		if bad:
			draw_rect(inner, Color(0.8, 0.1, 0.1, 0.35))
		if dim:
			draw_rect(inner, Color(0, 0, 0, 0.6))
		var rc: Color = Items.RARITY_COL[item["rar"]]
		draw_rect(r, rc if item["rar"] > 1 else Color(0.45, 0.4, 0.3, 0.95), false, 2.0)
		if count > 1:
			var f := ThemeDB.fallback_font
			draw_string_outline(f, Vector2(0, size.y - 4), str(count), HORIZONTAL_ALIGNMENT_RIGHT, size.x - 3, 13, 4, Color(0, 0, 0, 0.95))
			draw_string(f, Vector2(0, size.y - 4), str(count), HORIZONTAL_ALIGNMENT_RIGHT, size.x - 3, 13, Color.WHITE)

## Satıcı / ganimet satırı
class Row extends Control:
	signal clicked(idx: int, button: int)
	signal hovered(idx: int, on: bool)
	const Glyph = preload("res://glyph.gd")
	const Items = preload("res://items.gd")
	var idx := 0
	var item := {}
	var title := ""
	var tcol := Color.WHITE
	var price := -1
	var price_red := false
	var count := 1
	var hot := false
	var coin := false

	func _init() -> void:
		custom_minimum_size = Vector2(300, 40)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and (ev.button_index == MOUSE_BUTTON_LEFT or ev.button_index == MOUSE_BUTTON_RIGHT):
			clicked.emit(idx, ev.button_index)
			accept_event()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_ENTER:
			hot = true
			queue_redraw()
			hovered.emit(idx, true)
		elif what == NOTIFICATION_MOUSE_EXIT:
			hot = false
			queue_redraw()
			hovered.emit(idx, false)

	func _money(x_right: float, y: float, c: int, red: bool) -> void:
		var f := ThemeDB.fallback_font
		var parts: Array = []
		var g := c / 10000
		var s := (c / 100) % 100
		var k := c % 100
		if g > 0:
			parts.append([str(g), Color("ffd100")])
		if s > 0 or g > 0:
			parts.append([str(s), Color("c9c9d0")])
		parts.append([str(k), Color("c97a3a")])
		var x := x_right
		for i in range(parts.size() - 1, -1, -1):
			var col: Color = Color("ff4040") if red else parts[i][1]
			var w := f.get_string_size(parts[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
			x -= w
			draw_string_outline(f, Vector2(x, y), parts[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 3, Color(0, 0, 0, 0.9))
			draw_string(f, Vector2(x, y), parts[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, col)
			x -= 4.0
			draw_circle(Vector2(x - 3, y - 5), 4.0, parts[i][1].darkened(0.1))
			x -= 12.0

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color(0.16, 0.13, 0.08, 0.9) if hot else Color(0.07, 0.06, 0.05, 0.75))
		draw_rect(r, Color(0.5, 0.4, 0.2, 0.8), false, 1.0)
		var ir := Rect2(4, 3, 34, 34)
		if coin:
			draw_circle(ir.get_center(), 12.0, Color("e6b440"))
			draw_arc(ir.get_center(), 12.0, 0, TAU, 24, Color("8a5a10"), 2.0)
		elif not item.is_empty():
			Glyph.item(self, item, ir)
			draw_rect(ir, Items.RARITY_COL[item["rar"]] if item["rar"] > 1 else Color(0.45, 0.4, 0.3), false, 2.0)
			if count > 1:
				var f2 := ThemeDB.fallback_font
				draw_string_outline(f2, Vector2(4, 36), str(count), HORIZONTAL_ALIGNMENT_RIGHT, 32, 12, 3, Color.BLACK)
				draw_string(f2, Vector2(4, 36), str(count), HORIZONTAL_ALIGNMENT_RIGHT, 32, 12, Color.WHITE)
		var f := ThemeDB.fallback_font
		draw_string_outline(f, Vector2(46, 25), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 150, 14, 3, Color(0, 0, 0, 0.9))
		draw_string(f, Vector2(46, 25), title, HORIZONTAL_ALIGNMENT_LEFT, size.x - 150, 14, tcol)
		if price >= 0:
			_money(size.x - 8, 25, price, price_red)

var game
var bag_win: Panel
var char_win: Panel
var vend_win: Panel
var loot_win: Panel
var bag_slots: Array = []
var eq_slots := {}
var money_lbl: RichTextLabel
var stats_l: RichTextLabel
var stats_r: RichTextLabel
var char_portrait
var char_name: Label
var vend_title: Label
var vend_list: VBoxContainer
var vend_money: RichTextLabel
var vend_tab_btns: Array = []
var loot_title: Label
var loot_list: VBoxContainer
var tip: PanelContainer
var tip_lbl: RichTextLabel
var tip2: PanelContainer
var tip2_lbl: RichTextLabel
var cursor

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_bag()
	_build_char()
	_build_vendor()
	_build_loot()
	_build_tips()
	cursor = ItemSlot.new(40.0)
	cursor.interactive = false
	cursor.z_index = 100
	cursor.visible = false
	add_child(cursor)

func _process(_dt: float) -> void:
	if cursor.visible:
		cursor.position = get_viewport().get_mouse_position() - Vector2(20, 20)

# ---------- yardımcılar ----------
func _style(bg: Color = Color(0.06, 0.05, 0.04, 0.96)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = Color("8a6a30")
	s.set_border_width_all(3)
	s.set_corner_radius_all(6)
	return s

func _label(t: String, sz: int = 14, col: Color = Color("e9eef2")) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _rich(w: float, h: float) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.scroll_active = false
	r.fit_content = false
	r.custom_minimum_size = Vector2(w, h)
	r.size = Vector2(w, h)
	r.add_theme_font_size_override("normal_font_size", 14)
	r.add_theme_font_size_override("bold_font_size", 14)
	r.add_theme_color_override("default_color", Color("e9eef2"))
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

func _window(title: String, name: String) -> Panel:
	var p := Panel.new()
	p.add_theme_stylebox_override("panel", _style())
	p.visible = false
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(p)
	var t := _label(title, 16, GOLD)
	t.position = Vector2(14, 6)
	t.name = "title"
	p.add_child(t)
	var x := Button.new()
	x.text = "X"
	x.focus_mode = Control.FOCUS_NONE
	x.custom_minimum_size = Vector2(24, 22)
	x.size = Vector2(24, 22)
	x.anchor_left = 1.0
	x.anchor_right = 1.0
	x.offset_left = -30
	x.offset_right = -6
	x.offset_top = 5
	x.offset_bottom = 27
	x.pressed.connect(func(): game.ui_close(name))
	p.add_child(x)
	return p

func _slot(kind: String, key, sz: float, parent: Control, pos: Vector2) -> ItemSlot:
	var s := ItemSlot.new(sz)
	s.kind = kind
	s.key = key
	s.position = pos
	s.clicked.connect(_on_slot_click)
	s.hovered.connect(_on_slot_hover)
	parent.add_child(s)
	return s

# ---------- pencereler ----------
func _build_bag() -> void:
	bag_win = _window("Çanta", "bag")
	bag_win.anchor_left = 1.0
	bag_win.anchor_right = 1.0
	bag_win.anchor_top = 1.0
	bag_win.anchor_bottom = 1.0
	bag_win.offset_left = -226
	bag_win.offset_right = -14
	bag_win.offset_top = -392
	bag_win.offset_bottom = -112
	for i in 16:
		bag_slots.append(_slot("bag", i, 44.0, bag_win, Vector2(12 + (i % 4) * 48, 34 + (i / 4) * 48)))
	money_lbl = _rich(190, 24)
	money_lbl.position = Vector2(14, 250)
	bag_win.add_child(money_lbl)

func _build_char() -> void:
	char_win = _window("Karakter", "char")
	char_win.position = Vector2(14, 96)
	char_win.size = Vector2(336, 480)
	var left := ["head", "neck", "shoulder", "back", "chest", "wrist"]
	var right := ["hands", "waist", "legs", "feet", "ring1", "ring2"]
	for i in 6:
		eq_slots[left[i]] = _slot("eq", left[i], 40.0, char_win, Vector2(14, 36 + i * 44))
		eq_slots[right[i]] = _slot("eq", right[i], 40.0, char_win, Vector2(282, 36 + i * 44))
	var bottom := ["trinket1", "mainhand", "offhand", "trinket2"]
	for i in 4:
		eq_slots[bottom[i]] = _slot("eq", bottom[i], 40.0, char_win, Vector2(67 + i * 54, 304))
	for k in eq_slots:
		eq_slots[k].ghost = k
	char_portrait = Parts.Portrait.new()
	char_portrait.kind = "dwarf"
	char_portrait.size = Vector2(150, 150)
	char_portrait.position = Vector2(93, 44)
	char_win.add_child(char_portrait)
	char_name = _label("", 14, Color("ffd100"))
	char_name.position = Vector2(0, 246)
	char_name.size = Vector2(336, 20)
	char_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_win.add_child(char_name)
	stats_l = _rich(150, 110)
	stats_l.position = Vector2(18, 360)
	char_win.add_child(stats_l)
	stats_r = _rich(150, 110)
	stats_r.position = Vector2(176, 360)
	char_win.add_child(stats_r)

func _build_vendor() -> void:
	vend_win = _window("Satıcı", "vendor")
	vend_win.position = Vector2(14, 96)
	vend_win.size = Vector2(336, 480)
	vend_title = vend_win.get_node("title")
	for i in 2:
		var b := Button.new()
		b.text = "Satın al" if i == 0 else "Geri alım"
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(14 + i * 100, 34)
		b.size = Vector2(94, 26)
		b.pressed.connect(func(): game.ui_vendor_tab(i))
		vend_win.add_child(b)
		vend_tab_btns.append(b)
	var sc := ScrollContainer.new()
	sc.position = Vector2(12, 66)
	sc.size = Vector2(312, 370)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vend_win.add_child(sc)
	vend_list = VBoxContainer.new()
	vend_list.add_theme_constant_override("separation", 3)
	sc.add_child(vend_list)
	vend_money = _rich(300, 24)
	vend_money.position = Vector2(14, 446)
	vend_win.add_child(vend_money)

func _build_loot() -> void:
	loot_win = _window("Ganimet", "loot")
	loot_win.position = Vector2(400, 150)
	loot_win.size = Vector2(324, 60)
	loot_title = loot_win.get_node("title")
	loot_list = VBoxContainer.new()
	loot_list.position = Vector2(10, 34)
	loot_list.add_theme_constant_override("separation", 3)
	loot_win.add_child(loot_list)

func _build_tips() -> void:
	for i in 2:
		var p := PanelContainer.new()
		var sb := _style(Color(0.02, 0.03, 0.07, 0.97))
		sb.border_color = Color("5a6a8a")
		sb.set_border_width_all(2)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		p.add_theme_stylebox_override("panel", sb)
		p.visible = false
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.z_index = 90
		add_child(p)
		var r := RichTextLabel.new()
		r.bbcode_enabled = true
		r.fit_content = true
		r.scroll_active = false
		r.autowrap_mode = TextServer.AUTOWRAP_OFF
		r.custom_minimum_size = Vector2(210, 0)
		r.add_theme_font_size_override("normal_font_size", 14)
		r.add_theme_font_size_override("bold_font_size", 16)
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.add_child(r)
		if i == 0:
			tip = p
			tip_lbl = r
		else:
			tip2 = p
			tip2_lbl = r

# ---------- ipucu ----------
func show_tip(it: Dictionary, at: Vector2, compare: Dictionary = {}) -> void:
	if it.is_empty():
		return
	tip_lbl.text = Items.tip_bb(it, game.P["lvl"], game.inv.eq)
	tip.visible = true
	tip.reset_size()
	var cmp_w := 0.0
	if not compare.is_empty():
		tip2_lbl.text = "[color=#9aa7b4]Şu an takılı[/color]\n" + Items.tip_bb(compare, game.P["lvl"], game.inv.eq)
		tip2.visible = true
		tip2.reset_size()
	else:
		tip2.visible = false
	await get_tree().process_frame
	if not tip.visible:
		return
	var vs := get_viewport_rect().size
	var tw := tip.size.x
	var x := at.x + 16
	var total := tw + (tip2.size.x + 6 if tip2.visible else 0.0)
	if x + total > vs.x - 6:
		x = at.x - 16 - total
	var y := clampf(at.y - 10, 6, vs.y - maxf(tip.size.y, tip2.size.y if tip2.visible else 0.0) - 6)
	tip.position = Vector2(maxf(6, x), y)
	if tip2.visible:
		tip2.position = Vector2(tip.position.x + tw + 6, y)

func hide_tip() -> void:
	tip.visible = false
	tip2.visible = false

# ---------- olaylar ----------
func _on_slot_click(kind: String, key, button: int) -> void:
	hide_tip()
	game.ui_slot_click(kind, key, button)

func _on_slot_hover(kind: String, key, on: bool) -> void:
	if not on:
		hide_tip()
		return
	var it := {}
	var cmp := {}
	if kind == "bag":
		var e = game.inv.bag[key]
		if e != null:
			it = Items.get_item(e["id"])
			if Items.is_equip(it):
				var ts: String = game.inv.target_slot(it)
				var eqid: String = game.inv.eq[ts]
				if eqid != "":
					cmp = Items.get_item(eqid)
	else:
		var id: String = game.inv.eq[key]
		if id != "":
			it = Items.get_item(id)
	if not it.is_empty():
		show_tip(it, get_viewport().get_mouse_position(), cmp)

func tip_for_id(id: String) -> void:
	var it := Items.get_item(id)
	show_tip(it, get_viewport().get_mouse_position())

# ---------- yenileme ----------
func refresh() -> void:
	var inv = game.inv
	var lvl: int = game.P["lvl"]
	var held = game.held
	for i in 16:
		var s: ItemSlot = bag_slots[i]
		var e = inv.bag[i]
		s.item = {} if e == null else Items.get_item(e["id"])
		s.count = 0 if e == null else e["n"]
		s.dim = held != null and held["from"] == "bag" and held["i"] == i
		s.bad = not s.item.is_empty() and Items.is_equip(s.item) and lvl < s.item["req"]
		s.queue_redraw()
	for k in eq_slots:
		var s2: ItemSlot = eq_slots[k]
		var id: String = inv.eq[k]
		s2.item = {} if id == "" else Items.get_item(id)
		s2.count = 0
		s2.dim = held != null and held["from"] == "eq" and held["slot"] == k
		s2.bad = false
		s2.queue_redraw()
	money_lbl.text = Items.money_bb(inv.money)
	vend_money.text = "Paran: " + Items.money_bb(inv.money)
	var G: Dictionary = game.G
	char_name.text = "Seviye %d Cüce Savaşçı" % lvl
	char_portrait.lvl = lvl
	char_portrait.queue_redraw()
	var gk := "[color=#ffd100]%s[/color]  %d [color=#1eff00]%s[/color]\n"
	var bs: int = game.base_str()
	var ba: int = game.base_agi()
	var bst: int = game.base_sta()
	stats_l.text = (gk % ["Güç", bs + G["str"], "(+%d)" % G["str"] if G["str"] > 0 else ""]
		+ gk % ["Çeviklik", ba + G["agi"], "(+%d)" % G["agi"] if G["agi"] > 0 else ""]
		+ gk % ["Dayanıklılık", bst + G["sta"], "(+%d)" % G["sta"] if G["sta"] > 0 else ""]
		+ "[color=#ffd100]Zırh[/color]  %d" % G["armor"])
	stats_r.text = ("[color=#ffd100]Saldırı Gücü[/color]  %d\n" % roundi(game.atk() * 2.0)
		+ "[color=#ffd100]Hasar[/color]  %d-%d\n" % [roundi(G["wmin"]), roundi(G["wmax"])]
		+ "[color=#ffd100]Hız[/color]  %.2f\n" % G["wspd"]
		+ "[color=#ffd100]Kritik[/color]  %.1f%%" % (game.crit_chance() * 100.0))
	cursor.visible = held != null
	if held != null:
		var hid := ""
		if held["from"] == "bag":
			var he = inv.bag[held["i"]]
			hid = "" if he == null else he["id"]
		else:
			hid = inv.eq[held["slot"]]
		cursor.item = {} if hid == "" else Items.get_item(hid)
		cursor.queue_redraw()
	refresh_vendor()
	refresh_loot()

func _row(idx: int, it: Dictionary, title: String, price: int, n: int, red: bool, tcol: Color) -> Row:
	var r := Row.new()
	r.idx = idx
	r.item = it
	r.title = title
	r.price = price
	r.count = n
	r.price_red = red
	r.tcol = tcol
	return r

func refresh_vendor() -> void:
	if not vend_win.visible:
		return
	for c in vend_list.get_children():
		vend_list.remove_child(c)
		c.queue_free()
	var npc = game.vendor_npc
	if npc == null:
		return
	vend_title.text = npc["name"]
	for i in 2:
		(vend_tab_btns[i] as Button).disabled = (i == game.vendor_tab)
	var lvl: int = game.P["lvl"]
	if game.vendor_tab == 0:
		var list: Array = game.VENDORS[npc["id"]]
		for i in list.size():
			var it := Items.get_item(list[i])
			var cost := Items.buy_price(it)
			var tc: Color = Items.RARITY_COL[it["rar"]]
			if Items.is_equip(it) and lvl < it["req"]:
				tc = Color("ff4040")
			var r := _row(i, it, it["name"], cost, 1, game.inv.money < cost, tc)
			r.custom_minimum_size = Vector2(300, 40)
			r.clicked.connect(func(idx, b): game.ui_vendor_click(idx, b))
			r.hovered.connect(func(idx, on): _row_hover(it, on))
			vend_list.add_child(r)
	else:
		var bb: Array = game.inv.buyback
		for i in bb.size():
			var it2 := Items.get_item(bb[i]["id"])
			var r2 := _row(i, it2, it2["name"], bb[i]["price"], bb[i]["n"], game.inv.money < bb[i]["price"], Items.RARITY_COL[it2["rar"]])
			r2.clicked.connect(func(idx, b): game.ui_vendor_click(idx, b))
			r2.hovered.connect(func(idx, on): _row_hover(it2, on))
			vend_list.add_child(r2)
		if bb.is_empty():
			vend_list.add_child(_label("Sattığın eşyalar burada görünür.", 13, Color("9aa7b4")))

func refresh_loot() -> void:
	if not loot_win.visible:
		return
	for c in loot_list.get_children():
		loot_list.remove_child(c)
		c.queue_free()
	var m = game.loot_mob
	if m == null:
		return
	loot_title.text = m.nm
	var rows := 0
	if m.loot_money > 0:
		var r := _row(-1, {}, "", m.loot_money, 1, false, Color.WHITE)
		r.coin = true
		r.price = m.loot_money
		r.title = "Para"
		r.clicked.connect(func(idx, b): game.ui_loot_click(idx))
		loot_list.add_child(r)
		rows += 1
	for i in m.loot.size():
		var it := Items.get_item(m.loot[i]["id"])
		var r2 := _row(i, it, it["name"], -1, m.loot[i]["n"], false, Items.RARITY_COL[it["rar"]])
		r2.clicked.connect(func(idx, b): game.ui_loot_click(idx))
		r2.hovered.connect(func(idx, on): _row_hover(it, on))
		loot_list.add_child(r2)
		rows += 1
	loot_win.size = Vector2(324, 44 + rows * 43)

func _row_hover(it: Dictionary, on: bool) -> void:
	if on:
		var cmp := {}
		if Items.is_equip(it):
			var ts: String = game.inv.target_slot(it)
			var eqid: String = game.inv.eq[ts]
			if eqid != "":
				cmp = Items.get_item(eqid)
		show_tip(it, get_viewport().get_mouse_position(), cmp)
	else:
		hide_tip()
