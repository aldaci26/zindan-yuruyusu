extends Node3D
## Cüce Savaşçı: ana sahne. Tüm dünya kodla kurulur.

const Dwarf = preload("res://dwarf.gd")
const Tex = preload("res://tex.gd")
const HudScript = preload("res://hud.gd")
const SfxScript = preload("res://sfx.gd")
const Items = preload("res://items.gd")
const Inv = preload("res://inv.gd")
const InvUI = preload("res://invui.gd")

const WORLD_R := 92.0
const CITY := {"x": 0.0, "z": -58.0, "r": 24.0, "y": 3.0}

const MTYPES := {
	"wolf": {"name": "Kurt", "lo": 1, "hi": 3, "hp": 26.0, "dmg": 2.2, "spd": 4.6, "aggro": 9.0, "rad": 0.7, "sc": 1.0},
	"boar": {"name": "Yaban Domuzu", "lo": 2, "hi": 4, "hp": 34.0, "dmg": 2.4, "spd": 3.8, "aggro": 7.0, "rad": 0.8, "sc": 1.0},
	"bear": {"name": "Dağ Ayısı", "lo": 4, "hi": 6, "hp": 46.0, "dmg": 2.8, "spd": 3.6, "aggro": 8.0, "rad": 1.1, "sc": 1.15},
}

const QUESTS := {
	"q_wolf": {"title": "Kurt Sürüsü", "kill": "Kurt", "n": 4, "lvl": 1, "xp": 90, "money": 250, "rew": ["axe_wolf", "bk_fur", "nk_tooth"],
		"text": "Vadide kurtlar çoğaldı, sürüler köye yaklaşıyor. Dört kurdu avla, köy sana minnettar kalır.", "done": "Sürü dağıldı, teşekkürler. İşte ödülün."},
	"q_boar": {"title": "Domuz İstilası", "kill": "Yaban Domuzu", "n": 4, "lvl": 2, "xp": 170, "money": 450, "rew": ["axe_boar", "so_boar", "ft_iron"],
		"text": "Yaban domuzları kapının önündeki yolu çiğniyor. Dört tanesini durdur.", "done": "Yol yeniden güvenli. Demirkazan sana borçlu."},
	"q_bear": {"title": "Dağın Efendisi", "kill": "Dağ Ayısı", "n": 2, "lvl": 3, "xp": 340, "money": 900, "rew": ["helm_bear", "bk_bear", "sh_deep"],
		"text": "Dağ ayıları ocak ekiplerimizi korkutuyor. İki ayıyı alt et, cephaneliğimden bir şey seçersin.", "done": "Gerçek bir savaşçısın. Cephanelikten birini seç."},
}

## WoW bosları: ad, seviye, can, hasar, ganimet ve yetenekler _boss_ai içinde.
const BOSSES := {
	"arctikus": {"name": "Büyük Baba Arctikus", "title": "Kar Dağı Efendisi", "lvl": 6, "hp": 2600.0, "dmg": 24.0, "spd": 4.2, "rad": 1.7, "sc": 1.7, "aggro": 12.0,
		"x": -62.0, "z": 38.0, "model": "bear", "kind": "bear", "respawn": 300.0, "xp": 160,
		"say": "Büyük Baba Arctikus kükreyerek saldırıya geçti!", "drops": ["wt_arc", "hd_arc", "bk_arc"]},
	"grik": {"name": "Grik'nir the Cold", "title": "Trogg Reisi", "lvl": 5, "hp": 2000.0, "dmg": 19.0, "spd": 3.6, "rad": 1.0, "sc": 1.5, "aggro": 12.0,
		"x": 66.0, "z": 40.0, "model": "trogg", "kind": "skull", "respawn": 300.0, "xp": 130,
		"say": "Grik'nir: Buzzz! Donacaksınız!", "drops": ["axe_grik", "nk_grik"]},
	"choksul": {"name": "Chok'sul", "title": "Ogre Savaş Başı", "lvl": 7, "hp": 3400.0, "dmg": 30.0, "spd": 3.4, "rad": 1.4, "sc": 1.5, "aggro": 12.0,
		"x": -70.0, "z": -28.0, "model": "ogre", "kind": "skull", "respawn": 300.0, "xp": 200,
		"say": "Chok'sul: Ezin! Hepsini ezin!", "drops": ["hammer_chok", "wt_chok"]},
	"hogger": {"name": "Hogger", "title": "Gnoll Elebaşı", "lvl": 8, "hp": 4400.0, "dmg": 28.0, "spd": 4.0, "rad": 1.1, "sc": 1.6, "aggro": 12.0,
		"x": 62.0, "z": -38.0, "model": "gnoll", "kind": "skull", "respawn": 300.0, "xp": 280,
		"say": "Hogger: Grrr... Taze et! Yiiipe!", "drops": ["lg_hogger", "wr_hogger", "tr_hogger"]},
	"vancleef": {"name": "Edwin VanCleef", "title": "Defias Elebaşı", "lvl": 9, "hp": 6500.0, "dmg": 30.0, "spd": 4.4, "rad": 0.9, "sc": 1.3, "aggro": 12.0,
		"x": -40.0, "z": 70.0, "model": "vancleef", "kind": "dwarf", "respawn": 360.0, "xp": 400,
		"say": "VanCleef: Beni durduramazsınız! Muhafızlar, saldırın!", "drops": ["sword_cruel", "helm_defias", "bk_edwin", "rg_vc"]},
	"ragnaros": {"name": "Ragnaros", "title": "Ateş Efendisi", "lvl": 10, "hp": 24000.0, "dmg": 60.0, "spd": 0.0, "rad": 4.6, "sc": 1.0, "aggro": 0.0, "reach": 1.9, "yoff": 1.3,
		"x": 0.0, "z": -64.0, "model": "ragnaros", "kind": "skull", "respawn": 600.0, "xp": 900,
		"say": "Ragnaros: SİZİ KÜÇÜK FANİLER! ATEŞİMDE YANACAKSINIZ!", "drops": ["helm_rag", "ch_rag", "tr_core"]},
}

const VENDORS := {
	"hilda": ["pot_heal", "pot_big", "helm_cap", "helm_iron", "so_pad", "so_iron", "bk_cloak", "ch_leather", "ch_mail", "wr_cloth", "wr_iron",
		"hd_glove", "hd_iron", "wt_belt", "wt_iron", "lg_leather", "lg_mail", "ft_hide", "ft_iron", "rg_iron", "nk_tooth"],
	"borga": ["axe_iron", "axe_forge", "axe_boar", "hammer_smith", "sword_gate", "sh_iron", "sh_gate", "sh_rein", "tr_whet"],
}

class Mob:
	var kind: String
	var nm: String
	var lvl: int
	var x: float
	var z: float
	var hx: float
	var hz: float
	var yaw: float
	var maxhp: float
	var hp: float
	var dmg: float
	var spd: float
	var aggro: float
	var rad: float
	var sc: float
	var state := "idle"
	var dead := false
	var died_at := 0.0
	var atk_t := 1.0
	var stun := 0.0
	var w_t := 0.0
	var wx: float
	var wz: float
	var ph := 0.0
	var lunge := 0.0
	var bleed_t := 0.0
	var bleed_tick := 0.0
	var bleed_v := 0.0
	var slow := 0.0
	var loot: Array = []
	var loot_money := 0
	var fade_t := 0.0
	var sparkle: MeshInstance3D
	var boss := ""
	var title := ""
	var reach := 1.3
	var yoff := 0.0
	var temp := false
	var gc := false
	var engaged := false
	var respawn := 32.0
	var cd := {}
	var flags := {}
	var eat_t := 0.0
	var atk_int := 2.0
	var base_dmg := 0.0
	var base_spd := 0.0
	var owner_m = null
	var node: Node3D
	var legs: Array = []
	var id: int

# ---------- durum ----------
var hud
var sfx
var paused := false
var inv
var invui
var held = null
var G := {}
var vendor_npc = null
var vendor_tab := 0
var loot_mob = null
var next_id := 100
var save_t := 0.0
const SAVE_PATH := "user://cuce_save.json"
var cam: Camera3D
var sun: DirectionalLight3D
var player: Node3D
var rig: Dictionary
var P := {}
var mobs: Array = []
var npcs: Array = []
var obs: Array = []
var qs := {}
var T := 0.0
var mode := "title"
var cam_yaw := 0.0
var cam_pitch := 0.34
var cam_dist := 8.5
var rmb := false
var dlg_open := false
var cur_npc = null
var last_rest := -999.0
var zone_now := ""
var swing_t := 0.0
var walk_ph := 0.0
var snow_node: GPUParticles3D
var lava_mat: StandardMaterial3D
var fire_light: OmniLight3D
var forge_light: OmniLight3D
var gate_light: OmniLight3D
var flame_nodes: Array = []
var rings: Array = []
var m_stone: StandardMaterial3D
var m_wood: StandardMaterial3D
var m_roof: StandardMaterial3D
var m_cobble: StandardMaterial3D
var m_gold: StandardMaterial3D
var m_bronze: StandardMaterial3D
var m_snow: StandardMaterial3D
var m_blue: StandardMaterial3D

# ---------- arazi gürültüsü ----------
func hash2(x: float, y: float) -> float:
	var h := sin(x * 127.1 + y * 311.7) * 43758.5453
	return h - floorf(h)

func vn(x: float, y: float) -> float:
	var xi := floorf(x)
	var yi := floorf(y)
	var xf := x - xi
	var yf := y - yi
	var u := xf * xf * (3.0 - 2.0 * xf)
	var v := yf * yf * (3.0 - 2.0 * yf)
	var a := hash2(xi, yi)
	var b := hash2(xi + 1.0, yi)
	var c := hash2(xi, yi + 1.0)
	var d := hash2(xi + 1.0, yi + 1.0)
	return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v

func height_at(x: float, z: float) -> float:
	var h := vn(x * 0.03, z * 0.03) * 16.0 + vn(x * 0.08, z * 0.08) * 4.5 + vn(x * 0.21, z * 0.21) * 0.9 - 9.0
	var d := sqrt(x * x + z * z)
	var flat := clampf((d - 13.0) / 18.0, 0.0, 1.0)
	flat = flat * flat * (3.0 - 2.0 * flat)
	var edge := maxf(0.0, (d - 78.0) / 20.0)
	var res := h * flat + edge * edge * 20.0
	var dc := sqrt((x - CITY.x) * (x - CITY.x) + (z - CITY.z) * (z - CITY.z))
	var cf := clampf((dc - CITY.r) / 12.0, 0.0, 1.0)
	cf = cf * cf * (3.0 - 2.0 * cf)
	return res * cf + CITY.y * (1.0 - cf)

# ---------- kurulum ----------
func _ready() -> void:
	randomize()
	m_stone = _tmat(Tex.stone(), 0.22, 0.0, 0.9)
	m_wood = _tmat(Tex.wood(), 0.4, 0.0, 0.85)
	m_roof = _tmat(Tex.roof(), 0.3, 0.0, 0.8)
	m_cobble = _tmat(Tex.cobble(), 0.25, 0.0, 0.95)
	m_gold = Dwarf.mat(Color.html("e6b440"), 0.85, 0.28)
	m_bronze = Dwarf.mat(Color.html("b8782e"), 0.7, 0.4)
	m_snow = Dwarf.mat(Color.html("f4f8ff"), 0.0, 0.9)
	m_blue = Dwarf.mat(Color.html("2a55b8"), 0.0, 0.85)
	m_blue.cull_mode = BaseMaterial3D.CULL_DISABLED
	_setup_environment()
	_build_terrain()
	_build_mountains()
	_build_forest()
	_build_village()
	_build_city()
	_spawn_player()
	_spawn_npcs()
	_spawn_mobs()
	_spawn_bosses()
	_setup_snow()
	hud = HudScript.new()
	add_child(hud)
	invui = InvUI.new()
	invui.game = self
	hud.add_child(invui)
	hud.bag_pressed.connect(func(): toggle_win("bag"))
	hud.char_pressed.connect(func(): toggle_win("char"))
	inv_changed()
	hud.start_pressed.connect(_on_start)
	hud.ability_pressed.connect(ability)
	hud.resume_pressed.connect(toggle_pause)
	hud.quit_pressed.connect(func():
		save_game()
		get_tree().quit())
	hud.fullscreen_pressed.connect(toggle_fullscreen)
	sfx = SfxScript.new()
	add_child(sfx)
	hud.volume_changed.connect(sfx.set_volume)
	sfx.set_volume(0.8)
	hud.set_has_save(FileAccess.file_exists(SAVE_PATH))
	get_tree().set_auto_accept_quit(false)
	_update_camera(0.0)

func _tmat(tex: Texture2D, scale: float, metal: float, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(scale, scale, scale)
	m.metallic = metal
	m.roughness = rough
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m

func _setup_environment() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("3d7dcf")
	psm.sky_horizon_color = Color("f6dcc2")
	psm.ground_horizon_color = Color("f6dcc2")
	psm.ground_bottom_color = Color("9fb4cf")
	psm.sky_curve = 0.18
	psm.sun_angle_max = 28.0
	psm.sun_curve = 0.12
	sky.sky_material = psm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_sky_contribution = 0.7
	env.ambient_light_energy = 1.0
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_white = 6.0
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_bloom = 0.06
	env.glow_hdr_threshold = 1.0
	env.ssao_enabled = true
	env.ssao_radius = 1.6
	env.ssao_intensity = 1.8
	env.fog_enabled = true
	env.fog_light_color = Color("dde3ec")
	env.fog_density = 0.0048
	env.fog_sky_affect = 0.35
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.18
	env.adjustment_contrast = 1.1
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.light_color = Color("ffe2b0")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 110.0
	sun.shadow_blur = 1.4
	sun.rotation_degrees = Vector3(-44, -35, 0)
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 62.0
	cam.far = 600.0
	cam.current = true
	add_child(cam)

func _build_terrain() -> void:
	var seg := 160
	var size := 260.0
	var verts := PackedVector3Array()
	var cols := PackedColorArray()
	var uvs := PackedVector2Array()
	var norms := PackedVector3Array()
	var idx := PackedInt32Array()
	for j in range(seg + 1):
		for i in range(seg + 1):
			var x := (float(i) / seg - 0.5) * size
			var z := (float(j) / seg - 0.5) * size
			var y := height_at(x, z)
			verts.append(Vector3(x, y, z))
			uvs.append(Vector2(float(i) / seg, float(j) / seg) * 70.0)
			var e := 1.0
			norms.append(Vector3(height_at(x - e, z) - height_at(x + e, z), 2.0 * e, height_at(x, z - e) - height_at(x, z + e)).normalized())
			cols.append(_terrain_color(x, z, y))
	for j in range(seg):
		for i in range(seg):
			var a := j * (seg + 1) + i
			var b := a + 1
			var c := a + seg + 1
			var d := c + 1
			idx.append_array([a, b, c, b, d, c])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.albedo_texture = Tex.detail()
	m.roughness = 0.95
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	add_child(mi)

func _terrain_color(x: float, z: float, y: float) -> Color:
	var s := maxf(absf(height_at(x + 1.2, z) - y), absf(height_at(x, z + 1.2) - y)) / 1.2
	var n := vn(x * 0.11, z * 0.11)
	var d := sqrt(x * x + z * z)
	var c := Color("f4f8ff").lerp(Color("b4cff0"), clampf(n * 1.2 - 0.2, 0.0, 1.0))
	var gp := clampf((0.58 - n) * 3.0 + (3.0 - y) * 0.08, 0.0, 1.0) * clampf(1.3 - absf(y) / 9.0, 0.0, 1.0)
	c = c.lerp(Color("6fab58"), gp * 0.85)
	c = c.lerp(Color("77818b"), clampf((s - 0.55) * 2.2, 0.0, 1.0))
	c = c.lerp(Color("7a6a58"), clampf((11.0 - d) / 5.0, 0.0, 1.0))
	var rdx := absf(x - sin(z * 0.07) * 3.0)
	if z < 14.0 and z > CITY.z + 18.0:
		c = c.lerp(Color("a09282"), clampf(1.0 - (rdx - 1.8) / 1.2, 0.0, 1.0) * 0.9)
	return c

func _cone_mi(r: float, h: float, m: Material, pos: Vector3, shadow: bool = true, seg: int = 7) -> MeshInstance3D:
	var mi := Dwarf.cone(self, r, h, m, pos, seg)
	if not shadow:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

func _build_mountains() -> void:
	var mm := Dwarf.mat(Color.html("8a97ba"), 0.0, 0.95)
	var cap := Dwarf.mat(Color.html("f6f9ff"), 0.0, 0.9)
	for i in 26:
		var a := float(i) / 26.0 * TAU + hash2(i, 3) * 0.2
		var r := 135.0 + hash2(i, 9) * 25.0
		var h := 38.0 + hash2(i, 5) * 42.0
		var w := 24.0 + hash2(i, 7) * 18.0
		var c := _cone_mi(w, h, mm, Vector3(cos(a) * r, h / 2.0 - 8.0, sin(a) * r), false, 6)
		c.rotation.y = hash2(i, 1) * 3.0
		var t := _cone_mi(w * 0.42, h * 0.38, cap, Vector3(cos(a) * r, h * 0.81 - 8.0, sin(a) * r), false, 6)
		t.rotation.y = c.rotation.y

func _add_multimesh(mesh: Mesh, m: Material, xfs: Array) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for i in xfs.size():
		mm.set_instance_transform(i, xfs[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = m
	add_child(mmi)

func _add_obs(x: float, z: float, r: float) -> void:
	obs.append(Vector3(x, z, r))

func _build_forest() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 2026
	var trees: Array = []
	var tries := 0
	while tries < 3000 and trees.size() < 260:
		tries += 1
		var a := rnd.randf() * TAU
		var r := 16.0 + sqrt(rnd.randf()) * 74.0
		var x := cos(a) * r
		var z := sin(a) * r
		var ok := Vector2(x - CITY.x, z - CITY.z).length() > 27.0
		if ok:
			for t in trees:
				if Vector2(t.x - x, t.z - z).length() < 3.2:
					ok = false
					break
		var sc := 0.8 + rnd.randf() * 0.9
		if ok:
			trees.append({"x": x, "z": z, "s": sc, "y": height_at(x, z), "rot": rnd.randf() * TAU})
	var trunk: Array = []
	var l1: Array = []
	var l2: Array = []
	var l3: Array = []
	for t in trees:
		var b := Basis(Vector3.UP, t.rot).scaled(Vector3.ONE * t.s)
		var p := Vector3(t.x, t.y, t.z)
		trunk.append(Transform3D(b, p + Vector3(0, 1.2 * t.s, 0)))
		l1.append(Transform3D(b, p + Vector3(0, 3.4 * t.s, 0)))
		l2.append(Transform3D(b, p + Vector3(0, 5.2 * t.s, 0)))
		l3.append(Transform3D(b, p + Vector3(0, 6.9 * t.s, 0)))
		_add_obs(t.x, t.z, 0.55 * t.s)
	var tm := CylinderMesh.new()
	tm.top_radius = 0.25
	tm.bottom_radius = 0.4
	tm.height = 2.4
	tm.radial_segments = 7
	var c1 := CylinderMesh.new()
	c1.top_radius = 0.0
	c1.bottom_radius = 2.0
	c1.height = 3.4
	c1.radial_segments = 9
	var c2 := CylinderMesh.new()
	c2.top_radius = 0.0
	c2.bottom_radius = 1.5
	c2.height = 2.8
	c2.radial_segments = 9
	var c3 := CylinderMesh.new()
	c3.top_radius = 0.0
	c3.bottom_radius = 0.95
	c3.height = 2.2
	c3.radial_segments = 9
	_add_multimesh(tm, Dwarf.mat(Color.html("5a3d26"), 0.0, 0.95), trunk)
	_add_multimesh(c1, Dwarf.mat(Color.html("2b6a48"), 0.0, 0.9), l1)
	_add_multimesh(c2, Dwarf.mat(Color.html("3a8a58"), 0.0, 0.9), l2)
	_add_multimesh(c3, m_snow, l3)
	# kayalar
	var rocks: Array = []
	var caps: Array = []
	for q in 50:
		var a2 := rnd.randf() * TAU
		var r2 := 15.0 + rnd.randf() * 75.0
		var x2 := cos(a2) * r2
		var z2 := sin(a2) * r2
		var s2 := 0.7 + rnd.randf() * 1.6
		if Vector2(x2 - CITY.x, z2 - CITY.z).length() < 27.0 or Vector2(x2, z2).length() < 16.0:
			continue
		var y2 := height_at(x2, z2)
		var rb := Basis.from_euler(Vector3(rnd.randf() * 3.0, rnd.randf() * 3.0, 0.0)).scaled(Vector3(s2, s2 * 0.75, s2))
		rocks.append(Transform3D(rb, Vector3(x2, y2 + s2 * 0.3, z2)))
		caps.append(Transform3D(Basis().scaled(Vector3(s2 * 0.7, s2 * 0.3, s2 * 0.7)), Vector3(x2, y2 + s2 * 0.75, z2)))
		_add_obs(x2, z2, s2 * 0.9)
	var rm := SphereMesh.new()
	rm.radius = 1.0
	rm.height = 2.0
	rm.radial_segments = 6
	rm.rings = 4
	_add_multimesh(rm, Dwarf.mat(Color.html("7a8590"), 0.0, 0.95), rocks)
	_add_multimesh(rm, m_snow, caps)

func _flame(parent: Node, pos: Vector3, size: float) -> void:
	var m := Dwarf.mat(Color.html("ffa030"), 0.0, 0.5, Color.html("ff8a1a"), 4.0)
	var f := Dwarf.cone(parent, 0.5 * size, 1.5 * size, m, pos, 7)
	f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	flame_nodes.append(f)

func _house(x: float, z: float, rot: float, w: float, d: float) -> void:
	var g := Node3D.new()
	g.position = Vector3(x, height_at(x, z), z)
	g.rotation.y = rot
	add_child(g)
	var h := 3.0
	Dwarf.box(g, Vector3(w, h, d), m_stone, Vector3(0, h / 2.0, 0))
	var r := Dwarf.cone(g, maxf(w, d) * 0.78, 2.4, m_roof, Vector3(0, h + 1.2, 0), 4)
	r.rotation.y = PI / 4.0
	var sn := Dwarf.cone(g, maxf(w, d) * 0.6, 0.8, m_snow, Vector3(0, h + 2.0, 0), 4)
	sn.rotation.y = PI / 4.0
	Dwarf.box(g, Vector3(1.1, 1.9, 0.2), m_wood, Vector3(0, 0.95, d / 2.0 + 0.05))
	var win := Dwarf.box(g, Vector3(0.8, 0.8, 0.15), Dwarf.mat(Color.html("ffd27a"), 0.0, 0.5, Color.html("ffa733"), 2.0), Vector3(w / 2.0 - 1.0, 1.9, d / 2.0 + 0.05))
	win.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	Dwarf.box(g, Vector3(0.7, 2.0, 0.7), m_stone, Vector3(-w / 3.0, h + 1.6, 0))
	_add_obs(x, z, maxf(w, d) * 0.62)

func _build_village() -> void:
	_house(-10, -4, 0.5, 6.0, 5.0)
	_house(10, -3, -0.6, 6.5, 5.0)
	_house(-8, 10, PI - 0.3, 5.5, 5.0)
	_house(11, 10, PI + 0.5, 5.0, 4.5)
	# kamp ateşi
	var fg := Node3D.new()
	fg.position = Vector3(0, height_at(0, 0), 0)
	add_child(fg)
	for i in 6:
		var lg := Dwarf.cyl(fg, 0.12, 0.12, 1.4, m_wood, Vector3(0, 0.3, 0), 6)
		lg.rotation = Vector3(0, i * PI / 3.0, 0)
		lg.rotation.z = PI / 2.6
	for j in 8:
		Dwarf.sph(fg, 0.28, m_stone, Vector3(cos(j * 0.785) * 1.1, 0.15, sin(j * 0.785) * 1.1), Vector3(1, 0.7, 1))
	_flame(fg, Vector3(0, 0.9, 0), 1.0)
	fire_light = OmniLight3D.new()
	fire_light.light_color = Color("ff9a40")
	fire_light.omni_range = 24.0
	fire_light.light_energy = 2.4
	fire_light.shadow_enabled = false
	fire_light.position = Vector3(0, 1.6, 0)
	fg.add_child(fire_light)
	_add_obs(0, 0, 1.3)
	# örs
	var an := Node3D.new()
	an.position = Vector3(5, height_at(5, 5), 5)
	an.rotation.y = 0.5
	add_child(an)
	var am := Dwarf.mat(Color.html("3a3f47"), 0.7, 0.45)
	Dwarf.box(an, Vector3(0.8, 0.5, 1.6), am, Vector3(0, 0.75, 0))
	Dwarf.box(an, Vector3(0.5, 0.3, 0.6), am, Vector3(0, 1.1, 0.9))
	Dwarf.box(an, Vector3(0.6, 0.6, 0.6), m_wood, Vector3(0, 0.3, 0))
	_add_obs(5, 5, 1.0)
	# sancaklar
	var pts := [[-4, 12], [4, 13], [-3, -9], [3, -10]]
	for i in pts.size():
		var p = pts[i]
		var y0 := height_at(p[0], p[1])
		Dwarf.cyl(self, 0.07, 0.09, 5.0, m_wood, Vector3(p[0], y0 + 2.5, p[1]), 6)
		var fl := Dwarf.box(self, Vector3(1.2, 2.0, 0.04), m_blue, Vector3(p[0] + 0.65, y0 + 3.9, p[1]))
		fl.rotation.y = i * 0.4
		Dwarf.sph(self, 0.14, m_gold, Vector3(p[0], y0 + 5.05, p[1]))

func _build_city() -> void:
	var cx: float = CITY.x
	var cz: float = CITY.z
	var cy: float = CITY.y
	# plaza zemini
	var floor_mi := Dwarf.cyl(self, 21.0, 21.0, 0.12, m_cobble, Vector3(cx, cy + 0.0, cz), 48)
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# surlar
	var R := 21.5
	var N := 34
	var wall_xf: Array = []
	var mer_xf: Array = []
	for i in N:
		var a := float(i) / N * TAU
		var da := absf(atan2(sin(a - PI / 2.0), cos(a - PI / 2.0)))
		if da < 0.27 or da > PI - 0.95:
			continue
		var px := cx + cos(a) * R
		var pz := cz + sin(a) * R
		var rot := -a - PI / 2.0
		var b := Basis(Vector3.UP, rot)
		wall_xf.append(Transform3D(b, Vector3(px, cy + 3.1, pz)))
		var tx := -sin(a)
		var tz := cos(a)
		for o in [-1.3, 1.3]:
			mer_xf.append(Transform3D(b, Vector3(px + tx * o, cy + 6.8, pz + tz * o)))
		_add_obs(px, pz, 2.5)
	var wb := BoxMesh.new()
	wb.size = Vector3(4.9, 6.2, 2.2)
	var mb := BoxMesh.new()
	mb.size = Vector3(1.1, 1.2, 2.5)
	_add_multimesh(wb, m_stone, wall_xf)
	_add_multimesh(mb, m_stone, mer_xf)
	# kapı kuleleri
	for sd in [-1.0, 1.0]:
		var a: float = PI / 2.0 + sd * 0.34
		var px := cx + cos(a) * R
		var pz := cz + sin(a) * R
		Dwarf.cyl(self, 3.0, 3.4, 13.0, m_stone, Vector3(px, cy + 6.5, pz), 14)
		Dwarf.cyl(self, 3.25, 3.25, 0.5, m_gold, Vector3(px, cy + 11.5, pz), 14)
		Dwarf.cone(self, 3.9, 5.5, m_bronze, Vector3(px, cy + 16.0, pz), 14)
		Dwarf.sph(self, 0.4, m_gold, Vector3(px, cy + 19.0, pz))
		Dwarf.box(self, Vector3(1.8, 6.0, 0.05), m_blue, Vector3(px, cy + 8.0, pz + 3.45))
		Dwarf.box(self, Vector3(0.35, 5.6, 0.06), m_gold, Vector3(px, cy + 8.0, pz + 3.5))
		_add_obs(px, pz, 3.4)
	var gz := cz + R
	Dwarf.box(self, Vector3(10.5, 2.6, 2.8), m_stone, Vector3(cx, cy + 9.6, gz))
	Dwarf.box(self, Vector3(11.0, 0.45, 3.1), m_gold, Vector3(cx, cy + 8.2, gz))
	Dwarf.box(self, Vector3(4.2, 2.0, 0.05), m_blue, Vector3(cx, cy + 9.6, gz + 1.45))
	for sd in [-1.0, 1.0]:
		var br := Node3D.new()
		br.position = Vector3(cx + sd * 4.6, cy, gz + 2.2)
		add_child(br)
		Dwarf.cyl(br, 0.5, 0.35, 1.2, m_bronze, Vector3(0, 1.4, 0), 10)
		Dwarf.cyl(br, 0.1, 0.1, 1.4, m_bronze, Vector3(0, 0.7, 0), 6)
		_flame(br, Vector3(0, 2.4, 0), 0.7)
	gate_light = OmniLight3D.new()
	gate_light.light_color = Color("ffa850")
	gate_light.omni_range = 28.0
	gate_light.light_energy = 2.0
	gate_light.position = Vector3(cx, cy + 4.0, gz + 3.0)
	add_child(gate_light)
	# büyük ocak
	var fx := cx
	var fz := cz - 6.0
	Dwarf.cyl(self, 5.2, 5.7, 1.3, m_stone, Vector3(fx, cy + 0.65, fz), 32)
	lava_mat = Dwarf.mat(Color.html("ff7a1f"), 0.0, 0.6, Color.html("ff6a10"), 3.5)
	var lava := Dwarf.cyl(self, 4.3, 4.3, 0.1, lava_mat, Vector3(fx, cy + 1.3, fz), 32)
	lava.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	forge_light = OmniLight3D.new()
	forge_light.light_color = Color("ff7a30")
	forge_light.omni_range = 34.0
	forge_light.light_energy = 3.0
	forge_light.position = Vector3(fx, cy + 3.5, fz)
	add_child(forge_light)
	for q in 6:
		var ca := float(q) / 6.0 * TAU
		var cpx := fx + cos(ca) * 5.6
		var cpz := fz + sin(ca) * 5.6
		Dwarf.box(self, Vector3(0.7, 2.6, 0.7), m_stone, Vector3(cpx, cy + 1.6, cpz))
		Dwarf.sph(self, 0.28, m_gold, Vector3(cpx, cy + 3.1, cpz))
	_add_obs(fx, fz, 5.9)
	# dev örs
	var an := Node3D.new()
	an.position = Vector3(cx + 9.0, cy + 0.05, cz - 6.0)
	an.rotation.y = -0.6
	an.scale = Vector3.ONE * 2.4
	add_child(an)
	var am := Dwarf.mat(Color.html("3a3f47"), 0.7, 0.45)
	Dwarf.box(an, Vector3(0.8, 0.5, 1.6), am, Vector3(0, 0.75, 0))
	Dwarf.box(an, Vector3(0.5, 0.3, 0.6), am, Vector3(0, 1.1, 0.9))
	Dwarf.box(an, Vector3(0.6, 0.6, 0.6), m_wood, Vector3(0, 0.3, 0))
	_add_obs(cx + 9.0, cz - 6.0, 2.2)
	# kral heykeli
	var statue := Dwarf.make_dwarf({"helm": true})
	var st_m := Dwarf.mat(Color.html("8a8782"), 0.0, 0.9)
	for n in _all_meshes(statue):
		n.material_override = st_m
	statue.scale *= 3.4
	statue.position = Vector3(cx, cy + 1.6, cz + 9.0)
	statue.rotation.y = PI
	add_child(statue)
	Dwarf.box(self, Vector3(5, 1.7, 5), m_stone, Vector3(cx, cy + 0.85, cz + 9.0))
	Dwarf.box(self, Vector3(5.3, 0.3, 5.3), m_gold, Vector3(cx, cy + 1.7, cz + 9.0))
	_add_obs(cx, cz + 9.0, 3.0)
	# dağ salonu girişi
	var hz := cz - 21.0
	for sd in [-1.0, 1.0]:
		Dwarf.box(self, Vector3(3.2, 17, 3.2), m_stone, Vector3(cx + sd * 5.8, cy + 8.5, hz))
		for yy in [3.0, 8.0, 13.0]:
			Dwarf.box(self, Vector3(3.5, 0.5, 3.5), m_gold, Vector3(cx + sd * 5.8, cy + yy, hz))
		_add_obs(cx + sd * 5.8, hz, 2.2)
	Dwarf.box(self, Vector3(15, 3.2, 3.4), m_stone, Vector3(cx, cy + 16.6, hz))
	Dwarf.box(self, Vector3(15.4, 0.5, 3.7), m_gold, Vector3(cx, cy + 14.8, hz))
	Dwarf.box(self, Vector3(9, 15, 1), Dwarf.mat(Color.html("14100e"), 0.0, 0.9), Vector3(cx, cy + 7.5, hz - 1.4))
	var glow := Dwarf.mat(Color.html("ff8a2a"), 0.0, 0.7, Color.html("ff7a1a"), 2.5)
	var hg := Dwarf.box(self, Vector3(7.6, 11, 0.1), glow, Vector3(cx, cy + 6.5, hz - 0.8))
	hg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var back := Dwarf.mat(Color.html("7d89ac"), 0.0, 0.95)
	for p in [[-26, -112], [0, -118], [28, -110]]:
		_cone_mi(30.0, 62.0, back, Vector3(p[0], 24, p[1]), false, 7)
		_cone_mi(12.0, 22.0, m_snow, Vector3(p[0], 48, p[1]), false, 7)
	# tezgâhlar
	_stall(cx - 10.0, cz + 4.0, 0.35, Color.html("b8302a"), Color.html("e6d3a0"))
	_stall(cx + 11.0, cz + 3.0, -0.35, Color.html("2a55b8"), Color.html("e6d3a0"))
	_stall(cx - 13.0, cz - 8.0, 1.2, Color.html("3a8a4a"), Color.html("e6d3a0"))
	# fener direkleri
	var lamp := Dwarf.mat(Color.html("ffc060"), 0.0, 0.5, Color.html("ffb040"), 4.0)
	for l in 7:
		var la := float(l) / 7.0 * TAU + 0.2
		var lx := cx + cos(la) * 14.5
		var lz := cz + sin(la) * 14.5
		if Vector2(lx - cx, lz - (cz + R)).length() < 6.0:
			continue
		Dwarf.cyl(self, 0.1, 0.14, 3.4, m_bronze, Vector3(lx, cy + 1.75, lz), 6)
		var lb := Dwarf.sph(self, 0.34, lamp, Vector3(lx, cy + 3.6, lz))
		lb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _all_meshes(n: Node) -> Array:
	var out: Array = []
	for c in n.get_children():
		if c is MeshInstance3D:
			out.append(c)
		out.append_array(_all_meshes(c))
	return out

func _stall(x: float, z: float, rot: float, c1: Color, c2: Color) -> void:
	var g := Node3D.new()
	g.position = Vector3(x, CITY.y + 0.05, z)
	g.rotation.y = rot
	add_child(g)
	Dwarf.box(g, Vector3(3.4, 1.0, 1.4), m_wood, Vector3(0, 0.5, 0))
	for px in [-1.6, 1.6]:
		Dwarf.cyl(g, 0.08, 0.08, 3.2, m_wood, Vector3(px, 1.6, -0.6), 6)
	for k in 6:
		var m := Dwarf.mat(c1 if k % 2 == 1 else c2, 0.0, 0.9)
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		var st := Dwarf.box(g, Vector3(0.62, 0.04, 2.0), m, Vector3(-1.55 + k * 0.62, 3.0, -0.1))
		st.rotation.x = 0.55
	Dwarf.cyl(g, 0.4, 0.4, 0.8, m_wood, Vector3(2.4, 0.4, 0.8), 10)
	_add_obs(x, z, 1.9)

# ---------- oyuncu, NPC, canavarlar ----------
func _spawn_player() -> void:
	player = Dwarf.make_dwarf()
	add_child(player)
	rig = player.get_meta("rig")
	P = {"x": 0.0, "z": 7.0, "y": 0.0, "yaw": PI, "hp": 0.0, "rage": 0.0, "lvl": 1, "xp": 0.0,
		"atk_t": 0.0, "gcd": 0.0, "cd": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], "vy": 0.0, "jy": 0.0, "bs_t": 0.0, "sb_t": 0.0, "charge": null, "charge_t": 0.0, "spin": 0.0, "pot_cd": 0.0, "target": null, "auto": false,
		"dead": false, "dead_t": 0.0, "combat_t": -99.0, "spd": 0.0, "wep_b": 0.0, "wep_lvl": 0, "dot_t": 0.0, "dot_v": 0.0, "dot_k": 0.0, "slow_t": 0.0}
	inv = Inv.new()
	G = Items.totals(inv.eq)
	P["hp"] = float(max_hp())

func base_str() -> int:
	return 12 + 2 * P["lvl"]

func base_agi() -> int:
	return 6 + P["lvl"]

func base_sta() -> int:
	return 10 + 2 * P["lvl"]

func max_hp() -> int:
	return 110 + 28 * (P["lvl"] - 1) + 7 * G["sta"]

func atk() -> float:
	var wd: float = (G["wmin"] + G["wmax"]) * 0.5 / G["wspd"] * 1.5
	return (wd + (base_str() + G["str"]) * 0.35 + P["lvl"] * 1.6 + P["wep_b"]) * (1.25 if P["bs_t"] > 0.0 else 1.0)

func crit_chance() -> float:
	return 0.08 + (base_agi() + G["agi"]) * 0.003 + G["crit"] * 0.01

func armor_total() -> float:
	return G["armor"] * 0.5 + P["lvl"] * 1.5

func potion_count() -> int:
	return inv.count("pot_heal") + inv.count("pot_big")

## Eşya/seviye değişince istatistikleri ve pencereleri yenile.
func inv_changed() -> void:
	G = Items.totals(inv.eq)
	if P.has("hp"):
		P["hp"] = minf(P["hp"], float(max_hp()))
	if invui != null:
		invui.refresh()

func xp_need(l: int) -> float:
	return 50.0 + 40.0 * l

const NPCDEF := [
	{"id": "ragna", "name": "Avcı Başı Ragna", "title": "Kurt Avı", "role": "quest", "q": "q_wolf", "x": -3.5, "z": 6.5, "face": 0.9,
		"o": {"beard": Color("8a5a2b"), "cloth": Color("2f6b3a"), "metal": Color("6f7d68"), "helm": false, "prop": "spear"}},
	{"id": "kelda", "name": "Han Sahibi Kelda", "title": "Han", "role": "inn", "x": -5.2, "z": 14.5, "face": 0.3,
		"o": {"beard": Color("e9e4d6"), "cloth": Color("7a5230"), "metal": Color("8d8472"), "helm": false, "prop": "none"}},
	{"id": "dorn", "name": "Muhafız Dorn", "title": "Kapı Muhafızı", "role": "quest", "q": "q_boar", "x": 5.2, "z": -40.5, "face": 0.0,
		"o": {"beard": Color("4a2b18"), "cloth": Color("1d3b86"), "metal": Color("9aa8c0"), "helm": true, "prop": "axe"}},
	{"id": "hilda", "name": "Tüccar Hilda", "title": "Tüccar", "role": "vendor", "x": -10.0, "z": -51.8, "face": 0.35,
		"o": {"beard": Color("dbb46a"), "cloth": Color("8e2f4a"), "metal": Color("b09060"), "helm": false, "prop": "none"}},
	{"id": "borga", "name": "Demirci Borga", "title": "Silah Ustası", "role": "smith", "x": 5.2, "z": -59.5, "face": -2.4,
		"o": {"beard": Color("2e2018"), "cloth": Color("5a3a22"), "metal": Color("6a6f78"), "helm": false, "prop": "hammer", "skin": Color("d69a74")}},
	{"id": "thrum", "name": "Komutan Thrum", "title": "Dağ Komutanı", "role": "quest", "q": "q_bear", "x": -4.0, "z": -73.5, "face": 0.0,
		"o": {"beard": Color("aab0b8"), "cloth": Color("8a1f1f"), "metal": Color("c0c8d4"), "helm": true, "prop": "axe"}},
]

func _spawn_npcs() -> void:
	for d in NPCDEF:
		var n: Dictionary = d.duplicate()
		var node := Dwarf.make_dwarf(d["o"])
		var inside_city: bool = d["z"] < CITY.z + 22.0
		n["y"] = height_at(d["x"], d["z"]) + (0.05 if inside_city else 0.0)
		node.position = Vector3(d["x"], n["y"], d["z"])
		node.rotation.y = d["face"]
		add_child(node)
		n["node"] = node
		npcs.append(n)
		_add_obs(d["x"], d["z"], 0.7)

func _spawn_mobs() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 77
	var kinds := ["wolf", "wolf", "boar", "wolf", "boar", "bear"]
	var n := 0
	var tries := 0
	while n < 30 and tries < 2000:
		tries += 1
		var a := rnd.randf() * TAU
		var r := 22.0 + rnd.randf() * 62.0
		var x := cos(a) * r
		var z := sin(a) * r
		var blocked := false
		for o in obs:
			if Vector2(o.x - x, o.y - z).length() < o.z + 1.5:
				blocked = true
				break
		if blocked or Vector2(x - CITY.x, z - CITY.z).length() < 30.0:
			continue
		var kind: String = kinds[rnd.randi() % kinds.size()]
		var ty: Dictionary = MTYPES[kind]
		var lvl := clampi(roundi(ty.lo + (r - 22.0) / 62.0 * (ty.hi - ty.lo + 1) - 0.3 + rnd.randf() * 0.8), ty.lo, ty.hi)
		var m := Mob.new()
		m.kind = kind
		m.nm = ty.name
		m.lvl = lvl
		m.x = x
		m.z = z
		m.hx = x
		m.hz = z
		m.wx = x
		m.wz = z
		m.yaw = rnd.randf() * 6.0
		m.maxhp = round(ty.hp * (1.0 + (lvl - 1) * 0.55))
		m.hp = m.maxhp
		m.dmg = ty.dmg * (1.0 + lvl * 0.55)
		m.spd = ty.spd
		m.aggro = ty.aggro
		m.rad = ty.rad
		m.sc = ty.sc
		m.w_t = rnd.randf() * 4.0
		m.ph = rnd.randf() * 6.0
		m.id = n
		match kind:
			"wolf": m.node = Dwarf.make_wolf()
			"boar": m.node = Dwarf.make_boar()
			_: m.node = Dwarf.make_bear()
		m.node.scale = Vector3.ONE * m.sc
		m.legs = m.node.get_meta("legs")
		add_child(m.node)
		mobs.append(m)
		n += 1

func _free_spot(x: float, z: float) -> Vector2:
	for i in 60:
		var a := float(i) * 2.4
		var r := float(i) * 0.5
		var px := x + cos(a) * r
		var pz := z + sin(a) * r
		var ok := true
		for o in obs:
			if Vector2(o.x - px, o.y - pz).length() < o.z + 2.5:
				ok = false
				break
		if ok:
			return Vector2(px, pz)
	return Vector2(x, z)

func _make_boss_model(id: String) -> Node3D:
	match id:
		"arctikus": return Dwarf.make_bear({"fur": Color("e8eef4"), "dk": Color("9aa8b8"), "lt": Color("ffffff")})
		"grik": return Dwarf.make_trogg(true)
		"choksul": return Dwarf.make_ogre()
		"hogger": return Dwarf.make_gnoll(true)
		"vancleef": return Dwarf.make_dwarf({"skin": Color("e8c0a0"), "metal": Color("5a2a2a"), "cloth": Color("a32a2a"), "beard": Color("2a1a10"), "helm": false, "prop": "axe"})
		_: return Dwarf.make_ragnaros()

func _humanoid_legs(node: Node3D) -> Array:
	if node.has_meta("legs"):
		return node.get_meta("legs")
	var r: Dictionary = node.get_meta("rig")
	return [r["legL"], r["legR"], r["legR"], r["legL"]]

func _spawn_bosses() -> void:
	var i := 0
	for id in BOSSES:
		var d: Dictionary = BOSSES[id]
		var m := Mob.new()
		var sp := Vector2(d["x"], d["z"]) if id == "ragnaros" else _free_spot(d["x"], d["z"])
		m.boss = id
		m.kind = d["kind"]
		m.nm = d["name"]
		m.title = d["title"]
		m.lvl = d["lvl"]
		m.x = sp.x
		m.z = sp.y
		m.hx = sp.x
		m.hz = sp.y
		m.wx = sp.x
		m.wz = sp.y
		m.yaw = 0.0 if id != "ragnaros" else 0.0
		m.maxhp = d["hp"]
		m.hp = m.maxhp
		m.dmg = d["dmg"]
		m.base_dmg = m.dmg
		m.spd = d["spd"]
		m.base_spd = m.spd
		m.aggro = d["aggro"]
		m.rad = d["rad"]
		m.sc = d["sc"]
		m.reach = d.get("reach", 1.3)
		m.yoff = d.get("yoff", 0.0)
		m.respawn = d["respawn"]
		m.atk_int = 2.4
		m.id = 900 + i
		m.node = _make_boss_model(id)
		m.node.scale = Vector3.ONE * m.sc
		m.legs = _humanoid_legs(m.node)
		add_child(m.node)
		m.node.position = Vector3(m.x, height_at(m.x, m.z) + m.yoff, m.z)
		mobs.append(m)
		i += 1

func spawn_add(owner_m, nm: String, model: String, lvl: int, hp: float, dmg: float, spd: float, sc: float, off: Vector2) -> void:
	var m := Mob.new()
	m.kind = "skull"
	m.nm = nm
	m.lvl = lvl
	m.x = owner_m.x + off.x
	m.z = owner_m.z + off.y
	m.hx = m.x
	m.hz = m.z
	m.wx = m.x
	m.wz = m.z
	m.maxhp = hp
	m.hp = hp
	m.dmg = dmg
	m.spd = spd
	m.aggro = 30.0
	m.rad = 0.7 * sc
	m.sc = sc
	m.temp = true
	m.owner_m = owner_m
	m.state = "chase"
	m.id = next_id
	next_id += 1
	match model:
		"gnoll": m.node = Dwarf.make_gnoll(false)
		"ember": m.node = Dwarf.make_ember()
		_: m.node = Dwarf.make_dwarf({"skin": Color("e0b898"), "metal": Color("4a3030"), "cloth": Color("8a2020"), "beard": Color("2a1a10"), "helm": false, "prop": "axe"})
	m.node.scale = Vector3.ONE * sc
	m.legs = _humanoid_legs(m.node)
	add_child(m.node)
	m.node.position = Vector3(m.x, height_at(m.x, m.z), m.z)
	mobs.append(m)
	ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.5, Color("ffb060") if model == "ember" else Color("c9b8a0"), 0.5)

func _setup_snow() -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(32, 0.5, 32)
	pm.direction = Vector3(0.12, -1, 0.05)
	pm.spread = 14.0
	pm.initial_velocity_min = 1.4
	pm.initial_velocity_max = 2.6
	pm.gravity = Vector3(0, -0.3, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.3
	var q := QuadMesh.new()
	q.size = Vector2(0.12, 0.12)
	var qm := StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.albedo_color = Color(1, 1, 1, 0.9)
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = qm
	snow_node = GPUParticles3D.new()
	snow_node.amount = 2400
	snow_node.lifetime = 9.0
	snow_node.preprocess = 9.0
	snow_node.process_material = pm
	snow_node.draw_pass_1 = q
	snow_node.visibility_aabb = AABB(Vector3(-36, -22, -36), Vector3(72, 44, 72))
	snow_node.local_coords = false
	snow_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(snow_node)

# ---------- girdi ----------
func _on_start(cont: bool) -> void:
	mode = "play"
	sfx.start_ambient()
	sfx.play("click")
	if cont and load_game():
		hud.say("Kayıtlı oyun yüklendi.", Color("f2c75c"))
		return
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	hud.banner("KAR DAĞI KÖYÜ", "Kamp ateşi")
	hud.say("Kurtlar ve domuzlar vadide dolaşıyor. İyi avlar!", Color("f2c75c"))

func toggle_win(name: String) -> void:
	if mode != "play":
		return
	var w: Control = invui.bag_win if name == "bag" else invui.char_win
	w.visible = not w.visible
	if w.visible and name == "char" and vendor_npc != null:
		close_vendor()
	if not w.visible:
		held = null
		invui.hide_tip()
	sfx.play("click", -6)
	inv_changed()

func ui_close(name: String) -> void:
	held = null
	invui.hide_tip()
	match name:
		"bag": invui.bag_win.visible = false
		"char": invui.char_win.visible = false
		"vendor": close_vendor()
		"loot": close_loot()
	invui.refresh()

func ui_vendor_tab(i: int) -> void:
	vendor_tab = i
	invui.refresh()

func ui_vendor_click(idx: int, _button: int) -> void:
	if vendor_npc == null:
		return
	var err: String = ""
	if vendor_tab == 0:
		var id: String = VENDORS[vendor_npc["id"]][idx]
		err = inv.buy(id, 1, Items.buy_price(Items.get_item(id)))
	else:
		err = inv.rebuy(idx)
	if err != "":
		hud.say(err, Color("ff6a5a"))
	else:
		sfx.play("coin", -6)
	inv_changed()

func ui_loot_click(idx: int) -> void:
	take_loot(idx)

func ui_slot_click(kind: String, key, button: int) -> void:
	sfx.play("click", -6)
	var lvl: int = P["lvl"]
	var err: String = ""
	if button == MOUSE_BUTTON_RIGHT:
		if held != null:
			held = null
		elif kind == "bag":
			var e = inv.bag[key]
			if e == null:
				return
			var it := Items.get_item(e["id"])
			if vendor_npc != null and invui.vend_win.visible:
				var gain: int = inv.sell(key)
				hud.say("Sattın: %s (+%s)" % [it["name"], Items.money_plain(gain)], Color("f2c75c"))
				sfx.play("coin", -6)
			elif Items.is_equip(it):
				err = inv.equip_from_bag(key, lvl)
			elif it.get("heal", 0.0) > 0.0:
				use_potion(e["id"])
		else:
			err = inv.unequip(key)
	elif held == null:
		if kind == "bag" and inv.bag[key] != null:
			held = {"from": "bag", "i": key}
		elif kind == "eq" and inv.eq[key] != "":
			held = {"from": "eq", "slot": key}
	else:
		var h: Dictionary = held
		held = null
		if h["from"] == "bag":
			if kind == "bag":
				inv.swap_bag(h["i"], key)
			else:
				err = inv.equip_from_bag(h["i"], lvl, key)
		else:
			var sl: String = h["slot"]
			if kind == "bag":
				var e2 = inv.bag[key]
				if e2 == null:
					inv.bag[key] = {"id": inv.eq[sl], "n": 1}
					inv.eq[sl] = ""
				else:
					var it2 := Items.get_item(e2["id"])
					if Items.slot_fits(it2, sl) and lvl >= it2["req"]:
						var old: String = inv.eq[sl]
						inv.eq[sl] = e2["id"]
						inv.bag[key] = {"id": old, "n": 1}
					else:
						err = "Bu eşya o yuvaya uymuyor."
			elif key != sl:
				var a: String = inv.eq[sl]
				var b: String = inv.eq[key]
				if Items.slot_fits(Items.get_item(a), key) and (b == "" or Items.slot_fits(Items.get_item(b), sl)):
					inv.eq[sl] = b
					inv.eq[key] = a
				else:
					err = "Bu eşya o yuvaya uymuyor."
	if err != "":
		hud.say(err, Color("ff6a5a"))
	inv_changed()

func toggle_fullscreen() -> void:
	var w := get_window()
	w.mode = Window.MODE_WINDOWED if w.mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN

func toggle_pause() -> void:
	if mode != "play":
		return
	paused = not paused
	hud.set_paused(paused)
	if paused:
		rmb = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		save_game()

func save_game() -> void:
	if mode != "play" or P["dead"]:
		return
	var d := {"x": P["x"], "z": P["z"], "yaw": P["yaw"], "hp": P["hp"], "lvl": P["lvl"], "xp": P["xp"],
		"wep_b": P["wep_b"], "wep_lvl": P["wep_lvl"], "qs": qs, "inv": inv.to_dict()}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(d))

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var d = JSON.parse_string(f.get_as_text())
	if typeof(d) != TYPE_DICTIONARY:
		return false
	for k in ["x", "z", "yaw", "lvl", "xp", "wep_b", "wep_lvl", "hp"]:
		if not d.has(k) or typeof(d[k]) != TYPE_FLOAT:
			return false
	P["x"] = clampf(d["x"], -WORLD_R, WORLD_R)
	P["z"] = clampf(d["z"], -WORLD_R, WORLD_R)
	P["yaw"] = d["yaw"]
	P["lvl"] = clampi(int(d["lvl"]), 1, 10)
	P["xp"] = maxf(0.0, d["xp"])
	if typeof(d.get("inv")) == TYPE_DICTIONARY and inv.from_dict(d["inv"]):
		pass
	else:
		# eski kayıt: altın ve iksirleri çantaya çevir
		inv.reset()
		inv.money = maxi(0, int(d.get("gold", 0))) * 10
		inv.remove("pot_heal", inv.count("pot_heal"))
		inv.add("pot_heal", clampi(int(d.get("pot", 3)), 0, 20))
	held = null
	P["wep_b"] = d["wep_b"]
	P["wep_lvl"] = clampi(int(d["wep_lvl"]), 0, 6)
	G = Items.totals(inv.eq)
	P["hp"] = clampf(d["hp"], 1.0, float(max_hp()))
	qs = {}
	if typeof(d.get("qs")) == TYPE_DICTIONARY:
		for id in d["qs"]:
			if QUESTS.has(id) and typeof(d["qs"][id]) == TYPE_DICTIONARY:
				var e: Dictionary = d["qs"][id]
				qs[id] = {"st": str(e.get("st", "active")), "n": int(e.get("n", 0))}
	P["y"] = height_at(P["x"], P["z"])
	render_quests()
	inv_changed()
	return true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

func _unhandled_input(ev: InputEvent) -> void:
	if paused:
		if ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode == KEY_ESCAPE:
			toggle_pause()
		return
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_RIGHT:
			rmb = ev.pressed
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if ev.pressed else Input.MOUSE_MODE_VISIBLE
		elif ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed and mode == "play":
			_select_at(ev.position)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_dist = clampf(cam_dist - 0.7, 4.0, 16.0)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_dist = clampf(cam_dist + 0.7, 4.0, 16.0)
	elif ev is InputEventMouseMotion and rmb:
		cam_yaw -= ev.relative.x * 0.005
		cam_pitch = clampf(cam_pitch + ev.relative.y * 0.004, 0.05, 1.25)
	elif ev is InputEventKey and ev.pressed and not ev.echo:
		match ev.keycode:
			KEY_SPACE: jump()
			KEY_R: toggle_auto()
			KEY_1: ability(0)
			KEY_2: ability(1)
			KEY_3: ability(2)
			KEY_4: ability(3)
			KEY_5: ability(4)
			KEY_6: ability(5)
			KEY_7: ability(6)
			KEY_8: ability(7)
			KEY_9: ability(8)
			KEY_0: use_potion()
			KEY_F: use_potion()
			KEY_H: hud.toggle_help()
			KEY_B: toggle_win("bag")
			KEY_C: toggle_win("char")
			KEY_G:
				if loot_mob != null:
					while loot_mob != null and not loot_mob.loot.is_empty():
						var before: int = loot_mob.loot.size()
						take_loot(0)
						if loot_mob != null and loot_mob.loot.size() >= before:
							break
				elif dlg_open:
					close_dialog()
				elif near_npc() != null:
					open_talk()
				else:
					for m in mobs:
						if m.dead and (not m.loot.is_empty() or m.loot_money > 0) and Vector2(m.x - P["x"], m.z - P["z"]).length() < 4.0 + (m.rad if m.boss != "" else 0.0):
							open_loot(m)
							break
			KEY_TAB:
				var m = nearest_mob(14.0)
				if m:
					P["target"] = m
			KEY_ESCAPE:
				if held != null:
					held = null
					invui.refresh()
				elif loot_mob != null:
					close_loot()
				elif vendor_npc != null:
					close_vendor()
				elif invui.bag_win.visible or invui.char_win.visible:
					invui.bag_win.visible = false
					invui.char_win.visible = false
					invui.hide_tip()
				elif dlg_open:
					close_dialog()
				elif hud.help_box.visible:
					hud.toggle_help()
				elif P["target"] != null or P["auto"]:
					P["target"] = null
					P["auto"] = false
				else:
					toggle_pause()
			KEY_F11:
				toggle_fullscreen()

func _select_at(pos: Vector2) -> void:
	if held != null:
		held = null
		invui.refresh()
		return
	for m in mobs:
		if m.dead and (not m.loot.is_empty() or m.loot_money > 0):
			var lp := Vector3(m.x, m.node.position.y + 0.5, m.z)
			if not cam.is_position_behind(lp) and cam.unproject_position(lp).distance_to(pos) < 50.0:
				open_loot(m)
				return
	var best = null
	var bd := 60.0
	for m in mobs:
		if m.dead:
			continue
		var wp := Vector3(m.x, m.node.position.y + 1.0 * m.sc, m.z)
		if cam.is_position_behind(wp):
			continue
		var d := cam.unproject_position(wp).distance_to(pos)
		if d < bd:
			bd = d
			best = m
	if best:
		P["target"] = best

# ---------- savaş ----------
func in_combat() -> bool:
	return T - P["combat_t"] < 5.0

func add_rage(n: float) -> void:
	P["rage"] = minf(100.0, P["rage"] + n)

func roll(base: float) -> Dictionary:
	var crit := randf() < crit_chance()
	var v: float = base * (0.85 + randf() * 0.3) * (1.0 + G["dmg"])
	if crit:
		v *= 1.8
	return {"v": maxi(1, roundi(v)), "crit": crit}

func dist_to(m) -> float:
	return Vector2(m.x - P["x"], m.z - P["z"]).length() - m.rad

func nearest_mob(max_d: float):
	var best = null
	var bd := 1e9
	for m in mobs:
		if m.dead:
			continue
		var d := Vector2(m.x - P["x"], m.z - P["z"]).length()
		if d < max_d and d < bd:
			bd = d
			best = m
	return best

func hit_mob(m, r: Dictionary, col: Color = Color.WHITE) -> void:
	if m.dead:
		return
	m.hp -= r["v"]
	sfx.play("crit" if r["crit"] else "hit", -4)
	float_text(Vector3(m.x, 1.9 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), str(r["v"]), Color("ffd23a") if r["crit"] else col, r["crit"])
	P["combat_t"] = T
	add_rage((9.0 if r["crit"] else 6.0) + G["rage"])
	if m.state == "idle":
		m.state = "chase"
	if m.hp <= 0.0:
		kill_mob(m)

func kill_mob(m) -> void:
	m.dead = true
	m.bleed_t = 0.0
	m.died_at = T
	m.state = "idle"
	if P["target"] == m:
		P["target"] = null
		P["auto"] = false
	var xp := roundi((14.0 + m.lvl * 9.0) * clampf(1.0 + (m.lvl - P["lvl"]) * 0.15, 0.2, 1.6))
	if m.boss != "":
		xp = BOSSES[m.boss]["xp"]
		_boss_reset(m)
		hud.banner("BOSS ÖLDÜ", m.nm)
		sfx.play("quest")
	hud.say("%s öldü. +%d tecrübe" % [m.nm, xp], Color("c9a8ff"))
	roll_loot(m)
	quest_kill(m)
	gain_xp(xp)

func _normal_loot(m) -> void:
	m.loot_money = 4 + m.lvl * 5 + randi() % 6
	var junk := {"Kurt": "j_wolf", "Yaban Domuzu": "j_boar", "Dağ Ayısı": "j_bear"}
	if randf() < 0.55:
		m.loot.append({"id": junk[m.nm], "n": 1})
	if randf() < 0.2:
		m.loot.append({"id": "pot_big" if (m.lvl >= 4 and randf() < 0.4) else "pot_heal", "n": 1})
	var r := randf()
	var rar := 0
	if m.nm == "Dağ Ayısı" and r < 0.04:
		rar = 4
	elif r < 0.07:
		rar = 3
	elif r < 0.30:
		rar = 2
	elif r < 0.42:
		rar = 1
	if rar > 0:
		var pl: Array = Items.pool(rar, 1 if rar == 4 else maxi(1, m.lvl - 2), 10 if rar == 4 else m.lvl + 2)
		if not pl.is_empty():
			m.loot.append({"id": pl[randi() % pl.size()], "n": 1})

func roll_loot(m) -> void:
	m.loot = []
	if m.boss != "":
		_boss_loot(m)
	elif m.temp:
		m.loot_money = 6 + m.lvl * 4
		if randf() < 0.3:
			m.loot.append({"id": "pot_heal", "n": 1})
	else:
		_normal_loot(m)
	m.fade_t = T + (90.0 if m.boss != "" else 25.0)
	var sp := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.13
	sm.height = 0.26
	sp.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("ffd45a")
	sp.material_override = mat
	sp.position = Vector3(m.x, height_at(m.x, m.z) + 0.8, m.z)
	add_child(sp)
	m.sparkle = sp

func _boss_loot(m) -> void:
	var d: Dictionary = BOSSES[m.boss]
	m.loot_money = 300 + m.lvl * 120 + randi() % 200
	var drops: Array = d["drops"]
	var main_id: String = drops[randi() % drops.size()]
	m.loot.append({"id": main_id, "n": 1})
	for id in drops:
		if id != main_id and randf() < 0.3:
			m.loot.append({"id": id, "n": 1})
	if m.boss == "ragnaros" and randf() < 0.15:
		m.loot.append({"id": "hammer_sulf", "n": 1})
	m.loot.append({"id": "pot_big", "n": 2})

func open_loot(m) -> void:
	if m.loot.is_empty() and m.loot_money <= 0:
		return
	if Vector2(m.x - P["x"], m.z - P["z"]).length() > 5.0 + (m.rad if m.boss != "" else 0.0):
		hud.say("Çok uzaktasın.", Color("ff6a5a"))
		return
	loot_mob = m
	if m.loot_money > 0:
		inv.money += m.loot_money
		hud.say("+%s" % Items.money_plain(m.loot_money), Color("f2c75c"))
		sfx.play("coin", -8)
		m.loot_money = 0
	invui.loot_win.visible = true
	inv_changed()
	if m.loot.is_empty():
		close_loot()

func close_loot() -> void:
	var m = loot_mob
	loot_mob = null
	invui.loot_win.visible = false
	if m != null and m.loot.is_empty() and m.fade_t > T:
		m.fade_t = T
	if m != null and m.sparkle != null and m.loot.is_empty():
		m.sparkle.queue_free()
		m.sparkle = null

func take_loot(i: int) -> void:
	var m = loot_mob
	if m == null or i < 0 or i >= m.loot.size():
		return
	var e: Dictionary = m.loot[i]
	var left: int = inv.add(e["id"], e["n"])
	if left > 0:
		e["n"] = left
		hud.say("Çantan dolu.", Color("ff6a5a"))
		return
	var it := Items.get_item(e["id"])
	hud.say("Ganimet: " + it["name"], Items.RARITY_COL[it["rar"]])
	sfx.play("click", -4)
	m.loot.remove_at(i)
	inv_changed()
	if m.loot.is_empty():
		close_loot()

func gain_xp(n: float) -> void:
	if P["lvl"] >= 10:
		return
	P["xp"] += n
	while P["lvl"] < 10 and P["xp"] >= xp_need(P["lvl"]):
		P["xp"] -= xp_need(P["lvl"])
		P["lvl"] += 1
		P["hp"] = float(max_hp())
		inv_changed()
		ring_fx(Vector3(P["x"], P["y"], P["z"]), 3.0, Color("f2c75c"), 0.9)
		sfx.play("level")
		hud.banner("SEVİYE %d" % P["lvl"], "Can doldu")
		hud.say("Seviye atladın! Sv %d" % P["lvl"], Color("f2c75c"))
		for a in HudScript.ABIL:
			if a["lvl"] == P["lvl"]:
				hud.say("Yeni yetenek: %s" % a["name"], Color("7fb8ff"))
				hud.banner("SEVİYE %d" % P["lvl"], "Yeni yetenek: " + a["name"])

func swing() -> void:
	swing_t = 0.001
	sfx.play("swing", -10)

func auto_attack() -> void:
	var m = P["target"]
	if m == null or m.dead:
		return
	if dist_to(m) > 2.0:
		return
	P["atk_t"] = 1.5
	swing()
	P["yaw"] = atan2(m.x - P["x"], m.z - P["z"])
	hit_mob(m, roll(atk()))

func jump() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	if P["jy"] <= 0.001 and P["vy"] <= 0.0 and P["charge"] == null:
		P["vy"] = 8.6

func _face(m) -> void:
	P["yaw"] = atan2(m.x - P["x"], m.z - P["z"])

func ability(i: int) -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	if i == 9:
		use_potion()
		return
	var a: Dictionary = HudScript.ABIL[i]
	if P["lvl"] < a["lvl"]:
		hud.say("%s: Seviye %d'de öğrenilir." % [a["name"], a["lvl"]], Color("ff9a8a"))
		return
	if P["gcd"] > 0.0 or P["cd"][i] > 0.0:
		return
	var cost: float = a["cost"]
	if P["rage"] < cost:
		hud.say("Yeterli öfke yok.", Color("ff9a8a"))
		return
	var kind: String = a["kind"]
	var m = P["target"] if (P["target"] != null and not P["target"].dead) else null
	var pp := Vector3(P["x"], P["y"], P["z"])
	var melee := kind in ["strike", "rend", "execute", "mortal"]
	if melee or kind == "charge":
		if m == null:
			m = nearest_mob(25.0 if kind == "charge" else 6.0)
		if m == null:
			hud.say("Hedef yok.", Color("ff9a8a"))
			return
		P["target"] = m
		var dd := dist_to(m)
		if melee and dd > 2.6:
			hud.say("Hedef çok uzak.", Color("ff9a8a"))
			return
		if kind == "charge":
			if dd < 6.0:
				hud.say("Hedef çok yakın.", Color("ff9a8a"))
				return
			if dd > 25.0:
				hud.say("Hedef çok uzak.", Color("ff9a8a"))
				return
		if kind == "execute" and m.hp > m.maxhp * 0.2:
			hud.say("Hedef henüz yeterince yaralı değil.", Color("ff9a8a"))
			return
		_face(m)
	P["rage"] -= cost
	P["gcd"] = 1.0
	P["cd"][i] = a["cd"]
	P["combat_t"] = T
	match kind:
		"strike":
			swing()
			hit_mob(m, roll(atk() * 2.3), Color("ffd8a0"))
		"mortal":
			swing()
			ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.6, Color("ff5040"), 0.45)
			hit_mob(m, roll(atk() * 3.4), Color("ff9a8a"))
		"execute":
			swing()
			ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.8, Color("ffe45c"), 0.5)
			hit_mob(m, roll(atk() * 5.0), Color("ffe08a"))
		"rend":
			swing()
			m.bleed_t = 8.0
			m.bleed_tick = 2.0
			m.bleed_v = atk() * 0.55
			float_text(Vector3(m.x, 2.4 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), "Kanama", Color("ff6a5a"), false)
			hit_mob(m, roll(atk() * 0.5), Color("ffb0a0"))
		"charge":
			sfx.play("charge")
			P["charge"] = m
			P["charge_t"] = 0.0
			P["auto"] = false
			ring_fx(pp, 1.8, Color("ffd890"), 0.4)
		"shout":
			sfx.play("shout")
			P["bs_t"] = 60.0
			ring_fx(pp, 3.4, Color("ffd23a"), 0.6)
			float_text(pp + Vector3(0, 2.6, 0), "Savaş Narası!", Color("ffe08a"), true)
		"shield":
			sfx.play("block")
			P["sb_t"] = 5.0
			ring_fx(pp, 1.8, Color("59a9ff"), 0.5)
			float_text(pp + Vector3(0, 2.6, 0), "Kalkan Bloğu", Color("8ec9ff"), false)
		"clap":
			sfx.play("thunder")
			swing()
			ring_fx(pp, 6.0, Color("6aa8ff"), 0.55)
			var any := false
			for o in mobs:
				if not o.dead and dist_to(o) <= 6.0:
					any = true
					o.slow = 8.0
					hit_mob(o, roll(atk() * 1.0), Color("bfe0ff"))
			if not any:
				hud.say("Yakında düşman yok.", Color("ff9a8a"))
		"whirl":
			sfx.play("whirl")
			P["spin"] = 0.6
			swing()
			ring_fx(pp, 5.0, Color("c8f0f8"), 0.55)
			for o in mobs:
				if not o.dead and dist_to(o) <= 5.0:
					hit_mob(o, roll(atk() * 1.7), Color("d8f4ff"))
	if melee and not P["auto"] and P["target"] != null:
		P["auto"] = true

func use_potion(want: String = "") -> void:
	if mode != "play" or P["dead"]:
		return
	if potion_count() <= 0:
		hud.say("İksirin kalmadı.")
		return
	if P["pot_cd"] > 0.0:
		return
	if P["hp"] >= max_hp():
		hud.say("Canın zaten dolu.")
		return
	var id := want
	if id == "":
		var big: bool = inv.count("pot_big") > 0 and (max_hp() - P["hp"] > max_hp() * 0.45 or inv.count("pot_heal") == 0)
		id = "pot_big" if big else ("pot_heal" if inv.count("pot_heal") > 0 else "pot_big")
	inv.remove(id, 1)
	sfx.play("potion")
	P["pot_cd"] = 20.0
	var frac: float = Items.get_item(id)["heal"]
	var hv := mini(max_hp() - roundi(P["hp"]), roundi(max_hp() * frac))
	P["hp"] += hv
	float_text(Vector3(P["x"], P["y"] + 2.3, P["z"]), "+%d" % hv, Color("43d17f"), false)
	ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.4, Color("43d17f"), 0.5)
	inv_changed()

func toggle_auto() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	if P["auto"]:
		P["auto"] = false
		return
	if P["target"] == null or P["target"].dead:
		var m = nearest_mob(12.0)
		if m == null:
			hud.say("Yakında düşman yok.")
			return
		P["target"] = m
	P["auto"] = true

func hurt_player(raw: float, m) -> void:
	var arm: float = armor_total()
	var d := maxi(1, roundi(raw * (1.0 - minf(0.75, arm / (arm + 30.0 + m.lvl * 4.0)))))
	if P["sb_t"] > 0.0:
		d = maxi(1, roundi(d * 0.3))
		float_text(Vector3(P["x"], P["y"] + 2.9, P["z"]), "Bloklandı", Color("8ec9ff"), false)
		sfx.play("block", -6)
		add_rage(5.0)
	player_hp_loss(d)

func player_hp_loss(d: int) -> void:
	if P["dead"]:
		return
	P["hp"] -= d
	P["combat_t"] = T
	sfx.play("hurt", -4)
	add_rage(4.0)
	float_text(Vector3(P["x"], P["y"] + 2.2, P["z"]), "-%d" % d, Color("ff6a5a"), false)
	if P["hp"] <= 0.0 and not P["dead"]:
		P["dead"] = true
		P["dot_t"] = 0.0
		P["slow_t"] = 0.0
		sfx.play("die")
		P["dead_t"] = T
		P["auto"] = false
		P["target"] = null
		hud.show_dead(true)
		hud.say("Öldün.", Color("ff6a5a"))

func float_text(pos: Vector3, text: String, color: Color, big: bool) -> void:
	var l := Label3D.new()
	l.text = text
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.fixed_size = true
	l.pixel_size = 0.0011
	l.font_size = 64 if big else 44
	l.outline_size = 14
	l.position = pos
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", pos.y + 1.6, 1.0)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 1.0)
	tw.tween_callback(l.queue_free)

func ring_fx(pos: Vector3, radius: float, color: Color, dur: float) -> void:
	var t := TorusMesh.new()
	t.inner_radius = 0.9
	t.outer_radius = 1.0
	t.rings = 32
	t.ring_segments = 4
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(color.r, color.g, color.b, 0.9)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var mi := MeshInstance3D.new()
	mi.mesh = t
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos + Vector3(0, 0.15, 0)
	mi.scale = Vector3(0.4, 0.3, 0.4)
	add_child(mi)
	var tw := create_tween()
	tw.tween_property(mi, "scale", Vector3(radius, 0.3, radius), dur)
	tw.parallel().tween_property(m, "albedo_color:a", 0.0, dur)
	tw.tween_callback(mi.queue_free)

# ---------- görevler ve diyalog ----------
func q_avail(id: String) -> bool:
	return not qs.has(id) and P["lvl"] >= QUESTS[id]["lvl"]

func render_quests() -> void:
	var lines: Array = []
	for id in qs:
		var s: Dictionary = qs[id]
		if s["st"] == "done":
			continue
		lines.append("%s  %d/%d%s" % [QUESTS[id]["title"], s["n"], QUESTS[id]["n"], " — Teslim et" if s["st"] == "ready" else ""])
	hud.set_quests(lines)

func quest_kill(m) -> void:
	for id in qs:
		var s: Dictionary = qs[id]
		var d: Dictionary = QUESTS[id]
		if s["st"] == "active" and d["kill"] == m.nm:
			s["n"] += 1
			if s["n"] >= d["n"]:
				s["n"] = d["n"]
				s["st"] = "ready"
				hud.say("Görev tamam: %s (teslim et)" % d["title"], Color("7fe08a"))
				hud.banner("GÖREV HAZIR", d["title"])
				sfx.play("quest")
				save_game()
			else:
				hud.say("%s: %d/%d" % [d["title"], s["n"], d["n"]], Color("f2c75c"))
	render_quests()

func npc_mark(n: Dictionary) -> String:
	if n["role"] != "quest":
		return ""
	if qs.has(n["q"]) and qs[n["q"]]["st"] == "ready":
		return "?"
	return "!" if q_avail(n["q"]) else ""

func near_npc():
	var best = null
	var bd := 4.2
	for n in npcs:
		var d := Vector2(n["x"] - P["x"], n["z"] - P["z"]).length()
		if d < bd:
			bd = d
			best = n
	return best

func open_talk() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	var n = near_npc()
	if n == null:
		return
	dlg_open = true
	cur_npc = n
	P["auto"] = false
	render_dialog()

func close_dialog() -> void:
	dlg_open = false
	cur_npc = null
	hud.hide_dialog()

func item_brief(it: Dictionary) -> String:
	if it["slot"] == "mainhand":
		return "%d-%d hasar" % [it["dmin"], it["dmax"]]
	if it["armor"] > 0:
		return "%d zırh" % it["armor"]
	return "+%d güç" % it["str"] if it["str"] > 0 else "+%d çeviklik" % it["agi"]

func reward_pick(qid: String) -> void:
	var q: Dictionary = QUESTS[qid]
	var buttons: Array = []
	for id in q["rew"]:
		var it := Items.get_item(id)
		buttons.append({"label": "%s  (%s)" % [it["name"], item_brief(it)], "disabled": inv.free_slots() < 1, "cb": func():
			qs[qid]["st"] = "done"
			inv.add(id, 1)
			inv.money += q["money"]
			sfx.play("coin")
			hud.say("Ödül: %d XP, %s, %s" % [q["xp"], Items.money_plain(q["money"]), it["name"]], Color("f2c75c"))
			render_quests()
			close_dialog()
			gain_xp(q["xp"])
			inv_changed()
			save_game()})
	buttons.append({"label": "Geri", "cb": render_dialog})
	var body := "Bir ödül seç." if inv.free_slots() > 0 else "Çantan dolu, önce yer aç."
	hud.show_dialog(cur_npc["name"], cur_npc["title"], body, buttons)

func open_vendor(n: Dictionary) -> void:
	close_dialog()
	vendor_npc = n
	vendor_tab = 0
	invui.char_win.visible = false
	invui.vend_win.visible = true
	invui.bag_win.visible = true
	inv_changed()

func close_vendor() -> void:
	vendor_npc = null
	invui.vend_win.visible = false
	invui.hide_tip()

func render_dialog() -> void:
	var n = cur_npc
	var body := ""
	var buttons: Array = []
	if n["role"] == "quest":
		var q: Dictionary = QUESTS[n["q"]]
		if not qs.has(n["q"]):
			if P["lvl"] < q["lvl"]:
				body = "Biraz daha güçlenince gel. (Seviye %d gerekli)" % q["lvl"]
			else:
				body = "%s\n\nGörev: %d %s öldür.\nÖdül: %d tecrübe, %s ve bir eşya seçimi." % [q["text"], q["n"], q["kill"], q["xp"], Items.money_plain(q["money"])]
				buttons.append({"label": "Görevi kabul et", "cb": func():
					qs[n["q"]] = {"st": "active", "n": 0}
					sfx.play("quest")
					hud.say("Görev alındı: " + q["title"], Color("f2c75c"))
					save_game()
					render_quests()
					close_dialog()})
		else:
			var st: Dictionary = qs[n["q"]]
			if st["st"] == "active":
				body = "%s: %d/%d %s. Devam et!" % [q["title"], st["n"], q["n"], q["kill"]]
			elif st["st"] == "ready":
				body = q["done"]
				buttons.append({"label": "Ödülü al", "cb": func(): reward_pick(n["q"])})
			else:
				body = "Yardımın için sağ ol, kahraman."
	elif n["role"] == "vendor":
		body = "Taze iksirler, sıcak çorba, sağlam zırhlar! Ne lazım?"
		buttons.append({"label": "Alışveriş", "cb": func(): open_vendor(n)})
	elif n["role"] == "smith":
		var cost: int = 300 + 250 * P["wep_lvl"]
		buttons.append({"label": "Alışveriş", "cb": func(): open_vendor(n)})
		if P["wep_lvl"] >= 6:
			body = "Baltan bundan fazla bilenmez, usta. Yeni silah bakacak mısın?"
		else:
			body = "Baltanı bileyleyeyim mi? Her bileme +3 saldırı. Şu anki bileme: %d/6." % P["wep_lvl"]
			buttons.append({"label": "Bileyle (%s)" % Items.money_plain(cost), "disabled": inv.money < cost, "cb": func():
				if inv.money >= cost:
					inv.money -= cost
					P["wep_lvl"] += 1
					P["wep_b"] += 3.0
					sfx.play("block")
					hud.say("Silah bilendi: +3 saldırı", Color("f2c75c"))
					ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.6, Color("ffb040"), 0.5)
					inv_changed()
				render_dialog()})
	elif n["role"] == "inn":
		var wait := ceili(60.0 - (T - last_rest))
		if wait > 0:
			body = "Az önce dinlendin, biraz bekle (%d sn)." % wait
		else:
			body = "Sıcak çorba ve yumuşak yatak. Biraz dinlen, savaşçı."
			buttons.append({"label": "Dinlen (canı doldur)", "cb": func():
				P["hp"] = float(max_hp())
				P["rage"] = 0.0
				last_rest = T
				hud.say("Dinlendin, canın doldu.", Color("43d17f"))
				render_dialog()})
	buttons.append({"label": "Kapat", "cb": close_dialog})
	hud.show_dialog(n["name"], n["title"], body, buttons)

# ---------- güncelleme ----------
func _process(delta: float) -> void:
	if paused:
		return
	step(minf(delta, 0.05))

func collide(x: float, z: float, r: float) -> Vector2:
	for o in obs:
		var dx: float = x - o.x
		var dz: float = z - o.y
		var rr: float = r + o.z
		var d2 := dx * dx + dz * dz
		if d2 < rr * rr and d2 > 0.000001:
			var d := sqrt(d2)
			x = o.x + dx / d * rr
			z = o.y + dz / d * rr
	return Vector2(x, z)

func step(dt: float) -> void:
	T += dt
	_check_windows()
	if mode == "play" and not P["dead"]:
		save_t += dt
		if save_t >= 20.0:
			save_t = 0.0
			save_game()
	var ix := 0.0
	var iy := 0.0
	if mode == "play" and not P["dead"]:
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			ix -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			ix += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			iy += 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			iy -= 1.0
		if Input.is_key_pressed(KEY_Q):
			cam_yaw += dt * 1.8
		if Input.is_key_pressed(KEY_E):
			cam_yaw -= dt * 1.8
	if mode == "title":
		cam_yaw += dt * 0.12
	if dlg_open:
		ix = 0.0
		iy = 0.0
	_step_player(dt, ix, iy)
	if P["slow_t"] > 0.0:
		P["slow_t"] -= dt
	if P["dot_t"] > 0.0 and not P["dead"]:
		P["dot_t"] -= dt
		P["dot_k"] -= dt
		if P["dot_k"] <= 0.0:
			P["dot_k"] += 1.0
			player_hp_loss(maxi(1, roundi(P["dot_v"])))
	for m in mobs:
		_step_mob(m, dt)
	for i in range(mobs.size() - 1, -1, -1):
		if mobs[i].gc:
			mobs.remove_at(i)
	_step_npcs(dt)
	_animate_player(dt)
	_update_camera(dt)
	_step_effects(dt)
	_update_hud()

func _check_windows() -> void:
	if vendor_npc != null and Vector2(vendor_npc["x"] - P["x"], vendor_npc["z"] - P["z"]).length() > 7.0:
		close_vendor()
	if loot_mob != null and Vector2(loot_mob.x - P["x"], loot_mob.z - P["z"]).length() > 6.5 + (loot_mob.rad if loot_mob.boss != "" else 0.0):
		close_loot()

func _step_player(dt: float, ix: float, iy: float) -> void:
	var il := minf(1.0, Vector2(ix, iy).length())
	var moving: bool = il > 0.12 and mode == "play" and not P["dead"]
	if not P["dead"] and mode == "play":
		var fx := -sin(cam_yaw)
		var fz := -cos(cam_yaw)
		var rx := -fz
		var rz := fx
		var sp := 5.0 * (0.5 if P["slow_t"] > 0.0 else 1.0)
		var chm = P["charge"]
		if chm != null and (chm.dead or P["charge_t"] > 2.0):
			P["charge"] = null
			chm = null
		if chm != null:
			P["charge_t"] += dt
			var cdist := dist_to(chm)
			P["yaw"] = atan2(chm.x - P["x"], chm.z - P["z"])
			if cdist <= 1.7:
				P["charge"] = null
				add_rage(15.0)
				chm.stun = 1.5
				if chm.state == "idle":
					chm.state = "chase"
				ring_fx(Vector3(chm.x, height_at(chm.x, chm.z), chm.z), 2.2, Color("ffd890"), 0.4)
				float_text(Vector3(chm.x, 2.4 * chm.sc, chm.z) + Vector3(0, chm.node.position.y, 0), "Sersem", Color("8ec9ff"), false)
				P["combat_t"] = T
				P["auto"] = true
				P["spd"] = 0.0
			else:
				var cl: float = cdist + chm.rad
				var cc := collide(P["x"] + (chm.x - P["x"]) / cl * 24.0 * dt, P["z"] + (chm.z - P["z"]) / cl * 24.0 * dt, 0.5)
				P["x"] = cc.x
				P["z"] = cc.y
				P["spd"] = 1.8
		elif moving:
			var dx := fx * iy + rx * ix
			var dz := fz * iy + rz * ix
			var dl := maxf(0.0001, Vector2(dx, dz).length())
			dx /= dl
			dz /= dl
			var c := collide(P["x"] + dx * sp * il * dt, P["z"] + dz * sp * il * dt, 0.5)
			var rr := c.length()
			if rr > WORLD_R:
				c *= WORLD_R / rr
			P["x"] = c.x
			P["z"] = c.y
			if not (P["target"] != null and not P["target"].dead):
				P["auto"] = false
			var ty := atan2(dx, dz)
			var df := fposmod(ty - P["yaw"] + PI, TAU) - PI
			P["yaw"] += df * minf(1.0, dt * 14.0)
			P["spd"] = il
		elif P["auto"] and P["target"] != null and not P["target"].dead:
			var m = P["target"]
			var d0 := dist_to(m)
			if d0 > 1.8:
				var vx: float = (m.x - P["x"]) / (d0 + m.rad)
				var vz: float = (m.z - P["z"]) / (d0 + m.rad)
				var c2 := collide(P["x"] + vx * sp * dt, P["z"] + vz * sp * dt, 0.5)
				P["x"] = c2.x
				P["z"] = c2.y
				P["spd"] = 1.0
			else:
				P["spd"] = 0.0
			P["yaw"] = atan2(m.x - P["x"], m.z - P["z"])
		else:
			P["spd"] = 0.0
		P["atk_t"] = maxf(0.0, P["atk_t"] - dt)
		P["gcd"] = maxf(0.0, P["gcd"] - dt)
		P["pot_cd"] = maxf(0.0, P["pot_cd"] - dt)
		for i in 9:
			P["cd"][i] = maxf(0.0, P["cd"][i] - dt)
		P["bs_t"] = maxf(0.0, P["bs_t"] - dt)
		P["sb_t"] = maxf(0.0, P["sb_t"] - dt)
		P["spin"] = maxf(0.0, P["spin"] - dt)
		P["vy"] -= 24.0 * dt
		P["jy"] += P["vy"] * dt
		if P["jy"] <= 0.0:
			P["jy"] = 0.0
			P["vy"] = maxf(P["vy"], 0.0) if P["vy"] > 0.0 else 0.0
		if P["auto"] and P["target"] != null and not P["target"].dead and P["atk_t"] <= 0.0:
			auto_attack()
		var ooc := not in_combat()
		P["hp"] = minf(float(max_hp()), P["hp"] + (max_hp() * 0.015 if ooc else 0.3) * dt)
		if ooc:
			P["rage"] = maxf(0.0, P["rage"] - 4.0 * dt)
		if P["target"] != null and (P["target"].dead or Vector2(P["target"].x - P["x"], P["target"].z - P["z"]).length() > 30.0):
			P["target"] = null
			P["auto"] = false
	elif P["dead"]:
		P["spd"] = 0.0
		if T - P["dead_t"] > 3.2:
			P["dead"] = false
			P["hp"] = max_hp() * 0.6
			P["rage"] = 0.0
			P["x"] = 0.0
			P["z"] = 7.0
			P["combat_t"] = -99.0
			P["dot_t"] = 0.0
			P["slow_t"] = 0.0
			hud.show_dead(false)
			for m in mobs:
				if m.state == "chase":
					m.state = "return"
			hud.say("Kamp ateşinde canlandın.", Color("6aa8ff"))
	P["y"] = height_at(P["x"], P["z"]) + P["jy"]

# ---------- boss yetenekleri ----------
func _bpos(m) -> Vector3:
	return Vector3(m.x, m.node.position.y + (7.0 if m.boss == "ragnaros" else 2.6 * m.sc), m.z)

func _bready(m, key: String) -> bool:
	return m.cd.get(key, 0.0) <= 0.0

func _bset(m, key: String, t: float) -> void:
	m.cd[key] = t

func boss_say(m, text: String) -> void:
	hud.say(text, Color("ffb050"))

func boss_hit(m, mult: float, label: String) -> void:
	hurt_player(m.dmg * mult * (0.9 + randf() * 0.2), m)
	float_text(_bpos(m), label, Color("ffd060"), true)
	m.lunge = 0.25
	m.atk_t = maxf(m.atk_t, 1.2)

## Büyü hasarı: zırh sayılmaz, bloklanmaz.
func boss_spell(m, mult: float, label: String, col: Color) -> void:
	var dmg := maxi(1, roundi(m.dmg * mult * (0.9 + randf() * 0.2) * 0.75))
	player_hp_loss(dmg)
	float_text(_bpos(m), label, col, true)
	ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.8, col, 0.5)
	m.atk_t = maxf(m.atk_t, 1.0)

func knockback(m, dist: float) -> void:
	var dx: float = P["x"] - m.x
	var dz: float = P["z"] - m.z
	var l := maxf(0.01, sqrt(dx * dx + dz * dz))
	var c := collide(P["x"] + dx / l * dist, P["z"] + dz / l * dist, 0.5)
	var rr := c.length()
	if rr > WORLD_R:
		c *= WORLD_R / rr
	P["x"] = c.x
	P["z"] = c.y

func apply_dot(total_t: float, per_tick: float, label: String, col: Color) -> void:
	P["dot_t"] = total_t
	P["dot_v"] = per_tick
	P["dot_k"] = 1.0
	float_text(Vector3(P["x"], P["y"] + 2.9, P["z"]), label, col, false)

func _boss_engage(m) -> void:
	m.engaged = true
	boss_say(m, BOSSES[m.boss]["say"])
	hud.banner(m.nm.to_upper(), m.title)
	sfx.play("shout")
	match m.boss:
		"hogger":
			_bset(m, "sum", 0.0)
		"ragnaros":
			_bset(m, "wrath", 8.0)
			_bset(m, "lava", 5.0)
		"vancleef":
			_bset(m, "stab", 5.0)
			_bset(m, "poison", 6.0)
		"choksul":
			_bset(m, "slam", 5.0)
		"grik":
			_bset(m, "nova", 5.0)
			_bset(m, "bolt", 2.0)
		"arctikus":
			_bset(m, "maul", 5.0)
			_bset(m, "rend", 8.0)

func _boss_reset(m) -> void:
	m.engaged = false
	m.cd = {}
	m.flags = {}
	m.eat_t = 0.0
	m.dmg = m.base_dmg
	m.spd = m.base_spd
	m.atk_int = 2.4
	for a in mobs:
		if a.owner_m == m and not a.dead:
			a.dead = true
			a.died_at = T
			a.fade_t = T
			a.loot = []
			a.loot_money = 0
	if m.dead:
		return
	m.hp = minf(m.maxhp, m.hp)

func _boss_summon(m, nm: String, model: String, n: int, hp: float, dmg: float, spd: float, sc: float, ring: float) -> void:
	for i in n:
		var a := float(i) / n * TAU + randf()
		spawn_add(m, nm, model, m.lvl - 1, hp, dmg, spd, sc, Vector2(cos(a), sin(a)) * ring)

## true: bu tur sıradan saldırı yapma.
func _boss_ai(m, dt: float, d: float) -> bool:
	for k in m.cd.keys():
		m.cd[k] = maxf(0.0, m.cd[k] - dt)
	var hpf: float = m.hp / m.maxhp
	if m.eat_t > 0.0:
		m.eat_t -= dt
		m.hp = minf(m.maxhp, m.hp + m.maxhp * 0.06 * dt)
		return true
	var melee: bool = d <= m.rad + m.reach + 0.6
	match m.boss:
		"arctikus":
			if hpf < 0.35 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.25
				boss_say(m, "Büyük Baba Arctikus öfkelendi!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if melee and _bready(m, "maul"):
				_bset(m, "maul", 7.0)
				boss_hit(m, 2.2, "Parçala!")
				return true
			if melee and _bready(m, "rend"):
				_bset(m, "rend", 15.0)
				apply_dot(8.0, m.dmg * 0.14, "Yırtma", Color("ff4a4a"))
				m.atk_t = maxf(m.atk_t, 1.0)
				return true
		"grik":
			if d <= 6.5 and _bready(m, "nova"):
				_bset(m, "nova", 9.0)
				boss_spell(m, 1.3, "Don Dalgası", Color("8ae0ff"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 6.0, Color("8ae0ff"), 0.6)
				P["slow_t"] = 4.0
				return true
			if d > 5.0 and d < 17.0 and _bready(m, "bolt"):
				_bset(m, "bolt", 5.0)
				boss_spell(m, 0.9, "Buz Oku", Color("b8f0ff"))
		"choksul":
			if hpf < 0.3 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.35
				m.atk_int = 1.8
				boss_say(m, "Chok'sul: EZİN!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
			if d <= 7.0 and _bready(m, "slam"):
				_bset(m, "slam", 9.0)
				boss_spell(m, 1.5, "Yer Yarığı", Color("d8b070"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 7.0, Color("d8b070"), 0.6)
				knockback(m, 7.0)
				sfx.play("thunder", -4)
				return true
		"hogger":
			if not m.flags.has("s0"):
				m.flags["s0"] = true
				boss_say(m, "Hogger gnoll çıraklarını çağırdı!")
				_boss_summon(m, "Gnoll Çırağı", "gnoll", 2, 100.0, 9.0, 4.0, 0.9, 3.0)
			if hpf < 0.5 and not m.flags.has("s1"):
				m.flags["s1"] = true
				boss_say(m, "Hogger: Yiiipe! Gelin, gelin!")
				_boss_summon(m, "Gnoll Çırağı", "gnoll", 2, 100.0, 9.0, 4.0, 0.9, 3.0)
			if hpf < 0.4 and not m.flags.has("eat"):
				m.flags["eat"] = true
				m.eat_t = 4.0
				boss_say(m, "Hogger yemek yiyor ve canını yeniliyor!")
				float_text(_bpos(m), "Yiyor...", Color("43d17f"), true)
				return true
			if melee and _bready(m, "cleave"):
				_bset(m, "cleave", 8.0)
				boss_hit(m, 1.7, "Pençe!")
				return true
		"vancleef":
			for t in [0.75, 0.5, 0.25]:
				var key := "w%d" % roundi(t * 100.0)
				if hpf < t and not m.flags.has(key):
					m.flags[key] = true
					boss_say(m, "VanCleef: Muhafızlar! Şunları öldürün!")
					_boss_summon(m, "Defias Haydudu", "defias", 2, 150.0, 11.0, 4.2, 1.0, 3.0)
			if hpf < 0.5 and not m.flags.has("thrash"):
				m.flags["thrash"] = true
				m.atk_int = 1.5
				boss_say(m, "VanCleef: Hiçbir şey beni durduramaz!")
				float_text(_bpos(m), "Çılgınlık!", Color("ff6a3a"), true)
			if melee and _bready(m, "stab"):
				_bset(m, "stab", 8.0)
				boss_hit(m, 2.0, "Sırttan Bıçak!")
				return true
			if melee and _bready(m, "poison"):
				_bset(m, "poison", 12.0)
				apply_dot(10.0, m.dmg * 0.1, "Ölümcül Zehir", Color("7be85a"))
		"ragnaros":
			if hpf < 0.5 and not m.flags.has("s1"):
				m.flags["s1"] = true
				boss_say(m, "Ragnaros: ALEV OĞULLARIM, ÖNÜNÜZE ÇIKIN!")
				_boss_summon(m, "Alev Oğlu", "ember", 4, 220.0, 22.0, 3.8, 1.0, 8.0)
			if hpf < 0.25 and not m.flags.has("s2"):
				m.flags["s2"] = true
				boss_say(m, "Ragnaros: ÇOK ERKEN GELDİNİZ!")
				_boss_summon(m, "Alev Oğlu", "ember", 4, 220.0, 22.0, 3.8, 1.0, 8.0)
			if _bready(m, "wrath"):
				_bset(m, "wrath", 22.0)
				boss_say(m, "Ragnaros: Ateşin gazabını tadın!")
				boss_spell(m, 1.8, "Ragnaros'un Gazabı", Color("ff7a30"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z) + 1.5, m.z), 14.0, Color("ff7a30"), 0.8)
				knockback(m, 12.0)
				sfx.play("thunder", -2)
				return true
			if melee and _bready(m, "lava"):
				_bset(m, "lava", 12.0)
				boss_hit(m, 2.2, "Lav Patlaması")
				return true
			if d > m.rad + m.reach + 1.5 and d < 34.0 and _bready(m, "magma"):
				_bset(m, "magma", 3.0)
				boss_spell(m, 1.0, "Magma Topu", Color("ff9a40"))
	return false

func _step_mob(m, dt: float) -> void:
	var node: Node3D = m.node
	if m.dead:
		var k: float = T - m.died_at
		var kf: float = T - m.fade_t if m.fade_t > 0.0 else k - 0.8
		var gy: float = height_at(m.x, m.z) + m.yoff
		if m.boss == "ragnaros":
			node.rotation.z = 0.0
			node.position.y = gy - minf(k, 2.5) * 1.2
			if kf >= 0.0:
				node.visible = false
		elif k < 0.8:
			node.rotation.z = lerpf(0.0, 1.5, k / 0.8)
			node.position.y = gy + 0.1
		elif kf < 0.0:
			node.rotation.z = 1.5
			node.position.y = gy + 0.1
		elif kf < 0.8:
			node.scale = Vector3.ONE * m.sc * maxf(0.001, 1.0 - kf / 0.8)
		else:
			node.visible = false
		if m.temp and kf >= 0.8 and not m.gc:
			m.gc = true
			node.queue_free()
			hud.plate_hide(m.id)
			if loot_mob == m:
				close_loot()
			return
		if m.sparkle != null:
			m.sparkle.position.y = height_at(m.x, m.z) + 0.8 + sin(T * 4.0) * 0.1
			if kf >= 0.0 or loot_mob == null and m.loot.is_empty():
				m.sparkle.queue_free()
				m.sparkle = null
		if k > m.respawn and not m.temp:
			m.dead = false
			m.hp = m.maxhp
			m.x = m.hx
			m.z = m.hz
			m.state = "idle"
			m.bleed_t = 0.0
			m.slow = 0.0
			m.loot = []
			m.loot_money = 0
			m.fade_t = 0.0
			if m.sparkle != null:
				m.sparkle.queue_free()
				m.sparkle = null
			if loot_mob == m:
				close_loot()
			node.visible = true
			node.rotation.z = 0.0
			node.scale = Vector3.ONE * m.sc
			node.position.y = height_at(m.x, m.z) + m.yoff
			_boss_reset(m)
		return
	var dx: float = P["x"] - m.x
	var dz: float = P["z"] - m.z
	var d := sqrt(dx * dx + dz * dz)
	var moving := false
	m.stun = maxf(0.0, m.stun - dt)
	m.slow = maxf(0.0, m.slow - dt)
	var msp: float = m.spd * (0.5 if m.slow > 0.0 else 1.0)
	if m.bleed_t > 0.0:
		m.bleed_t -= dt
		m.bleed_tick -= dt
		if m.bleed_tick <= 0.0:
			m.bleed_tick += 2.0
			var bd := maxi(1, roundi(m.bleed_v * (0.9 + randf() * 0.2)))
			m.hp -= bd
			float_text(Vector3(m.x, 1.9 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), str(bd), Color("ff6a5a"), false)
			if m.hp <= 0.0:
				kill_mob(m)
				return
	if mode == "play" and not P["dead"] and m.state == "idle" and d < m.aggro:
		m.state = "chase"
	if m.boss != "":
		if m.state == "chase" and not m.engaged:
			_boss_engage(m)
		elif m.state != "chase" and m.engaged:
			_boss_reset(m)
		if m.state == "chase" and m.spd == 0.0 and d > 40.0:
			m.state = "return"
	if P["dead"] and m.state == "chase":
		m.state = "return"
	if m.stun > 0.0:
		pass
	elif m.state == "chase":
		var hd := Vector2(m.x - m.hx, m.z - m.hz).length()
		if hd > 38.0:
			m.state = "return"
		elif d > m.rad + 0.9 and m.eat_t <= 0.0:
			var c := collide(m.x + dx / d * msp * dt, m.z + dz / d * msp * dt, m.rad * 0.6)
			m.x = c.x
			m.z = c.y
			moving = true
		m.yaw = atan2(dx, dz)
		m.atk_t -= dt
		var busy := false
		if m.boss != "":
			busy = _boss_ai(m, dt, d)
		if not busy and d <= m.rad + m.reach and m.atk_t <= 0.0:
			m.atk_t = m.atk_int
			hurt_player(m.dmg * (0.85 + randf() * 0.3), m)
			m.lunge = 0.2
	elif m.state == "return":
		var rx: float = m.hx - m.x
		var rz: float = m.hz - m.z
		var rd := sqrt(rx * rx + rz * rz)
		if rd < 0.6:
			m.state = "idle"
		else:
			m.x += rx / rd * m.spd * 1.2 * dt
			m.z += rz / rd * m.spd * 1.2 * dt
			m.yaw = atan2(rx, rz)
			moving = true
		m.hp = minf(m.maxhp, m.hp + m.maxhp * 0.25 * dt)
	else:
		m.w_t -= dt
		if m.w_t <= 0.0:
			m.w_t = 2.0 + randf() * 4.0
			var a := randf() * TAU
			var r := randf() * 5.0
			m.wx = m.hx + cos(a) * r
			m.wz = m.hz + sin(a) * r
		var wx: float = m.wx - m.x
		var wz: float = m.wz - m.z
		var wd := sqrt(wx * wx + wz * wz)
		if wd > 0.5:
			m.x += wx / wd * 1.2 * dt
			m.z += wz / wd * 1.2 * dt
			m.yaw = atan2(wx, wz)
			moving = true
	if m.lunge > 0.0:
		m.lunge -= dt
	var y: float = height_at(m.x, m.z) + m.yoff
	node.position = Vector3(m.x, y, m.z)
	node.rotation = Vector3(0, m.yaw, 0)
	if m.lunge > 0.0:
		node.position += Vector3(sin(m.yaw), 0, cos(m.yaw)) * 0.25
	m.ph += dt * ((6.0 if m.state == "idle" else 12.0) if moving else 0.0)
	var s := sin(m.ph) * 0.7 if moving else 0.0
	m.legs[0].rotation.x = s
	m.legs[3].rotation.x = s
	m.legs[1].rotation.x = -s
	m.legs[2].rotation.x = -s

func _step_npcs(dt: float) -> void:
	for n in npcs:
		var node: Node3D = n["node"]
		var nr: Dictionary = node.get_meta("rig")
		var d := Vector2(n["x"] - P["x"], n["z"] - P["z"]).length()
		if d < 7.0:
			var ty := atan2(P["x"] - n["x"], P["z"] - n["z"])
			var df := fposmod(ty - node.rotation.y + PI, TAU) - PI
			node.rotation.y += df * minf(1.0, dt * 4.0)
		if n["role"] == "smith":
			nr["armR"].rotation.x = -0.9 + sin(T * 5.0) * 0.7
		else:
			nr["armR"].rotation.x = sin(T * 1.7 + n["x"]) * 0.04
		node.position.y = n["y"] + sin(T * 1.4 + n["z"]) * 0.015

func _animate_player(dt: float) -> void:
	var ph0 := walk_ph
	walk_ph += P["spd"] * dt * 9.0
	if P["spd"] > 0.2 and P["jy"] <= 0.05 and floorf(walk_ph / PI) != floorf(ph0 / PI):
		sfx.play("step", -16)
	var sw: float = sin(walk_ph) * 0.75 * P["spd"]
	var air: bool = P["jy"] > 0.05
	rig["legL"].rotation.x = -0.7 if air else sw
	rig["legR"].rotation.x = 0.3 if air else -sw
	rig["armL"].rotation.x = -2.2 if air else (-0.3 - sw * 0.35)
	var bob: float = absf(sin(walk_ph)) * 0.07 * P["spd"]
	if swing_t > 0.0:
		swing_t += dt
		var u := swing_t / 0.38
		if u >= 1.0:
			swing_t = 0.0
			rig["armR"].rotation.x = sw * 0.35
		else:
			rig["armR"].rotation.x = lerpf(-2.5, 0.5, u * u)
	else:
		rig["armR"].rotation.x = sw * 0.35 - 0.2 + sin(T * 2.0) * 0.03
	player.position = Vector3(P["x"], P["y"] + bob, P["z"])
	player.rotation.y = P["yaw"] + ((1.0 - P["spin"] / 0.6) * TAU if P["spin"] > 0.0 else 0.0)
	if P["dead"]:
		player.rotation.x = lerpf(player.rotation.x, -1.4, minf(1.0, dt * 6.0))
		player.position.y = P["y"] + 0.3
	else:
		player.rotation.x = lerpf(player.rotation.x, 0.0, minf(1.0, dt * 10.0))

func _update_camera(_dt: float) -> void:
	var cp := cos(cam_pitch)
	var tgt := Vector3(P["x"], P["y"] + 1.6, P["z"])
	var pos := Vector3(P["x"] + sin(cam_yaw) * cp * cam_dist, P["y"] + 1.9 + sin(cam_pitch) * cam_dist, P["z"] + cos(cam_yaw) * cp * cam_dist)
	var gh := height_at(pos.x, pos.z) + 1.0
	if pos.y < gh:
		pos.y = gh
	cam.position = pos
	cam.look_at(tgt, Vector3.UP)
	if snow_node:
		snow_node.position = Vector3(P["x"], P["y"] + 16.0, P["z"])

func _step_effects(_dt: float) -> void:
	for f in flame_nodes:
		f.scale = Vector3(1.0 + sin(T * 14.0) * 0.12, 1.0 + sin(T * 11.0 + 1.0) * 0.2, 1.0 + sin(T * 13.0) * 0.12)
	if fire_light:
		fire_light.light_energy = 2.3 + sin(T * 17.0) * 0.4 + sin(T * 9.0) * 0.25
	if forge_light:
		forge_light.light_energy = 3.0 + sin(T * 9.0) * 0.5
	if gate_light:
		gate_light.light_energy = 2.0 + sin(T * 11.0) * 0.4
	if lava_mat:
		lava_mat.emission_energy_multiplier = 3.5 + sin(T * 3.0) * 0.6

func _lvl_color(l: int) -> Color:
	var d: int = l - P["lvl"]
	if d >= 4:
		return Color("ff4a4a")
	if d >= 2:
		return Color("ff9a3a")
	if d >= -1:
		return Color("ffe45c")
	if d >= -3:
		return Color("7fe08a")
	return Color("a8a8a8")

func _mob_kind(m) -> String:
	if m.kind in ["skull", "dwarf", "bear"] and m.boss != "":
		return m.kind
	if m.temp:
		return "skull"
	if m.nm == "Kurt":
		return "wolf"
	if m.nm == "Yaban Domuzu":
		return "boar"
	return "bear"

func _update_hud() -> void:
	if hud == null:
		return
	var buffs: Array = []
	if P["bs_t"] > 0.0:
		buffs.append({"kind": "shout", "t": P["bs_t"]})
	if P["sb_t"] > 0.0:
		buffs.append({"kind": "shield", "t": P["sb_t"]})
	var t0 = P["target"]
	var exec_ok: bool = t0 != null and not t0.dead and t0.hp <= t0.maxhp * 0.2 and P["lvl"] >= 4
	hud.update_player({"lvl": P["lvl"], "hp": P["hp"], "maxhp": max_hp(), "rage": P["rage"], "xp": P["xp"], "xpneed": xp_need(P["lvl"]),
		"money": Items.money_short(inv.money), "cd": P["cd"], "gcd": P["gcd"], "pot": potion_count(), "potcd": P["pot_cd"], "exec_ok": exec_ok, "buffs": buffs})
	var t = P["target"]
	if t != null and not t.dead:
		hud.update_target({"name": t.nm, "lvl": t.lvl, "hp": t.hp, "maxhp": t.maxhp, "color": _lvl_color(t.lvl), "kind": _mob_kind(t),
			"hint": "Kanıyor" if t.bleed_t > 0.0 else ("Yavaş" if t.slow > 0.0 else "")})
	else:
		hud.update_target({})
	var mp: Array = []
	for m in mobs:
		if not m.dead:
			mp.append(Vector2(m.x, m.z))
	var np: Array = []
	for n in npcs:
		np.append({"p": Vector2(n["x"], n["z"]), "mark": npc_mark(n)})
	hud.update_minimap({"px": P["x"], "pz": P["z"], "cam_yaw": cam_yaw, "pyaw": P["yaw"], "mobs": mp, "npcs": np})
	# isim levhaları
	for m in mobs:
		var show: bool = mode == "play" and not m.dead and Vector2(m.x - P["x"], m.z - P["z"]).length() < (40.0 if m.boss != "" else 22.0)
		var wp := Vector3(m.x, m.node.position.y + (1.7 * m.sc + 0.3 if m.boss != "ragnaros" else 8.8), m.z)
		if show and not cam.is_position_behind(wp):
			hud.plate(m.id, cam.unproject_position(wp), "%s %d" % [m.nm, m.lvl], _lvl_color(m.lvl), m.hp / m.maxhp, ("<" + m.title + ">") if m.boss != "" else "", "", P["target"] == m)
		else:
			hud.plate_hide(m.id)
	for n in npcs:
		var wp2 := Vector3(n["x"], n["y"] + 2.4, n["z"])
		var d := Vector2(n["x"] - P["x"], n["z"] - P["z"]).length()
		if mode == "play" and d < 26.0 and not cam.is_position_behind(wp2):
			hud.plate("npc_" + n["id"], cam.unproject_position(wp2), n["name"], Color("7fe08a"), -1.0, "<" + n["title"] + ">", npc_mark(n), false)
		else:
			hud.plate_hide("npc_" + n["id"])
	var nn = near_npc()
	hud.set_prompt(("G — Konuş: " + nn["name"]) if (nn != null and not dlg_open and mode == "play" and not P["dead"]) else "")
	# bölge
	var dc := Vector2(P["x"] - CITY.x, P["z"] - CITY.z).length()
	var dv := Vector2(P["x"], P["z"]).length()
	var z := "c" if dc < 27.0 else ("v" if dv < 16.0 else "w")
	if z != zone_now:
		zone_now = z
		if mode == "play":
			if z == "c":
				hud.banner("DEMİRKAZAN", "Cüce başkenti")
			elif z == "v":
				hud.banner("KAR DAĞI KÖYÜ", "Kamp ateşi")
			else:
				hud.banner("KAR DAĞI VADİSİ", "Cüce toprakları")
		hud.set_zone("Demirkazan" if z == "c" else ("Kar Dağı Köyü" if z == "v" else "Kar Dağı Vadisi"))

# ---------- kendi kendine test ----------
