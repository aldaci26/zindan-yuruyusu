extends RefCounted
## WoW tarzı arayüz parçaları (hepsi kodla çizilir).

const Glyph = preload("res://glyph.gd")
const GOLD := Color("f2c75c")
const DARK := Color("120c06")

## Aksiyon çubuğu kutusu
class Slot extends Control:
	signal clicked(i: int)
	signal hovered(i: int, on: bool)
	var idx := 0
	var kind := "empty"
	var key_text := ""
	var frac := 0.0
	var cd_text := ""
	var locked := 0
	var norage := false
	var glow := false
	var count := ""

	func _init() -> void:
		custom_minimum_size = Vector2(46, 46)
		size = Vector2(46, 46)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(idx)

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_ENTER:
			hovered.emit(idx, true)
		elif what == NOTIFICATION_MOUSE_EXIT:
			hovered.emit(idx, false)

	func _pie(r: Rect2, f: float) -> void:
		if f >= 0.995:
			draw_rect(r, Color(0, 0, 0, 0.66))
			return
		var c := r.get_center()
		var pts := PackedVector2Array([c])
		var a0 := -PI / 2.0 + (1.0 - f) * TAU
		var n := 40
		for i in n + 1:
			var a := a0 + float(i) / n * f * TAU
			var d := Vector2(cos(a), sin(a))
			var tt := (r.size.x * 0.5) / maxf(absf(d.x), absf(d.y))
			pts.append(c + d * tt)
		draw_colored_polygon(pts, Color(0, 0, 0, 0.66))

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		if kind == "empty":
			draw_rect(r, Color(0.04, 0.035, 0.03, 0.75))
			draw_rect(r, Color(0.35, 0.3, 0.2, 0.8), false, 2.0)
			return
		var inner := r.grow(-2)
		Glyph.draw(self, kind, inner)
		if locked > 0:
			draw_rect(inner, Color(0, 0, 0, 0.72))
		elif norage:
			draw_rect(inner, Color(0.1, 0.15, 0.55, 0.5))
		if frac > 0.01 and locked == 0:
			_pie(inner, minf(frac, 1.0))
		var edge := Color("0e0a05")
		draw_rect(r, edge, false, 3.0)
		var rim := GOLD
		if glow:
			var p := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.012)
			rim = Color(1.0, 0.95, 0.4).lerp(Color(1, 0.55, 0.1), p)
			draw_rect(r.grow(1), rim, false, 3.0)
		else:
			draw_rect(r.grow(-1), Color(0.62, 0.5, 0.25, 0.95), false, 1.5)
		if locked > 0:
			Glyph.text(self, "Sv %d" % locked, Vector2(0, size.y * 0.58), size.x, 12, Color("ff8a7a"), 4)
		elif cd_text != "":
			Glyph.text(self, cd_text, Vector2(0, size.y * 0.64), size.x, 17, Color("ffe9a8"), 5)
		if key_text != "":
			var f := ThemeDB.fallback_font
			draw_string_outline(f, Vector2(4, 13), key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 4, Color(0, 0, 0, 0.95))
			draw_string(f, Vector2(4, 13), key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("f3f3f3"))
		if count != "":
			var f2 := ThemeDB.fallback_font
			draw_string_outline(f2, Vector2(0, size.y - 4), count, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 4, 13, 4, Color(0, 0, 0, 0.95))
			draw_string(f2, Vector2(0, size.y - 4), count, HORIZONTAL_ALIGNMENT_RIGHT, size.x - 4, 13, Color.WHITE)

	const Glyph = preload("res://glyph.gd")

## Buff simgesi (sağ üst)
class Buff extends Control:
	var kind := ""
	var t := 0.0
	const Glyph = preload("res://glyph.gd")

	func _init() -> void:
		custom_minimum_size = Vector2(34, 44)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var r := Rect2(0, 0, 34, 34)
		Glyph.draw(self, kind, r.grow(-1))
		draw_rect(r, Color("0e0a05"), false, 2.0)
		draw_rect(r.grow(-1), Color(0.35, 0.65, 0.3), false, 1.5)
		Glyph.text(self, "%d sn" % ceili(t), Vector2(0, 43), 34, 11, Color("f0f0f0"), 4)

## Yuvarlak portre (oyuncu ve hedef)
class Portrait extends Control:
	var kind := "dwarf"
	var lvl := 1
	var lvl_color := Color("ffe45c")
	const Glyph = preload("res://glyph.gd")

	func _init() -> void:
		custom_minimum_size = Vector2(68, 68)
		size = Vector2(68, 68)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _tri(a: Vector2, b: Vector2, c: Vector2, col: Color) -> void:
		draw_colored_polygon(PackedVector2Array([a, b, c]), col)

	func _draw() -> void:
		var c := size / 2.0
		var R := size.x / 2.0 - 3.0
		var bgc := Color("2a3e5a")
		match kind:
			"wolf": bgc = Color("2c3446")
			"boar": bgc = Color("4a3a2a")
			"bear": bgc = Color("3a3020")
			"skull": bgc = Color("3a1414")
			"npc": bgc = Color("3a4a2a")
		draw_circle(c, R, bgc)
		match kind:
			"dwarf", "npc":
				var beard := Color("c8661e") if kind == "dwarf" else Color("8a8a8a")
				draw_colored_polygon(PackedVector2Array([c + Vector2(-0.52, 0.0) * R, c + Vector2(0.52, 0.0) * R, c + Vector2(0.4, 0.8) * R, c + Vector2(0, 1.0) * R, c + Vector2(-0.4, 0.8) * R]), beard)
				draw_circle(c + Vector2(0, -0.12) * R, 0.4 * R, Color("eebb90"))
				draw_circle(c + Vector2(-0.16, -0.14) * R, 0.05 * R, Color("20140c"))
				draw_circle(c + Vector2(0.16, -0.14) * R, 0.05 * R, Color("20140c"))
				draw_circle(c + Vector2(0, 0.0) * R, 0.08 * R, Color("e0907a"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(-0.3, 0.14) * R, c + Vector2(0.3, 0.14) * R, c + Vector2(0.22, 0.3) * R, c + Vector2(-0.22, 0.3) * R]), beard)
				var hel := Color("aab4c8")
				var pts := PackedVector2Array()
				for i in 17:
					var a := PI + float(i) / 16.0 * PI
					pts.append(c + Vector2(0, -0.2) * R + Vector2(cos(a), sin(a)) * 0.5 * R)
				draw_colored_polygon(pts, hel)
				draw_rect(Rect2(c + Vector2(-0.5, -0.24) * R, Vector2(1.0, 0.09) * R), Color("e6b440"))
				_tri(c + Vector2(-0.5, -0.2) * R, c + Vector2(-0.7, -0.62) * R, c + Vector2(-0.34, -0.5) * R, Color("f4f0e0"))
				_tri(c + Vector2(0.5, -0.2) * R, c + Vector2(0.7, -0.62) * R, c + Vector2(0.34, -0.5) * R, Color("f4f0e0"))
			"wolf":
				_tri(c + Vector2(-0.5, -0.05) * R, c + Vector2(-0.45, -0.8) * R, c + Vector2(-0.1, -0.35) * R, Color("6a7488"))
				_tri(c + Vector2(0.5, -0.05) * R, c + Vector2(0.45, -0.8) * R, c + Vector2(0.1, -0.35) * R, Color("6a7488"))
				draw_circle(c + Vector2(0, -0.05) * R, 0.5 * R, Color("8a94a8"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(-0.22, 0.05) * R, c + Vector2(0.22, 0.05) * R, c + Vector2(0.14, 0.62) * R, c + Vector2(-0.14, 0.62) * R]), Color("c8ced8"))
				draw_circle(c + Vector2(-0.22, -0.12) * R, 0.07 * R, Color("ffd23a"))
				draw_circle(c + Vector2(0.22, -0.12) * R, 0.07 * R, Color("ffd23a"))
				draw_circle(c + Vector2(0, 0.58) * R, 0.07 * R, Color("101010"))
			"boar":
				_tri(c + Vector2(-0.55, -0.1) * R, c + Vector2(-0.5, -0.7) * R, c + Vector2(-0.15, -0.4) * R, Color("5a3a28"))
				_tri(c + Vector2(0.55, -0.1) * R, c + Vector2(0.5, -0.7) * R, c + Vector2(0.15, -0.4) * R, Color("5a3a28"))
				draw_circle(c + Vector2(0, -0.05) * R, 0.55 * R, Color("7a5238"))
				draw_circle(c + Vector2(0, 0.3) * R, 0.3 * R, Color("c89a82"))
				draw_circle(c + Vector2(-0.1, 0.3) * R, 0.05 * R, Color("3a2018"))
				draw_circle(c + Vector2(0.1, 0.3) * R, 0.05 * R, Color("3a2018"))
				_tri(c + Vector2(-0.3, 0.4) * R, c + Vector2(-0.5, 0.1) * R, c + Vector2(-0.2, 0.3) * R, Color("f4f0e0"))
				_tri(c + Vector2(0.3, 0.4) * R, c + Vector2(0.5, 0.1) * R, c + Vector2(0.2, 0.3) * R, Color("f4f0e0"))
				draw_circle(c + Vector2(-0.26, -0.15) * R, 0.06 * R, Color("101010"))
				draw_circle(c + Vector2(0.26, -0.15) * R, 0.06 * R, Color("101010"))
			"bear":
				draw_circle(c + Vector2(-0.45, -0.5) * R, 0.2 * R, Color("5a3c1e"))
				draw_circle(c + Vector2(0.45, -0.5) * R, 0.2 * R, Color("5a3c1e"))
				draw_circle(c + Vector2(0, -0.05) * R, 0.62 * R, Color("7a5230"))
				draw_circle(c + Vector2(0, 0.25) * R, 0.3 * R, Color("c8a070"))
				draw_circle(c + Vector2(0, 0.15) * R, 0.09 * R, Color("101010"))
				draw_circle(c + Vector2(-0.26, -0.2) * R, 0.06 * R, Color("101010"))
				draw_circle(c + Vector2(0.26, -0.2) * R, 0.06 * R, Color("101010"))
		if kind == "skull":
			draw_circle(c + Vector2(0, -0.1) * R, 0.55 * R, Color("e8e2d0"))
			draw_rect(Rect2(c + Vector2(-0.3, 0.2) * R, Vector2(0.6, 0.4) * R), Color("e8e2d0"))
			draw_circle(c + Vector2(-0.22, -0.1) * R, 0.15 * R, Color("1a0a0a"))
			draw_circle(c + Vector2(0.22, -0.1) * R, 0.15 * R, Color("1a0a0a"))
			draw_rect(Rect2(c + Vector2(-0.04, 0.12) * R, Vector2(0.08, 0.14) * R), Color("1a0a0a"))
		draw_arc(c, R, 0, TAU, 48, Color("0e0a05"), 5.0, true)
		draw_arc(c, R, 0, TAU, 48, Color("d8ae4a"), 2.5, true)
		# seviye rozeti
		var bp := c + Vector2(0, R - 1.0)
		draw_circle(bp, 11.0, Color("0e0a05"))
		draw_arc(bp, 11.0, 0, TAU, 24, Color("d8ae4a"), 2.0, true)
		Glyph.text(self, str(lvl), Vector2(bp.x - 20, bp.y + 4.5), 40, 12, lvl_color, 3)

## Yuvarlak mini harita
class Minimap extends Control:
	var px := 0.0
	var pz := 0.0
	var cam_yaw := 0.0
	var pyaw := 0.0
	var city := Vector3(0, -58, 24)
	var mobs: Array = []
	var npcs: Array = []
	var swamp := false
	const Glyph = preload("res://glyph.gd")
	const RANGE := 42.0

	func _init() -> void:
		custom_minimum_size = Vector2(150, 150)
		size = Vector2(150, 150)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _w2s(x: float, z: float) -> Vector2:
		var dx := x - px
		var dz := z - pz
		var fx := -sin(cam_yaw)
		var fz := -cos(cam_yaw)
		var rx := -fz
		var rz := fx
		var k := size.x * 0.5 / RANGE
		return size * 0.5 + Vector2((dx * rx + dz * rz) * k, -(dx * fx + dz * fz) * k)

	func _clamp(p: Vector2, lim: float) -> Vector2:
		var c := size * 0.5
		var d := p - c
		if d.length() > lim:
			return c + d.normalized() * lim
		return p

	func _disc(x: float, z: float, rad: float, col: Color) -> void:
		var pts := PackedVector2Array()
		for i in 40:
			var a := float(i) / 40.0 * TAU
			pts.append(_w2s(x + cos(a) * rad, z + sin(a) * rad))
		var circle := PackedVector2Array()
		var c := size * 0.5
		var R := size.x * 0.5 - 3.0
		for i in 64:
			var a2 := float(i) / 64.0 * TAU
			circle.append(c + Vector2(cos(a2), sin(a2)) * R)
		for poly in Geometry2D.intersect_polygons(pts, circle):
			if poly.size() >= 3 and not Geometry2D.triangulate_polygon(poly).is_empty():
				draw_colored_polygon(poly, col)

	func _draw() -> void:
		var c := size * 0.5
		var R := size.x * 0.5 - 3.0
		draw_circle(c, R, Color("7f9468") if swamp else Color("c7d6e6"))
		_disc(0.0, 0.0, 16.0, Color("9a8c5a") if swamp else Color("e4ecf4"))
		if not swamp:
			_disc(city.x, city.y, city.z, Color("b9a98c"))
			_disc(city.x, city.y, city.z - 3.0, Color("d6c6a4"))
			# yol
			var a := _clamp(_w2s(0.0, -6.0), R)
			var b := _clamp(_w2s(0.0, city.y + city.z), R)
			draw_line(a, b, Color("b09870"), 4.0, true)
		for m in mobs:
			var p := _w2s(m.x, m.y)
			if (p - c).length() < R - 3.0:
				draw_circle(p, 3.0, Color("e02a2a"))
				draw_arc(p, 3.0, 0, TAU, 8, Color(0, 0, 0, 0.8), 1.0)
		for n in npcs:
			var p2 := _w2s(n["p"].x, n["p"].y)
			if (p2 - c).length() < R - 3.0:
				draw_circle(p2, 3.0, Color("ffd23a"))
				draw_arc(p2, 3.0, 0, TAU, 8, Color(0, 0, 0, 0.8), 1.0)
				if n["mark"] != "":
					Glyph.text(self, n["mark"], p2 + Vector2(-8, -4), 16, 13, Color("ffe45c"), 4)
		# oyuncu oku
		var fx := -sin(cam_yaw)
		var fz := -cos(cam_yaw)
		var rx := -fz
		var rz := fx
		var hx := sin(pyaw)
		var hz := cos(pyaw)
		var dir := Vector2(hx * rx + hz * rz, -(hx * fx + hz * fz)).normalized()
		var side := Vector2(-dir.y, dir.x)
		draw_colored_polygon(PackedVector2Array([c + dir * 8.0, c - dir * 5.0 + side * 5.0, c - dir * 2.0, c - dir * 5.0 - side * 5.0]), Color("ffffff"))
		draw_polyline(PackedVector2Array([c + dir * 8.0, c - dir * 5.0 + side * 5.0, c - dir * 2.0, c - dir * 5.0 - side * 5.0, c + dir * 8.0]), Color(0, 0, 0, 0.9), 1.2)
		draw_arc(c, R, 0, TAU, 64, Color("0e0a05"), 6.0, true)
		draw_arc(c, R, 0, TAU, 64, Color("d8ae4a"), 3.0, true)
		# kuzey işareti
		var np := c + Vector2(sin(cam_yaw), -cos(cam_yaw)) * (R - 9.0) * Vector2(1, 1)
		Glyph.text(self, "K", np + Vector2(-8, 4), 16, 12, Color("ff8a7a"), 4)



## WoW tarzı taş-metal panel: koyu gradyan, çift pah, altın şerit, köşe perçinleri
class Frame extends Control:
	var rivets := true
	var trim := true

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		var top := Color("34302a")
		var bot := Color("14110d")
		draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, 0), r.end, Vector2(0, r.end.y)]), PackedColorArray([top, top, bot, bot]))
		draw_rect(r, Color("050403"), false, 2.0)
		draw_line(Vector2(2, 2), Vector2(r.end.x - 2, 2), Color(0.62, 0.55, 0.42, 0.55), 1.5)
		draw_line(Vector2(2, 2), Vector2(2, r.end.y - 2), Color(0.5, 0.44, 0.34, 0.4), 1.5)
		draw_line(Vector2(2, r.end.y - 2), Vector2(r.end.x - 2, r.end.y - 2), Color(0, 0, 0, 0.7), 1.5)
		draw_line(Vector2(r.end.x - 2, 2), Vector2(r.end.x - 2, r.end.y - 2), Color(0, 0, 0, 0.55), 1.5)
		if trim:
			draw_rect(r.grow(-4), Color(0.6, 0.47, 0.2, 0.9), false, 1.0)
		if rivets:
			for p in [Vector2(6, 6), Vector2(size.x - 6, 6), Vector2(6, size.y - 6), Vector2(size.x - 6, size.y - 6)]:
				draw_circle(p, 2.2, Color("c9a447"))
				draw_circle(p + Vector2(-0.6, -0.6), 0.9, Color("f6e3a0"))

## Aksiyon çubuğunun yanındaki kanatlı süs (grifon kanadı)
class Wing extends Control:
	var flip := false

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(70, 80)

	func _draw() -> void:
		var sgn := -1.0 if flip else 1.0
		var ox := 0.0 if not flip else size.x
		var gold := Color("c9a447")
		var dk := Color("5a4418")
		# gövde yuvası
		draw_circle(Vector2(ox + sgn * 12.0, 40), 15.0, Color("1a140c"))
		draw_arc(Vector2(ox + sgn * 12.0, 40), 15.0, 0, TAU, 28, gold, 2.5, true)
		draw_circle(Vector2(ox + sgn * 12.0, 40), 6.0, gold)
		# tüyler
		for i in 6:
			var t := float(i) / 5.0
			var y0 := 40.0 - 8.0 - t * 22.0
			var len := 26.0 + t * 26.0
			var ang := -0.15 - t * 0.55
			var tip := Vector2(ox + sgn * (12.0 + cos(ang) * len), y0 + sin(ang) * len * 0.5 - t * 6.0)
			var base1 := Vector2(ox + sgn * 14.0, y0 + 4.0)
			var base2 := Vector2(ox + sgn * 14.0, y0 - 5.0)
			var col := gold.lerp(dk, t * 0.35)
			draw_colored_polygon(PackedVector2Array([base1, tip, base2]), col)
			draw_line(base1, tip, Color(0.1, 0.07, 0.02, 0.8), 1.2)
		for i in 4:
			var t2 := float(i) / 3.0
			var y1 := 40.0 + 8.0 + t2 * 18.0
			var len2 := 24.0 + t2 * 18.0
			var tip2 := Vector2(ox + sgn * (12.0 + len2), y1 + len2 * 0.3)
			draw_colored_polygon(PackedVector2Array([Vector2(ox + sgn * 14.0, y1 - 4.0), tip2, Vector2(ox + sgn * 14.0, y1 + 5.0)]), gold.lerp(dk, t2 * 0.4))

## Küçük menü düğmesi (karakter, yardım, menü)
class MicroBtn extends Control:
	signal pressed
	var kind := "char"
	var hover := false

	func _init() -> void:
		custom_minimum_size = Vector2(24, 34)
		size = Vector2(24, 34)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			pressed.emit()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_ENTER:
			hover = true
			queue_redraw()
		elif what == NOTIFICATION_MOUSE_EXIT:
			hover = false
			queue_redraw()

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("1a140c") if not hover else Color("33281a"))
		draw_rect(r, Color("050403"), false, 2.0)
		draw_rect(r.grow(-2), Color("c9a447") if hover else Color("7a6030"), false, 1.0)
		var c := r.get_center()
		var g := Color("e8d49a") if hover else Color("c8b27a")
		match kind:
			"char":
				draw_circle(c + Vector2(0, -6), 4.5, g)
				draw_colored_polygon(PackedVector2Array([c + Vector2(-8, 10), c + Vector2(-6, 0), c + Vector2(6, 0), c + Vector2(8, 10)]), g)
			"help":
				draw_string(ThemeDB.fallback_font, c + Vector2(-5, 8), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, g)
			"menu":
				for i in 3:
					draw_rect(Rect2(c.x - 7, c.y - 8 + i * 6, 14, 3), g)

## Sırt çantası (B) ve boş çanta yuvaları
class BagBar extends Control:
	signal pressed
	var hover := false

	func _init() -> void:
		size = Vector2(150, 40)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _gui_input(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and ev.position.x < 42:
			pressed.emit()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_MOUSE_EXIT:
			hover = false
			queue_redraw()

	func _draw() -> void:
		# sırt çantası
		var r := Rect2(0, 0, 40, 40)
		draw_rect(r, Color("1a140c"))
		draw_rect(r, Color("050403"), false, 2.0)
		draw_rect(r.grow(-2), Color("7a6030"), false, 1.0)
		draw_rect(Rect2(10, 12, 20, 22), Color("8a5a2a"))
		draw_rect(Rect2(10, 12, 20, 22), Color("2a1808"), false, 1.5)
		draw_rect(Rect2(13, 22, 14, 9), Color("a8743a"))
		draw_rect(Rect2(13, 22, 14, 9), Color("2a1808"), false, 1.0)
		draw_arc(Vector2(20, 12), 6.0, PI, TAU, 10, Color("5a3a18"), 2.5, true)
		draw_rect(Rect2(18, 25, 4, 3), Color("e0b040"))
		var f := ThemeDB.fallback_font
		draw_string(f, Vector2(2, 38), "B", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1, 1, 1, 0.8))
		# boş çanta yuvaları
		for i in 4:
			var q := Rect2(46 + i * 26, 7, 24, 26)
			draw_rect(q, Color(0.05, 0.04, 0.03, 0.9))
			draw_rect(q, Color("050403"), false, 2.0)
			draw_rect(q.grow(-2), Color(0.35, 0.28, 0.14), false, 1.0)

## Tecrübe çubuğundaki bölme çizgileri (WoW'daki 20 parça)
class Ticks extends Control:
	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		for i in range(1, 20):
			var x := size.x * i / 20.0
			draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0, 0, 0, 0.55), 1.0)
