extends Control
## Dünya haritası penceresi (M): bölgenin tamamı, kamplar, bosslar, portallar, NPC'ler ve oyuncu.

const Glyph = preload("res://glyph.gd")
const SZ := 460.0

var map_name := "snow"
var world_r := 92.0
var city := Vector3(0, -58, 24)
var camps: Array = []
var bosses: Array = []
var portals: Array = []
var npcs: Array = []
var mine_rooms: Array = []
var mine_alc: Array = []
var px := 0.0
var pz := 0.0
var pyaw := 0.0
var title := ""

func _init() -> void:
	size = Vector2(SZ + 28, SZ + 56)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	z_index = 25

func _s(x: float, z: float) -> Vector2:
	# kuzey yukarı: -z yukarı
	var ext := 22.0 + (95.0 if map_name == "mine" else world_r)
	var c := Vector2(14 + SZ * 0.5, 42 + SZ * 0.5)
	var cz := 0.0 if map_name != "mine" else 5.0
	return c + Vector2(x, z - cz) * (SZ * 0.5 / ext)

func _lbl(p: Vector2, t: String, col: Color, fs: int = 11) -> void:
	var f := ThemeDB.fallback_font
	draw_string_outline(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 4, Color(0, 0, 0, 0.9))
	draw_string(f, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0.06, 0.05, 0.04, 0.97))
	draw_rect(r, Color("c9a24a"), false, 3.0)
	_lbl(Vector2(16, 26), title + "   (M: kapat)", Color("f2c75c"), 17)
	var base := Color("3a3438") if map_name == "mine" else (Color("6f8458") if map_name == "swamp" else (Color("5a4640") if map_name == "ash" else Color("c7d6e6")))
	var area := Rect2(14, 42, SZ, SZ)
	draw_rect(area, Color(0.02, 0.02, 0.02))
	if map_name == "mine":
		for rm in mine_rooms:
			draw_circle(_s(rm[0], rm[1]), rm[2] * SZ * 0.5 / 117.0, base.lightened(0.15))
		for a in mine_alc:
			draw_circle(_s(a[0], a[1]), a[2] * SZ * 0.5 / 117.0, base.lightened(0.1))
		for i in range(mine_rooms.size() - 1):
			draw_line(_s(mine_rooms[i][0], mine_rooms[i][1]), _s(mine_rooms[i + 1][0], mine_rooms[i + 1][1]), base.lightened(0.15), 6.0)
	else:
		draw_circle(_s(0, 0), world_r * SZ * 0.5 / (22.0 + world_r), base)
		draw_arc(_s(0, 0), world_r * SZ * 0.5 / (22.0 + world_r), 0, TAU, 80, Color("5a4a30"), 3.0, true)
		if map_name == "snow":
			draw_circle(_s(city.x, city.y), city.z * SZ * 0.5 / (22.0 + world_r), Color("b9a98c"))
			_lbl(_s(city.x, city.y) + Vector2(-34, 4), "Demirkazan", Color("fff2c0"), 12)
			draw_line(_s(0, -6), _s(0, city.y + city.z), Color("b09870"), 4.0, true)
			_lbl(_s(0, 0) + Vector2(-34, 22), "Kar Dağı Köyü", Color("2a3a4a"), 11)
	var seen := {}
	for c in camps:
		var p := _s(c["x"], c["z"])
		var key := Vector2i(roundi(c["x"]), roundi(c["z"]))
		if seen.has(key):
			continue
		seen[key] = true
		draw_circle(p, 7.0, Color(0.85, 0.15, 0.15, 0.35))
		draw_arc(p, 7.0, 0, TAU, 16, Color("e03a3a"), 1.5)
		_lbl(p + Vector2(-16, -10), str(c.get("name", "")), Color("ffb0a0"), 10)
	for b in bosses:
		var p2 := _s(b["x"], b["z"])
		var sk := PackedVector2Array([p2 + Vector2(0, -7), p2 + Vector2(6, 0), p2 + Vector2(0, 7), p2 + Vector2(-6, 0)])
		draw_colored_polygon(sk, Color("ff3a3a") if not b.get("dead", false) else Color("606060"))
		_lbl(p2 + Vector2(8, 4), b["name"], Color("ffd0a0"), 10)
	for pt in portals:
		var p3 := _s(pt["x"], pt["z"])
		draw_arc(p3, 7.0, 0, TAU, 16, Color("b07aff"), 3.0)
		_lbl(p3 + Vector2(-30, -10), pt["label"], Color("e0c8ff"), 10)
	for n in npcs:
		var p4 := _s(n["p"].x, n["p"].y)
		draw_circle(p4, 3.0, Color("ffd23a"))
		if n["mark"] != "":
			_lbl(p4 + Vector2(4, -3), n["mark"], Color("ffe45c"), 14)
	var pp := _s(px, pz)
	var d := Vector2(sin(pyaw), cos(pyaw))
	var sd := Vector2(-d.y, d.x)
	draw_colored_polygon(PackedVector2Array([pp + d * 9.0, pp - d * 6.0 + sd * 6.0, pp - d * 2.0, pp - d * 6.0 - sd * 6.0]), Color.WHITE)
	draw_polyline(PackedVector2Array([pp + d * 9.0, pp - d * 6.0 + sd * 6.0, pp - d * 2.0, pp - d * 6.0 - sd * 6.0, pp + d * 9.0]), Color.BLACK, 1.5)
	draw_rect(area, Color("c9a24a"), false, 2.0)
	_lbl(Vector2(area.position.x + SZ * 0.5 - 4, 54), "K", Color("ff8a7a"), 14)
