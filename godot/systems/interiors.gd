extends RefCounted
## Köy evlerinin iç mekânları: 10x10'luk odalar, ana dünyadan uzakta kurulur.
## Host (main.gd) `_wow_spawn` ve `_add_obs` sağlar. Mobilya gerçek ölçekli Quaternius modelleridir (FURN_SCALE ile küçültülür).

const SIZE := 10.0
const WALL_H := 3.6
const FURN_SCALE := 0.55
const PACK := "house_interior_pack/"

## Giriş noktası (oyuncunun doğduğu yer) ve çıkış kapısı noktası, oda merkezine göre.
const SPAWN := Vector2(0.0, 2.2)
const EXIT_SPOT := Vector2(0.0, 3.4)

## Oda içeriği: [model, x, z, yön, çarpışma yarıçapı, ölçek çarpanı, y]
const LAYOUTS := {
	"tavern": [
		["Fireplace", 0.0, -4.55, 0.0, 0.0, 1.0, 0.0],
		["Shelf_Large", -3.3, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Bookshelf", 3.3, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Table_RoundLarge", -2.6, -0.6, 0.0, 1.0, 1.0, 0.0],
		["Table_RoundLarge", 2.6, 1.2, 0.4, 1.0, 1.0, 0.0],
		["Stool", -2.6, 0.9, 0.0, 0.3, 1.0, 0.0],
		["Stool", -4.0, -0.9, 0.0, 0.3, 1.0, 0.0],
		["Stool", -1.2, -1.0, 0.0, 0.3, 1.0, 0.0],
		["Stool", 2.6, 2.7, 0.0, 0.3, 1.0, 0.0],
		["Stool", 4.0, 1.0, 0.0, 0.3, 1.0, 0.0],
		["Carpet_Round", 0.0, 0.9, 0.0, 0.0, 1.0, 0.02],
		["Houseplant_1", -4.2, 4.2, 0.0, 0.3, 1.0, 0.0],
		["Houseplant_2", 4.2, 4.2, 0.0, 0.3, 1.0, 0.0],
		["Window_Large1", -4.85, -0.5, PI / 2.0, 0.0, 1.0, 1.1],
		["Window_Large1", 4.85, -0.5, -PI / 2.0, 0.0, 1.0, 1.1],
		["Light_Chandelier", 0.0, 0.0, 0.0, 0.0, 1.0, 3.3],
	],
	"bedroom": [
		["Bed_Single", -3.3, -2.8, 0.0, 1.1, 1.0, 0.0],
		["Bed_King", 3.2, -2.8, 0.0, 1.3, 1.0, 0.0],
		["NightStand_1", -1.4, -4.3, 0.0, 0.0, 1.0, 0.0],
		["NightStand_1", 0.9, -4.3, 0.0, 0.0, 1.0, 0.0],
		["Drawer_2", -3.0, 4.35, PI, 0.0, 1.0, 0.0],
		["Carpet_1", 0.0, 0.2, 0.0, 0.0, 1.0, 0.02],
		["Couch_Small1", 4.0, 1.8, -PI / 2.0, 1.0, 1.0, 0.0],
		["Houseplant_3", -4.2, -4.2, 0.0, 0.3, 1.0, 0.0],
		["Window_Large1", -4.85, 0.8, PI / 2.0, 0.0, 1.0, 1.1],
		["Curtains_Double", -4.7, 0.8, PI / 2.0, 0.0, 0.85, 0.0],
		["Light_Chandelier", 0.0, 0.0, 0.0, 0.0, 1.0, 3.3],
	],
	"library": [
		["Bookshelf", -2.6, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Bookshelf", -1.3, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Bookshelf", 0.0, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Bookshelf", 1.3, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Bookshelf", 2.6, -4.6, 0.0, 0.0, 1.0, 0.0],
		["Bookshelf", -4.6, -2.0, PI / 2.0, 0.0, 1.0, 0.0],
		["Bookshelf", -4.6, -0.7, PI / 2.0, 0.0, 1.0, 0.0],
		["Bookshelf", -4.6, 0.6, PI / 2.0, 0.0, 1.0, 0.0],
		["Bookshelf", 4.6, -2.0, -PI / 2.0, 0.0, 1.0, 0.0],
		["Bookshelf", 4.6, -0.7, -PI / 2.0, 0.0, 1.0, 0.0],
		["Table_RoundSmall", 0.4, 0.2, 0.0, 0.8, 1.0, 0.0],
		["Chair_1", -1.1, 0.2, PI / 2.0, 0.3, 1.0, 0.0],
		["Chair_1", 1.9, 0.2, -PI / 2.0, 0.3, 1.0, 0.0],
		["Carpet_Round", 0.4, 0.2, 0.0, 0.0, 1.0, 0.02],
		["Houseplant_5", 4.2, 4.2, 0.0, 0.3, 1.0, 0.0],
		["Light_Chandelier", 0.0, 0.0, 0.0, 0.0, 1.0, 3.3],
	],
}

static func _box(host: Node3D, size: Vector3, pos: Vector3, mat: Material) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	mi.position = pos
	host.add_child(mi)

static func _mat(color: Color, rough: float = 0.9) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m

## Odayı (cx, cz) merkezine kurar. Duvarlar çarpışma halkalarıyla korunur.
static func build(host: Node3D, kind: String, cx: float, cz: float) -> void:
	var half := SIZE * 0.5
	var floor_m := _mat(Color("6e4f33"), 0.8)
	var wall_m := _mat(Color("d9c7a3"))
	var beam_m := _mat(Color("4a3322"))
	_box(host, Vector3(SIZE + 0.8, 0.3, SIZE + 0.8), Vector3(cx, -0.15, cz), floor_m)
	_box(host, Vector3(SIZE + 0.8, WALL_H, 0.4), Vector3(cx, WALL_H * 0.5, cz - half - 0.2), wall_m)
	_box(host, Vector3(SIZE + 0.8, WALL_H, 0.4), Vector3(cx, WALL_H * 0.5, cz + half + 0.2), wall_m)
	_box(host, Vector3(0.4, WALL_H, SIZE), Vector3(cx - half - 0.2, WALL_H * 0.5, cz), wall_m)
	_box(host, Vector3(0.4, WALL_H, SIZE), Vector3(cx + half + 0.2, WALL_H * 0.5, cz), wall_m)
	# köşe kirişleri ve alt pervaz
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			_box(host, Vector3(0.5, WALL_H, 0.5), Vector3(cx + sx * (half + 0.05), WALL_H * 0.5, cz + sz * (half + 0.05)), beam_m)
	_box(host, Vector3(SIZE, 0.35, 0.12), Vector3(cx, 0.175, cz - half + 0.06), beam_m)
	_box(host, Vector3(SIZE, 0.35, 0.12), Vector3(cx, 0.175, cz + half - 0.06), beam_m)
	_box(host, Vector3(0.12, 0.35, SIZE), Vector3(cx - half + 0.06, 0.175, cz), beam_m)
	_box(host, Vector3(0.12, 0.35, SIZE), Vector3(cx + half - 0.06, 0.175, cz), beam_m)
	# duvar çarpışması: iç çevre boyunca halkalar
	var n := int(SIZE / 1.0)
	for i in n + 1:
		var t := -half + SIZE * float(i) / float(n)
		host.call("_add_obs", cx + t, cz - half - 0.2, 0.9)
		host.call("_add_obs", cx + t, cz + half + 0.2, 0.9)
		host.call("_add_obs", cx - half - 0.2, cz + t, 0.9)
		host.call("_add_obs", cx + half + 0.2, cz + t, 0.9)
	# çıkış kapısı (güney duvar)
	host.call("_wow_spawn", PACK + "Door_1.glb", Vector3(cx, 0.0, cz + half - 0.1), PI, FURN_SCALE)
	# mobilya
	for it in LAYOUTS.get(kind, LAYOUTS["bedroom"]):
		var sc: float = FURN_SCALE * float(it[5])
		host.call("_wow_spawn", PACK + str(it[0]) + ".glb", Vector3(cx + float(it[1]), float(it[6]), cz + float(it[2])), float(it[3]), sc)
		if float(it[4]) > 0.0:
			host.call("_add_obs", cx + float(it[1]), cz + float(it[2]), float(it[4]))
	# sıcak ışık
	var li := OmniLight3D.new()
	li.light_color = Color("ffb070")
	li.omni_range = 14.0
	li.light_energy = 1.7
	li.shadow_enabled = false
	li.position = Vector3(cx, 3.0, cz)
	host.add_child(li)
