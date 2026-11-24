extends Node3D
## Mermi Cehennemi: bağımsız "bullet heaven" modu (Vampire Survivors esintili).
## Ana kampanyadan tamamen ayrı; kendi kamerası, girişi, arenası ve
## ilerlemesi var. main.gd yalnızca başlatıp/bitiriyor, geri kalan her şey
## burada. Harita/arena tasarımı sonradan değişecek; şimdilik basit,
## sınırlı bir dairesel arena kullanılıyor.

const Dwarf = preload("res://dwarf.gd")
const TouchJoystick = preload("res://touch_joystick.gd")

var on_exit: Callable = Callable()
var shared_world_env: WorldEnvironment = null  ## main.gd'nin WorldEnvironment'ı; varsa onu yeniden kullanırız.

const ARENA_R := 46.0

const CHAR_DEFS := {
	"savasci": {"name": "Savaşçı Grum", "desc": "Can: Yüksek · Başlangıç: Dönen Balta", "hp": 140.0, "spd": 5.6, "dmg": 1.0, "weapon": "axe", "skin": {"metal": Color("8a6a3a"), "cloth": Color("7a2020")}},
	"izci": {"name": "İzci Fenna", "desc": "Hız: Yüksek · Başlangıç: Rün Cıvatası", "hp": 100.0, "spd": 6.8, "dmg": 1.0, "weapon": "bolt", "skin": {"metal": Color("3a6a4a"), "cloth": Color("2a5a3a")}},
	"buyucu": {"name": "Büyücü Odrin", "desc": "Büyü Gücü: Yüksek · Başlangıç: Toprak Patlaması", "hp": 90.0, "spd": 5.2, "dmg": 1.3, "weapon": "nova", "skin": {"metal": Color("4a3a7a"), "cloth": Color("3a2a6a")}},
}

const WEAPON_DEFS := {
	"axe": {"name": "Dönen Balta", "desc": "Etrafında dönen baltalar, temas edeni keser."},
	"bolt": {"name": "Rün Cıvatası", "desc": "En yakın düşmana otomatik mermi fırlatır."},
	"nova": {"name": "Toprak Patlaması", "desc": "Periyodik olarak çevrene alan hasarı verir."},
	"rain": {"name": "Ok Yağmuru", "desc": "Yakındaki düşmanların üstüne oklar yağdırır."},
}
const WEAPON_MAX := 5

const PASSIVE_DEFS := {
	"power": {"name": "Güç Taşı", "desc": "Hasar +%10"},
	"boots": {"name": "Hızlı Çizme", "desc": "Hız +%8"},
	"heart": {"name": "Dayanıklılık Kalbi", "desc": "Azami can +20"},
	"magnet": {"name": "Mıknatıs Taşı", "desc": "Toplama yarıçapı +%25"},
	"clock": {"name": "Zaman Kumu", "desc": "Tecrübe kazancı +%15"},
}
const PASSIVE_MAX := 5

var state := "charselect"  # charselect, play, levelup, gameover, paused
var char_id := ""
var P := {}
var weapons := {}   # id -> level
var passives := {}  # id -> level
var w_t := {}       # id -> sonraki ateşleme zamanlayıcısı

var player: Node3D
var walk_ph := 0.0
var cam: Camera3D
var ground: MeshInstance3D

var enemies: Array = []
var gems: Array = []
var bolts: Array = []   # uçan mermiler: {node, x, z, vx, vz, dmg, pierce, life}
var fx_list: Array = [] # geçici görsel efektler: {node, life, max_life, kind}

var t := 0.0
var spawn_t := 0.0
var kills := 0
var lvl := 1
var xp := 0.0
var xp_next := 8.0

var ui: CanvasLayer
var hp_bar: ProgressBar
var hp_lbl: Label
var xp_bar: ProgressBar
var lvl_lbl: Label
var timer_lbl: Label
var kills_lbl: Label
var levelup_box: Control
var gameover_box: Control
var charselect_box: Control
var weapon_row: HBoxContainer
var move_stick
var mobile_controls := false

func _ready() -> void:
	_build_arena()
	_build_camera()
	_build_ui()

func _exit_tree() -> void:
	pass

## ---------- Kurulum ----------

func _build_arena() -> void:
	var gm := PlaneMesh.new()
	gm.size = Vector2(ARENA_R * 2.6, ARENA_R * 2.6)
	ground = MeshInstance3D.new()
	ground.mesh = gm
	ground.material_override = Dwarf.mat(Color.html("3a4a30"), 0.0, 0.95)
	add_child(ground)
	for i in 28:
		var a := float(i) / 28.0 * TAU
		var r := ARENA_R + 1.5
		var rock := Dwarf.box(self, Vector3(1.6 + randf() * 1.2, 1.2 + randf() * 1.6, 1.6), Dwarf.mat(Color.html("55504a"), 0.0, 0.95), Vector3(cos(a) * r, 0.5, sin(a) * r))
		rock.rotation.y = randf() * TAU
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -35, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.html("1a2420")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color.html("3a4a40")
	env.ambient_light_energy = 0.9
	# İkinci bir WorldEnvironment eklemek yerine (aynı anda iki tane varsa hangisinin
	# geçerli olacağı belirsizleşiyor ve kampanyanın parlak gökyüzü/ton eşlemesi bu
	# arenayı eziyordu — ekranda yalnızca boş bir gökyüzü gradyanı görünüyordu),
	# main.gd'nin tek WorldEnvironment düğümünü burada yeniden kullanıyoruz.
	if shared_world_env != null:
		shared_world_env.environment = env
	else:
		var amb := WorldEnvironment.new()
		amb.environment = env
		add_child(amb)

func _build_camera() -> void:
	cam = Camera3D.new()
	cam.position = Vector3(0, 26, 15)
	cam.rotation_degrees = Vector3(-62, 0, 0)
	cam.fov = 50.0
	add_child(cam)
	cam.current = true

func _label(txt: String, size: int, col: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_constant_override("outline_size", 3)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	return l

func _btn(txt: String, size: int = 20) -> Button:
	var b := Button.new()
	b.text = txt
	b.add_theme_font_size_override("font_size", size)
	b.custom_minimum_size = Vector2(minf(260.0, get_viewport().get_visible_rect().size.x - 36.0), 0)
	return b

func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var top := Control.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.position = Vector2(0, 10)
	top.size = Vector2(0, 60)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(top)
	mobile_controls = DisplayServer.is_touchscreen_available() or get_viewport().get_visible_rect().size.x < 900.0
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_TOP_LEFT)
	vb.position = Vector2(12 if mobile_controls else 60, 10)
	vb.size = Vector2(minf(420.0, get_viewport().get_visible_rect().size.x - 24.0) if mobile_controls else 420.0, 70)
	ui.add_child(vb)
	var hrow := HBoxContainer.new()
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(minf(300.0, get_viewport().get_visible_rect().size.x - 120.0) if mobile_controls else 300.0, 18)
	hp_bar.max_value = 100.0
	hp_bar.show_percentage = false
	hrow.add_child(hp_bar)
	hp_lbl = _label("", 14)
	hrow.add_child(hp_lbl)
	vb.add_child(hrow)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(minf(300.0, get_viewport().get_visible_rect().size.x - 120.0) if mobile_controls else 300.0, 10)
	xp_bar.max_value = 100.0
	xp_bar.show_percentage = false
	vb.add_child(xp_bar)
	var hrow2 := HBoxContainer.new()
	lvl_lbl = _label("Sv.1", 16, Color("ffd23a"))
	hrow2.add_child(lvl_lbl)
	hrow2.add_theme_constant_override("separation", 16)
	kills_lbl = _label("0 öldürme", 16, Color("d9e2e8"))
	hrow2.add_child(kills_lbl)
	vb.add_child(hrow2)
	timer_lbl = _label("00:00", 30, Color.WHITE)
	timer_lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	timer_lbl.position = Vector2(-40, 12)
	ui.add_child(timer_lbl)
	weapon_row = HBoxContainer.new()
	weapon_row.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	weapon_row.position = Vector2(-220 if mobile_controls else -260, 82 if mobile_controls else 14)
	weapon_row.scale = Vector2.ONE * (0.72 if mobile_controls else 1.0)
	weapon_row.add_theme_constant_override("separation", 6)
	ui.add_child(weapon_row)
	if mobile_controls:
		move_stick = TouchJoystick.new()
		move_stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		move_stick.offset_left = 12
		move_stick.offset_top = -132
		move_stick.offset_right = 132
		move_stick.offset_bottom = -12
		ui.add_child(move_stick)
		var exit_btn := Button.new()
		exit_btn.text = "MENÜ"
		exit_btn.add_theme_font_size_override("font_size", 13)
		exit_btn.custom_minimum_size = Vector2(76, 48)
		exit_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		exit_btn.offset_left = -88
		exit_btn.offset_top = 12
		exit_btn.offset_right = -12
		exit_btn.offset_bottom = 60
		exit_btn.pressed.connect(_exit_run)
		ui.add_child(exit_btn)
	_build_charselect()
	_build_levelup()
	_build_gameover()

func _panel_bg(c: Control) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.05, 0.06, 0.93)
	sb.border_color = Color("c9a24a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(18)
	if c is PanelContainer:
		c.add_theme_stylebox_override("panel", sb)

## ---------- Karakter seçimi ----------

func _build_charselect() -> void:
	charselect_box = Control.new()
	charselect_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(charselect_box)
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.03, 0.04, 0.78)
	charselect_box.add_child(shade)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 14)
	charselect_box.add_child(vb)
	var t1 := _label("MERMİ CEHENNEMİ", 44, Color("ff6a4a"))
	t1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t1)
	var t2 := _label("Bir kahraman seç — sonsuz dalgalara karşı hayatta kal.", 18, Color("d5e1ea"))
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t2)
	var hb: BoxContainer = VBoxContainer.new() if get_viewport().get_visible_rect().size.x < 700.0 else HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10 if get_viewport().get_visible_rect().size.x < 700.0 else 20)
	vb.add_child(hb)
	for id in CHAR_DEFS:
		var cd: Dictionary = CHAR_DEFS[id]
		var card := PanelContainer.new()
		_panel_bg(card)
		var cv := VBoxContainer.new()
		cv.custom_minimum_size = Vector2(220, 0)
		card.add_child(cv)
		var nm := _label(String(cd["name"]), 18, Color("ffd23a"))
		nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(nm)
		var ds := _label(String(cd["desc"]), 13, Color("c7d0d8"))
		ds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ds.autowrap_mode = TextServer.AUTOWRAP_WORD
		cv.add_child(ds)
		var pb := _btn("SEÇ", 16)
		pb.pressed.connect(func(): _choose_char(id))
		cv.add_child(pb)
		hb.add_child(card)
	var back := _btn("Ana Menüye Dön", 14)
	back.pressed.connect(func(): _exit_run())
	vb.add_child(back)

func _choose_char(id: String) -> void:
	char_id = id
	var cd: Dictionary = CHAR_DEFS[id]
	P = {"x": 0.0, "z": 0.0, "yaw": 0.0, "hp": float(cd["hp"]), "maxhp": float(cd["hp"]), "spd": float(cd["spd"]), "dmg": float(cd["dmg"]),
		"dmg_mult": 1.0, "spd_mult": 1.0, "pickup_r": 3.2, "xp_mult": 1.0, "armor": 0.0}
	weapons = {String(cd["weapon"]): 1}
	passives = {}
	w_t = {}
	player = Dwarf.make_dwarf(cd.get("skin", {}))
	add_child(player)
	charselect_box.visible = false
	state = "play"
	if is_instance_valid(move_stick):
		move_stick.visible = true
	_update_weapon_icons()
	_update_top_ui()

## ---------- Seviye atlama ----------

func _build_levelup() -> void:
	levelup_box = Control.new()
	levelup_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	levelup_box.visible = false
	ui.add_child(levelup_box)

func _rebuild_levelup_cards() -> void:
	for c in levelup_box.get_children():
		c.queue_free()
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.03, 0.04, 0.78)
	levelup_box.add_child(shade)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.add_theme_constant_override("separation", 14)
	levelup_box.add_child(vb)
	vb.add_child(_label("SEVİYE ATLADIN!", 30, Color("ffd23a")))
	var hb: BoxContainer = VBoxContainer.new() if get_viewport().get_visible_rect().size.x < 700.0 else HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10 if get_viewport().get_visible_rect().size.x < 700.0 else 18)
	vb.add_child(hb)
	for opt in _roll_levelup_options():
		var card := PanelContainer.new()
		_panel_bg(card)
		var cv := VBoxContainer.new()
		cv.custom_minimum_size = Vector2(minf(230.0, get_viewport().get_visible_rect().size.x - 40.0), 0)
		card.add_child(cv)
		cv.add_child(_label(String(opt["name"]), 17, Color("ffd23a")))
		cv.add_child(_label(String(opt["sub"]), 13, Color("93d4a0")))
		var ds := _label(String(opt["desc"]), 13, Color("c7d0d8"))
		ds.autowrap_mode = TextServer.AUTOWRAP_WORD
		cv.add_child(ds)
		var pb := _btn("SEÇ", 15)
		pb.pressed.connect(func(): _pick_levelup(opt))
		cv.add_child(pb)
		hb.add_child(card)

func _roll_levelup_options() -> Array:
	var pool: Array = []
	for wid in WEAPON_DEFS:
		var wl: int = int(weapons.get(wid, 0))
		if wl == 0:
			pool.append({"kind": "w", "id": wid, "name": String(WEAPON_DEFS[wid]["name"]), "sub": "Yeni Silah", "desc": String(WEAPON_DEFS[wid]["desc"])})
		elif wl < WEAPON_MAX:
			pool.append({"kind": "w", "id": wid, "name": String(WEAPON_DEFS[wid]["name"]), "sub": "Seviye %d → %d" % [wl, wl + 1], "desc": String(WEAPON_DEFS[wid]["desc"])})
	for pid in PASSIVE_DEFS:
		var pl: int = int(passives.get(pid, 0))
		if pl == 0:
			pool.append({"kind": "p", "id": pid, "name": String(PASSIVE_DEFS[pid]["name"]), "sub": "Yeni Eşya", "desc": String(PASSIVE_DEFS[pid]["desc"])})
		elif pl < PASSIVE_MAX:
			pool.append({"kind": "p", "id": pid, "name": String(PASSIVE_DEFS[pid]["name"]), "sub": "Seviye %d → %d" % [pl, pl + 1], "desc": String(PASSIVE_DEFS[pid]["desc"])})
	pool.shuffle()
	return pool.slice(0, mini(3, pool.size()))

func _pick_levelup(opt: Dictionary) -> void:
	if opt["kind"] == "w":
		weapons[opt["id"]] = int(weapons.get(opt["id"], 0)) + 1
	else:
		passives[opt["id"]] = int(passives.get(opt["id"], 0)) + 1
		_apply_passives()
	levelup_box.visible = false
	state = "play"
	if is_instance_valid(move_stick):
		move_stick.visible = true
	_update_weapon_icons()

func _apply_passives() -> void:
	var dm := 1.0
	var sm := 1.0
	var pr := 3.2
	var xm := 1.0
	var hp_bonus := 0.0
	for pid in passives:
		var lv: int = int(passives[pid])
		match pid:
			"power": dm += 0.10 * lv
			"boots": sm += 0.08 * lv
			"heart": hp_bonus += 20.0 * lv
			"magnet": pr *= (1.0 + 0.25 * lv)
			"clock": xm += 0.15 * lv
	var old_bonus: float = float(P.get("_hpbonus", 0.0))
	P["dmg_mult"] = dm
	P["spd_mult"] = sm
	P["pickup_r"] = pr
	P["xp_mult"] = xm
	P["_hpbonus"] = hp_bonus
	P["maxhp"] = float(CHAR_DEFS[char_id]["hp"]) + hp_bonus
	P["hp"] = minf(P["maxhp"], P["hp"] + (hp_bonus - old_bonus))

## ---------- Oyun sonu ----------

func _build_gameover() -> void:
	gameover_box = Control.new()
	gameover_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	gameover_box.visible = false
	ui.add_child(gameover_box)

func _show_gameover() -> void:
	for c in gameover_box.get_children():
		c.queue_free()
	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.02, 0.03, 0.85)
	gameover_box.add_child(shade)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.add_theme_constant_override("separation", 12)
	gameover_box.add_child(vb)
	vb.add_child(_label("DÜŞTÜN", 40, Color("ff5a4a")))
	var mm := int(t) / 60
	var ss := int(t) % 60
	vb.add_child(_label("Süre: %02d:%02d" % [mm, ss], 20, Color.WHITE))
	vb.add_child(_label("Seviye: %d" % lvl, 20, Color.WHITE))
	vb.add_child(_label("Öldürme: %d" % kills, 20, Color.WHITE))
	var again := _btn("TEKRAR DENE", 18)
	again.pressed.connect(func(): _restart_run())
	vb.add_child(again)
	var back := _btn("ANA MENÜYE DÖN", 18)
	back.pressed.connect(func(): _exit_run())
	vb.add_child(back)
	gameover_box.visible = true
	state = "gameover"
	if is_instance_valid(move_stick):
		move_stick.visible = false

func _restart_run() -> void:
	for e in enemies:
		if is_instance_valid(e["node"]):
			e["node"].queue_free()
	enemies.clear()
	for g in gems:
		if is_instance_valid(g["node"]):
			g["node"].queue_free()
	gems.clear()
	for b in bolts:
		if is_instance_valid(b["node"]):
			b["node"].queue_free()
	bolts.clear()
	for f in fx_list:
		if is_instance_valid(f["node"]):
			f["node"].queue_free()
	fx_list.clear()
	if player != null and is_instance_valid(player):
		player.queue_free()
	t = 0.0
	spawn_t = 0.0
	kills = 0
	lvl = 1
	xp = 0.0
	xp_next = 8.0
	gameover_box.visible = false
	_choose_char(char_id)

func _exit_run() -> void:
	if on_exit.is_valid():
		on_exit.call()

## ---------- Ana döngü ----------

func _process(delta: float) -> void:
	var dt := minf(delta, 0.05)
	if state == "play":
		_tick_play(dt)
	_update_cam()

func _update_cam() -> void:
	if player == null:
		return
	var target := Vector3(P["x"], 26, P["z"] + 15.0)
	cam.position = cam.position.lerp(target, 0.12)

func _tick_play(dt: float) -> void:
	t += dt
	_move_player(dt)
	_fire_weapons(dt)
	_update_bolts(dt)
	_update_enemies(dt)
	_update_gems(dt)
	_update_fx(dt)
	_spawn_wave(dt)
	_update_top_ui()
	if int(t) != int(t - dt):
		timer_lbl.text = "%02d:%02d" % [int(t) / 60, int(t) % 60]

func _move_player(dt: float) -> void:
	var ix := 0.0
	var iz := 0.0
	if is_instance_valid(move_stick) and move_stick.visible:
		ix += move_stick.vector.x
		iz += move_stick.vector.y
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		ix -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		ix += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		iz -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		iz += 1.0
	var v := Vector2(ix, iz)
	var moving := v.length() > 0.01
	if moving:
		v = v.normalized()
		var sp: float = float(P["spd"]) * float(P["spd_mult"])
		P["x"] += v.x * sp * dt
		P["z"] += v.y * sp * dt
		var d := Vector2(P["x"], P["z"]).length()
		if d > ARENA_R:
			var nrm := Vector2(P["x"], P["z"]).normalized()
			P["x"] = nrm.x * ARENA_R
			P["z"] = nrm.y * ARENA_R
		P["yaw"] = atan2(v.x, v.y) + PI
		walk_ph += dt * sp * 0.9
	player.position = Vector3(P["x"], 0.0, P["z"])
	player.rotation.y = P["yaw"]
	var rig: Dictionary = player.get_meta("rig", {})
	if rig.has("legL") and rig.has("legR"):
		var sw := sin(walk_ph) * (0.7 if moving else 0.0)
		rig["legL"].rotation.x = sw
		rig["legR"].rotation.x = -sw

## ---------- Düşman dalgaları ----------

func _enemy_tier() -> String:
	if t > 240.0:
		return "bear"
	if t > 100.0:
		return "boar"
	return "wolf"

func _spawn_wave(dt: float) -> void:
	spawn_t -= dt
	if spawn_t > 0.0:
		return
	var rate: float = maxf(0.18, 0.95 - t * 0.012)
	spawn_t = rate
	var n: int = 1 + int(t / 45.0)
	for i in n:
		_spawn_enemy()

func _spawn_enemy() -> void:
	var a := randf() * TAU
	var r := ARENA_R * 1.05
	var x: float = float(P["x"]) + cos(a) * r
	var z: float = float(P["z"]) + sin(a) * r
	var kind := _enemy_tier()
	var node: Node3D
	match kind:
		"boar": node = Dwarf.make_boar()
		"bear": node = Dwarf.make_bear()
		_: node = Dwarf.make_wolf()
	add_child(node)
	var hp_scale: float = 1.0 + t * 0.03
	var base_hp: float = {"wolf": 10.0, "boar": 16.0, "bear": 34.0}[kind]
	var base_dmg: float = {"wolf": 4.0, "boar": 6.0, "bear": 10.0}[kind]
	var base_spd: float = {"wolf": 3.6, "boar": 3.0, "bear": 2.6}[kind]
	enemies.append({"node": node, "x": x, "z": z, "hp": float(base_hp) * hp_scale, "maxhp": float(base_hp) * hp_scale,
		"dmg": float(base_dmg), "spd": float(base_spd), "hit_cd": 0.0, "walk_ph": randf() * TAU, "legs": node.get_meta("legs", [])})

func _update_enemies(dt: float) -> void:
	var i := enemies.size() - 1
	while i >= 0:
		var e: Dictionary = enemies[i]
		if not is_instance_valid(e["node"]):
			enemies.remove_at(i)
			i -= 1
			continue
		if e.get("dead", false):
			var gx: float = e["x"]
			var gz: float = e["z"]
			e["node"].queue_free()
			_spawn_gem(gx, gz, 2.0 + randf() * 2.0)
			kills += 1
			enemies.remove_at(i)
			i -= 1
			continue
		var dx: float = P["x"] - e["x"]
		var dz: float = P["z"] - e["z"]
		var d: float = Vector2(dx, dz).length()
		if d > 0.01:
			var sp: float = e["spd"]
			e["x"] += dx / d * sp * dt
			e["z"] += dz / d * sp * dt
		e["node"].position = Vector3(e["x"], 0.0, e["z"])
		e["node"].rotation.y = atan2(dx, dz) + PI
		var legs: Array = e["legs"]
		if legs.size() >= 2:
			e["walk_ph"] += dt * e["spd"] * 1.1
			var sw := sin(e["walk_ph"]) * 0.7
			legs[0].rotation.x = sw
			legs[1].rotation.x = -sw
		e["hit_cd"] = maxf(0.0, e["hit_cd"] - dt)
		if d < 1.0 and e["hit_cd"] <= 0.0:
			e["hit_cd"] = 0.6
			_damage_player(e["dmg"])
		enemies[i] = e
		i -= 1

func _damage_player(v: float) -> void:
	P["hp"] -= maxf(1.0, v - float(P.get("armor", 0.0)))
	if P["hp"] <= 0.0 and state == "play":
		P["hp"] = 0.0
		_show_gameover()

## ---------- Silahlar ----------

func _fire_weapons(dt: float) -> void:
	for wid in weapons:
		var lv: int = int(weapons[wid])
		var tleft: float = float(w_t.get(wid, 0.0)) - dt
		if wid == "axe":
			_tick_axe(lv, dt)
			continue
		if tleft > 0.0:
			w_t[wid] = tleft
			continue
		match wid:
			"bolt":
				w_t[wid] = maxf(0.22, 0.85 - lv * 0.09)
				_fire_bolt(lv)
			"nova":
				w_t[wid] = maxf(0.9, 2.0 - lv * 0.18)
				_fire_nova(lv)
			"rain":
				w_t[wid] = maxf(0.8, 1.9 - lv * 0.16)
				_fire_rain(lv)

var axe_ph := 0.0
func _tick_axe(lv: int, dt: float) -> void:
	axe_ph += dt * 2.6
	var n: int = 1 + lv
	var r := 2.4
	var dmg: float = 7.0 * float(P["dmg_mult"]) * (1.0 + 0.25 * lv)
	for k in n:
		var ang := axe_ph + TAU * float(k) / float(n)
		var ax: float = float(P["x"]) + cos(ang) * r
		var az: float = float(P["z"]) + sin(ang) * r
		for e in enemies:
			if Vector2(e["x"] - ax, e["z"] - az).length() < 0.9:
				_hit_enemy(e, dmg * dt * 2.5)

func _nearest_enemy_to(x: float, z: float) -> Dictionary:
	var best: Dictionary = {}
	var bd := 1e9
	for e in enemies:
		var d: float = Vector2(e["x"] - x, e["z"] - z).length()
		if d < bd:
			bd = d
			best = e
	return best

func _fire_bolt(lv: int) -> void:
	var target: Dictionary = _nearest_enemy_to(P["x"], P["z"])
	if target.is_empty():
		return
	var dx: float = target["x"] - P["x"]
	var dz: float = target["z"] - P["z"]
	var d: float = Vector2(dx, dz).length()
	if d < 0.01:
		return
	var node := Dwarf.sph(self, 0.18, Dwarf.mat(Color.html("8a3aff"), 0.0, 0.3, Color.html("9a50ff"), 2.4), Vector3(P["x"], 1.0, P["z"]))
	bolts.append({"node": node, "x": P["x"], "z": P["z"], "vx": dx / d * 11.0, "vz": dz / d * 11.0,
		"dmg": 9.0 * float(P["dmg_mult"]) * (1.0 + 0.3 * lv), "pierce": 1 + lv / 2, "life": 2.2})

func _update_bolts(dt: float) -> void:
	var i := bolts.size() - 1
	while i >= 0:
		var b: Dictionary = bolts[i]
		b["x"] += b["vx"] * dt
		b["z"] += b["vz"] * dt
		b["life"] -= dt
		if is_instance_valid(b["node"]):
			b["node"].position = Vector3(b["x"], 1.0, b["z"])
		var hit := false
		for e in enemies:
			if Vector2(e["x"] - b["x"], e["z"] - b["z"]).length() < 0.7:
				_hit_enemy(e, b["dmg"])
				b["pierce"] -= 1
				hit = true
				break
		if b["life"] <= 0.0 or (hit and b["pierce"] <= 0):
			if is_instance_valid(b["node"]):
				b["node"].queue_free()
			bolts.remove_at(i)
			i -= 1
			continue
		bolts[i] = b
		i -= 1

func _fire_nova(lv: int) -> void:
	var r := 3.0 + 0.4 * lv
	var dmg: float = 10.0 * float(P["dmg_mult"]) * (1.0 + 0.3 * lv)
	for e in enemies:
		if Vector2(e["x"] - P["x"], e["z"] - P["z"]).length() < r:
			_hit_enemy(e, dmg)
	var ring := Dwarf.cyl(self, r, r, 0.08, Dwarf.mat(Color.html("ff8a3a"), 0.0, 0.4, Color.html("ff6a1a"), 2.0), Vector3(P["x"], 0.08, P["z"]))
	fx_list.append({"node": ring, "life": 0.3, "max_life": 0.3, "kind": "nova"})

func _fire_rain(lv: int) -> void:
	var n: int = mini(3 + lv, enemies.size())
	var pool := enemies.duplicate()
	pool.sort_custom(func(a, b): return Vector2(a["x"] - P["x"], a["z"] - P["z"]).length() < Vector2(b["x"] - P["x"], b["z"] - P["z"]).length())
	var dmg: float = 8.0 * float(P["dmg_mult"]) * (1.0 + 0.3 * lv)
	for k in n:
		var e: Dictionary = pool[k]
		_hit_enemy(e, dmg)
		var mark := Dwarf.cone(self, 0.3, 0.6, Dwarf.mat(Color.html("ffd23a"), 0.0, 0.3, Color.html("ffd23a"), 1.6), Vector3(e["x"], 1.6, e["z"]))
		mark.rotation.x = PI
		fx_list.append({"node": mark, "life": 0.25, "max_life": 0.25, "kind": "rain"})

func _update_fx(dt: float) -> void:
	var i := fx_list.size() - 1
	while i >= 0:
		var f: Dictionary = fx_list[i]
		f["life"] -= dt
		if f["life"] <= 0.0:
			if is_instance_valid(f["node"]):
				f["node"].queue_free()
			fx_list.remove_at(i)
			i -= 1
			continue
		if is_instance_valid(f["node"]) and f["kind"] == "nova":
			var k: float = 1.0 - f["life"] / f["max_life"]
			f["node"].scale = Vector3.ONE * (1.0 + k * 0.4)
		fx_list[i] = f
		i -= 1

## Düşmanı doğrudan dizi'den silmek yerine "dead" olarak işaretliyoruz; asıl
## silme/ganimet işlemi _update_enemies() içinde, tek ve güvenli bir geriye
## doğru döngüde yapılıyor. Böylece silahların kendi for-each döngüleri
## (_tick_axe, _update_bolts, _fire_nova, _fire_rain) enemies dizisini
## iterasyon sırasında değiştirmiş olmuyor.
func _hit_enemy(e: Dictionary, dmg: float) -> void:
	if e.get("dead", false):
		return
	e["hp"] -= dmg
	if e["hp"] <= 0.0:
		e["dead"] = true

func _spawn_gem(x: float, z: float, val: float) -> void:
	var node := Dwarf.sph(self, 0.14, Dwarf.mat(Color.html("4af0a0"), 0.0, 0.3, Color.html("30ffa0"), 2.2), Vector3(x, 0.5, z))
	gems.append({"node": node, "x": x, "z": z, "val": val})

func _update_gems(dt: float) -> void:
	var i := gems.size() - 1
	while i >= 0:
		var g: Dictionary = gems[i]
		var d: float = Vector2(g["x"] - P["x"], g["z"] - P["z"]).length()
		if d < float(P["pickup_r"]):
			var pull := 1.0 if d < 0.6 else minf(1.0, dt * 9.0)
			g["x"] = lerpf(g["x"], P["x"], pull)
			g["z"] = lerpf(g["z"], P["z"], pull)
			if is_instance_valid(g["node"]):
				g["node"].position = Vector3(g["x"], 0.5, g["z"])
			if d < 0.45:
				_gain_xp(g["val"])
				if is_instance_valid(g["node"]):
					g["node"].queue_free()
				gems.remove_at(i)
				i -= 1
				continue
		gems[i] = g
		i -= 1

func _gain_xp(v: float) -> void:
	xp += v * float(P["xp_mult"])
	while xp >= xp_next:
		xp -= xp_next
		lvl += 1
		xp_next = 8.0 * pow(1.16, lvl - 1)
		state = "levelup"
		if is_instance_valid(move_stick):
			move_stick.visible = false
		_rebuild_levelup_cards()
		levelup_box.visible = true

func _update_top_ui() -> void:
	hp_bar.max_value = P["maxhp"]
	hp_bar.value = P["hp"]
	hp_lbl.text = "%d / %d" % [maxi(0, roundi(P["hp"])), int(P["maxhp"])]
	xp_bar.max_value = xp_next
	xp_bar.value = xp
	lvl_lbl.text = "Sv.%d" % lvl
	kills_lbl.text = "%d öldürme" % kills

func _update_weapon_icons() -> void:
	for c in weapon_row.get_children():
		c.queue_free()
	for wid in weapons:
		var chip := PanelContainer.new()
		_panel_bg(chip)
		chip.custom_minimum_size = Vector2(0, 0)
		var l := _label("%s Lv%d" % [String(WEAPON_DEFS[wid]["name"]), int(weapons[wid])], 12, Color("ffd23a"))
		chip.add_child(l)
		weapon_row.add_child(chip)
	for pid in passives:
		var chip2 := PanelContainer.new()
		_panel_bg(chip2)
		var l2 := _label("%s Lv%d" % [String(PASSIVE_DEFS[pid]["name"]), int(passives[pid])], 12, Color("93d4a0"))
		chip2.add_child(l2)
		weapon_row.add_child(chip2)

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode == KEY_ESCAPE:
		if state == "play":
			_exit_run()
