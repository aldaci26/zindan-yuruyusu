extends Control
## Meslekler, İtibar ve Başarımlar penceresi (K).

const Prog = preload("res://prog.gd")
const Items = preload("res://items.gd")
const Skills = preload("res://systems/skills.gd")
const Journal = preload("res://systems/journal.gd")
const GOLD := Color("f2c75c")
const TABS := ["Beceriler", "Günlük", "Meslekler", "İtibar", "Başarımlar"]

var game
var win: Panel
var tab := 0
var tab_btns: Array = []
var box: VBoxContainer
var head: Label

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
	win.size = Vector2(500, 470)
	win.position = Vector2(-250, -235)
	add_child(win)
	head = _label("Karakter Gelişimi", 16, GOLD)
	head.autowrap_mode = TextServer.AUTOWRAP_OFF
	head.position = Vector2(14, 6)
	win.add_child(head)
	var x := Button.new()
	x.text = "X"
	x.focus_mode = Control.FOCUS_NONE
	x.position = Vector2(466, 5)
	x.size = Vector2(24, 22)
	x.pressed.connect(func(): game.toggle_win("prog"))
	win.add_child(x)
	for i in TABS.size():
		var b := Button.new()
		b.text = TABS[i]
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2(14 + i * 96, 34)
		b.size = Vector2(92, 26)
		b.pressed.connect(func():
			tab = i
			refresh())
		win.add_child(b)
		tab_btns.append(b)
	var sc := ScrollContainer.new()
	sc.position = Vector2(14, 70)
	sc.size = Vector2(472, 388)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	win.add_child(sc)
	box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(458, 0)
	box.add_theme_constant_override("separation", 6)
	sc.add_child(box)
	refresh()

func _label(t: String, sz: int, col: Color) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func _bar(v: float, mx: float, col: Color) -> ProgressBar:
	var p := ProgressBar.new()
	p.max_value = maxf(mx, 1.0)
	p.value = v
	p.show_percentage = false
	p.custom_minimum_size = Vector2(0, 8)
	var fill := StyleBoxFlat.new()
	fill.bg_color = col
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.1, 0.07)
	p.add_theme_stylebox_override("fill", fill)
	p.add_theme_stylebox_override("background", bg)
	return p

func _add(c: Control) -> void:
	box.add_child(c)

func refresh() -> void:
	if win == null or not win.visible:
		return
	for i in tab_btns.size():
		tab_btns[i].button_pressed = i == tab
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()
	match tab:
		0: _tab_skills()
		1: _tab_journal()
		2: _tab_profs()
		3: _tab_rep()
		_: _tab_ach()

func _tab_skills() -> void:
	var free: int = Skills.points_free(game.P["lvl"], game.P["skl"], game.P["perks"])
	_add(_label("Perk puanı: %d  (iki seviyede bir +1; seviyesi 30'a ulaşan her beceri +1)" % free, 12, Color("9be8a8") if free > 0 else Color("c8c8c8")))
	for sid in Skills.ORDER:
		var sd: Dictionary = Skills.SKILLS[sid]
		var lv: int = Skills.level_of(game.P["skl"], sid)
		_add(_label("%s  —  %d/%d" % [sd["name"], lv, Skills.MAX], 15, GOLD))
		_add(_bar(Skills.xp_of(game.P["skl"], sid) if lv < Skills.MAX else 1.0, Skills.need(lv) if lv < Skills.MAX else 1.0, Color("5aa0ff")))
		_add(_label(sd["use"] + " " + sd["per"], 11, Color("a8a8a8")))
		for pk in Skills.PERKS:
			if pk["skill"] != sid:
				continue
			var owned: bool = game.P["perks"].has(pk["id"])
			var why: String = Skills.can_take(game.P["lvl"], game.P["skl"], game.P["perks"], pk["id"])
			var b := Button.new()
			b.focus_mode = Control.FOCUS_NONE
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.add_theme_font_size_override("font_size", 12)
			b.custom_minimum_size = Vector2(0, 26)
			if owned:
				b.text = "✔ %s: %s" % [pk["name"], pk["desc"]]
				b.disabled = true
			else:
				b.text = "%s (Beceri %d): %s" % [pk["name"], pk["req"], pk["desc"]]
				b.disabled = why != ""
				b.tooltip_text = why
				var pid: String = pk["id"]
				b.pressed.connect(func(): game.take_perk(pid))
			_add(b)

func _tab_journal() -> void:
	var active: Array = []
	var done: Array = []
	for qid in game.qs:
		if game.qs[qid]["st"] == "done":
			done.append(qid)
		else:
			active.append(qid)
	_add(_label("Aktif görevler", 15, GOLD))
	if active.is_empty():
		_add(_label("Şu an aktif görevin yok. Şehirdeki ve karakoldaki görev verenlerle konuş.", 12, Color("a8a8a8")))
	for qid in active:
		var q: Dictionary = game.QUESTS[qid]
		var st: Dictionary = game.qs[qid]
		_add(_label("%s — %d/%d %s%s" % [q["title"], st["n"], q["n"], q["kill"], "  (Teslim et)" if st["st"] == "ready" else ""], 13, Color("7fe08a") if st["st"] == "ready" else Color("f6e8bb")))
		_add(_label(q["text"], 11, Color("b8b8b8")))
		_add(_label("Görev veren: " + Journal.giver(qid), 11, Color("7fb8ff")))
	_add(_label("Tamamlananlar (%d)" % done.size(), 15, GOLD))
	var names: Array = []
	for qid in done:
		names.append(game.QUESTS[qid]["title"])
	_add(_label(", ".join(names) if not names.is_empty() else "Henüz yok.", 11, Color("a8a8a8")))
	_add(_label("Keşfedilen bilgiler (%d/%d)" % [game.P["lore"].size(), Journal.LORE.size()], 15, GOLD))
	if game.P["lore"].is_empty():
		_add(_label("NPC'lerle 'Sohbet et' diyerek bilgi topla.", 11, Color("a8a8a8")))
	for lid in Journal.LORE:
		if game.P["lore"].has(lid):
			_add(_label(Journal.LORE[lid]["title"], 13, Color("c9a8ff")))
			_add(_label(Journal.LORE[lid]["text"], 11, Color("c8c8c8")))

func _tab_profs() -> void:
	for pid in Prog.PROFS:
		var pd: Dictionary = Prog.PROFS[pid]
		var known: bool = game.P["prof"].has(pid)
		var sk: int = game.P["prof"].get(pid, 0)
		var row := _label("%s  —  %s" % [pd["name"], ("%s %d/%d" % [Prog.skill_rank(sk), sk, Prog.SKILL_MAX]) if known else "öğrenilmedi"], 15, GOLD if known else Color("9a9a9a"))
		_add(row)
		if known:
			_add(_bar(sk, Prog.SKILL_MAX, Color("5ae07a")))
		_add(_label(pd["desc"] + ("" if known else "  Eğitmen: " + pd["trainer"] + "."), 12, Color("c8c8c8")))
	var any := false
	for pid in ["skin", "smith"]:
		if not game.P["prof"].has(pid):
			continue
		if not any:
			any = true
			_add(_label("Tarifler", 15, GOLD))
			var near: bool = game.can_craft_here()
			_add(_label("Üretim ocağı Demirkazan içindedir." if not near else "Ocağa yakınsın, üretebilirsin.", 12, Color("7fb8ff") if near else Color("ff9a6a")))
		for r in Prog.RECIPES:
			if r["prof"] != pid:
				continue
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 8)
			var out: Dictionary = Items.get_item(r["out"])
			var mats := []
			for mid in r["mats"]:
				var have: int = game.inv.count(mid)
				mats.append("%d/%d %s" % [mini(have, r["mats"][mid]), r["mats"][mid], Items.get_item(mid)["name"]])
			var lbl := _label("%s (Beceri %d)\n%s" % [out["name"], r["skill"], ", ".join(mats)], 12, Color("e0e0e0"))
			lbl.custom_minimum_size = Vector2(340, 0)
			hb.add_child(lbl)
			var bt := Button.new()
			bt.text = "Üret"
			bt.focus_mode = Control.FOCUS_NONE
			var err: String = game.craft_error(r["id"])
			bt.disabled = err != ""
			bt.tooltip_text = err
			var rid: String = r["id"]
			bt.pressed.connect(func(): game.craft(rid))
			hb.add_child(bt)
			_add(hb)

func _tab_rep() -> void:
	for fid in Prog.FACTIONS:
		var fd: Dictionary = Prog.FACTIONS[fid]
		var rep: int = game.P["rep"].get(fid, 0)
		var rk := Prog.rank_of(rep)
		_add(_label("%s  —  %s" % [fd["name"], Prog.RANKS[rk][0]], 15, fd["col"]))
		if rk < Prog.RANKS.size() - 1:
			var lo: int = Prog.RANKS[rk][1]
			var hi: int = Prog.RANKS[rk + 1][1]
			_add(_bar(rep - lo, hi - lo, fd["col"]))
			_add(_label("%d / %d (sonraki: %s)" % [rep, hi, Prog.RANKS[rk + 1][0]], 12, Color("c8c8c8")))
		else:
			_add(_bar(1, 1, fd["col"]))
			_add(_label("%d — en yüksek itibar" % rep, 12, Color("ffe45c")))
		var dc: float = Prog.DISCOUNT[rk]
		_add(_label("Satıcı indirimi: %%%d" % roundi(dc * 100.0), 12, Color("9be8a8") if dc > 0.0 else Color("8a8a8a")))
	_add(_label("Görevleri teslim ederek ve bölgenin düşmanlarını yenerek itibar kazanırsın. Dost ve üstü olunca o gruptaki satıcılar indirim yapar.", 12, Color("a8a8a8")))

func _tab_ach() -> void:
	var tot := 0
	var got := 0
	for a in Prog.ACHS:
		tot += int(a["pts"])
		if game.P["ach"].has(a["id"]):
			got += int(a["pts"])
	_add(_label("Başarım puanı: %d / %d" % [got, tot], 15, GOLD))
	for a in Prog.ACHS:
		var done: bool = game.P["ach"].has(a["id"])
		var v: int = game.ach_value(a)
		var goal: int = a["goal"]
		_add(_label("%s%s  (%d puan)" % ["✔ " if done else "", a["name"], a["pts"]], 14, Color("ffe45c") if done else Color("c8c8c8")))
		_add(_label("%s   %d/%d" % [a["desc"], mini(v, goal), goal], 12, Color("9a9a9a") if not done else Color("b8c8a8")))
