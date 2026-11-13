extends RefCounted
## Yetenek simgeleri: dış resim yok, hepsi kodla çizilir.

const BG := {
	"strike": [Color("8a4a1c"), Color("34190a")],
	"charge": [Color("9a6a22"), Color("3a2408")],
	"rend": [Color("8c1c1c"), Color("2c0707")],
	"shout": [Color("a23a2a"), Color("3a110b")],
	"clap": [Color("2c4f9a"), Color("0d1a3a")],
	"shield": [Color("3a5a9a"), Color("101c3a")],
	"execute": [Color("4a1a5a"), Color("140820")],
	"mortal": [Color("6a1414"), Color("160505")],
	"whirl": [Color("2a7a8a"), Color("0a2a30")],
	"potion": [Color("3a2a2a"), Color("120c0c")],
}

static func pt(r: Rect2, x: float, y: float) -> Vector2:
	return r.position + Vector2(x * r.size.x, y * r.size.y)

static func poly(ci: CanvasItem, r: Rect2, pts: Array, col: Color) -> void:
	var v := PackedVector2Array()
	for p in pts:
		v.append(pt(r, p[0], p[1]))
	ci.draw_colored_polygon(v, col)

static func line(ci: CanvasItem, r: Rect2, a: Array, b: Array, col: Color, w: float) -> void:
	ci.draw_line(pt(r, a[0], a[1]), pt(r, b[0], b[1]), col, r.size.x * w, true)

static func circ(ci: CanvasItem, r: Rect2, x: float, y: float, rad: float, col: Color) -> void:
	ci.draw_circle(pt(r, x, y), r.size.x * rad, col)

static func arc(ci: CanvasItem, r: Rect2, x: float, y: float, rad: float, a0: float, a1: float, col: Color, w: float) -> void:
	ci.draw_arc(pt(r, x, y), r.size.x * rad, a0, a1, 24, col, r.size.x * w, true)

static func draw(ci: CanvasItem, kind: String, r: Rect2) -> void:
	var bg: Array = BG.get(kind, [Color(0.12, 0.12, 0.14), Color(0.05, 0.05, 0.07)])
	var v := PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0), r.end, r.position + Vector2(0, r.size.y)])
	ci.draw_polygon(v, PackedColorArray([bg[0], bg[0], bg[1], bg[1]]))
	var steel := Color("e4eaf4")
	var gold := Color("f2c75c")
	match kind:
		"strike":
			line(ci, r, [0.24, 0.76], [0.8, 0.2], steel, 0.13)
			line(ci, r, [0.22, 0.52], [0.48, 0.78], gold, 0.09)
			circ(ci, r, 0.2, 0.8, 0.06, gold)
			line(ci, r, [0.3, 0.7], [0.74, 0.26], Color(1, 1, 1, 0.7), 0.03)
		"rend":
			for k in 3:
				var o := 0.2 * k
				line(ci, r, [0.14 + o, 0.16], [0.4 + o, 0.86], Color("ff5a4a"), 0.08)
				line(ci, r, [0.14 + o, 0.16], [0.4 + o, 0.86], Color("ffb0a0"), 0.025)
			circ(ci, r, 0.3, 0.9, 0.04, Color("e02a2a"))
			circ(ci, r, 0.72, 0.84, 0.035, Color("e02a2a"))
		"charge":
			poly(ci, r, [[0.28, 0.4], [0.58, 0.4], [0.58, 0.24], [0.9, 0.5], [0.58, 0.76], [0.58, 0.6], [0.28, 0.6]], steel)
			line(ci, r, [0.08, 0.34], [0.26, 0.34], Color(1, 0.9, 0.6, 0.8), 0.05)
			line(ci, r, [0.04, 0.5], [0.22, 0.5], Color(1, 0.9, 0.6, 0.8), 0.05)
			line(ci, r, [0.08, 0.66], [0.26, 0.66], Color(1, 0.9, 0.6, 0.8), 0.05)
		"clap":
			arc(ci, r, 0.5, 0.5, 0.14, 0, TAU, Color("9fd0ff"), 0.05)
			arc(ci, r, 0.5, 0.5, 0.27, 0, TAU, Color("6aa8ff"), 0.05)
			arc(ci, r, 0.5, 0.5, 0.39, 0, TAU, Color("3a78e0"), 0.05)
			poly(ci, r, [[0.56, 0.24], [0.38, 0.54], [0.49, 0.54], [0.43, 0.78], [0.64, 0.45], [0.52, 0.45]], Color("ffe45c"))
		"shout":
			poly(ci, r, [[0.14, 0.42], [0.36, 0.42], [0.66, 0.24], [0.66, 0.76], [0.36, 0.58], [0.14, 0.58]], gold)
			poly(ci, r, [[0.2, 0.58], [0.34, 0.58], [0.3, 0.78], [0.2, 0.78]], Color("b8782e"))
			arc(ci, r, 0.66, 0.5, 0.14, -1.0, 1.0, Color("ffe9a8"), 0.045)
			arc(ci, r, 0.66, 0.5, 0.26, -0.9, 0.9, Color("ffe9a8"), 0.045)
		"shield":
			poly(ci, r, [[0.2, 0.16], [0.8, 0.16], [0.8, 0.5], [0.5, 0.86], [0.2, 0.5]], Color("c9d4e6"))
			poly(ci, r, [[0.26, 0.22], [0.74, 0.22], [0.74, 0.48], [0.5, 0.78], [0.26, 0.48]], Color("2a55b8"))
			circ(ci, r, 0.5, 0.42, 0.1, gold)
			line(ci, r, [0.5, 0.22], [0.5, 0.74], Color(0.95, 0.85, 0.5, 0.8), 0.03)
		"execute":
			circ(ci, r, 0.5, 0.4, 0.27, Color("eceae0"))
			poly(ci, r, [[0.36, 0.58], [0.64, 0.58], [0.62, 0.8], [0.38, 0.8]], Color("eceae0"))
			circ(ci, r, 0.4, 0.4, 0.07, Color("1a0a14"))
			circ(ci, r, 0.6, 0.4, 0.07, Color("1a0a14"))
			poly(ci, r, [[0.5, 0.48], [0.45, 0.58], [0.55, 0.58]], Color("1a0a14"))
			for k in 3:
				line(ci, r, [0.43 + 0.07 * k, 0.65], [0.43 + 0.07 * k, 0.8], Color("1a0a14"), 0.02)
			line(ci, r, [0.14, 0.9], [0.86, 0.12], Color("ff5a4a"), 0.045)
		"mortal":
			poly(ci, r, [[0.5, 0.06], [0.58, 0.2], [0.58, 0.6], [0.42, 0.6], [0.42, 0.2]], steel)
			line(ci, r, [0.5, 0.18], [0.46, 0.34], Color("e02a2a"), 0.035)
			line(ci, r, [0.46, 0.34], [0.54, 0.46], Color("e02a2a"), 0.035)
			line(ci, r, [0.54, 0.46], [0.5, 0.58], Color("e02a2a"), 0.035)
			poly(ci, r, [[0.28, 0.6], [0.72, 0.6], [0.72, 0.67], [0.28, 0.67]], gold)
			poly(ci, r, [[0.46, 0.67], [0.54, 0.67], [0.54, 0.86], [0.46, 0.86]], Color("7a4a1c"))
			circ(ci, r, 0.5, 0.9, 0.05, gold)
		"whirl":
			arc(ci, r, 0.5, 0.5, 0.34, 0.2, 4.6, steel, 0.08)
			arc(ci, r, 0.5, 0.5, 0.19, 3.4, 7.7, Color("bfe6ee"), 0.07)
			poly(ci, r, [[0.8, 0.46], [0.94, 0.62], [0.68, 0.62]], steel)
			poly(ci, r, [[0.4, 0.42], [0.54, 0.34], [0.52, 0.52]], Color("bfe6ee"))
		"potion":
			poly(ci, r, [[0.43, 0.22], [0.57, 0.22], [0.57, 0.42], [0.78, 0.8], [0.22, 0.8], [0.43, 0.42]], Color(0.8, 0.9, 1.0, 0.85))
			poly(ci, r, [[0.34, 0.6], [0.66, 0.6], [0.78, 0.8], [0.22, 0.8]], Color("e02a3a"))
			poly(ci, r, [[0.42, 0.14], [0.58, 0.14], [0.58, 0.23], [0.42, 0.23]], Color("8a5a2a"))
			circ(ci, r, 0.4, 0.68, 0.03, Color(1, 1, 1, 0.7))

static func text(ci: CanvasItem, s: String, pos: Vector2, w: float, size: int, col: Color, outline: int = 4) -> void:
	var f := ThemeDB.fallback_font
	ci.draw_string_outline(f, pos, s, HORIZONTAL_ALIGNMENT_CENTER, w, size, outline, Color(0, 0, 0, 0.95))
	ci.draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_CENTER, w, size, col)

## ---------- eşya simgeleri ----------
const SLOT_BG := Color("1a1814")

static func item(ci: CanvasItem, it: Dictionary, r: Rect2) -> void:
	var c: Color = it["col"]
	var bgt := c.darkened(0.7)
	bgt.a = 1.0
	var v := PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0), r.end, r.position + Vector2(0, r.size.y)])
	ci.draw_polygon(v, PackedColorArray([bgt.lightened(0.12), bgt.lightened(0.12), bgt.darkened(0.3), bgt.darkened(0.3)]))
	var d := c.darkened(0.35)
	var l := c.lightened(0.3)
	var slot: String = it.get("slot", "")
	var look: int = it.get("look", 0)
	if slot == "":
		var ic: String = it.get("icon", "potion")
		if ic == "potion":
			var big: bool = it["id"] == "pot_big"
			var s0 := 1.0 if big else 0.85
			poly(ci, r, [[0.5 - 0.07, 0.2], [0.57, 0.2], [0.57, 0.42], [0.5 + 0.28 * s0, 0.8], [0.5 - 0.28 * s0, 0.8], [0.43, 0.42]], Color(0.8, 0.9, 1.0, 0.85))
			poly(ci, r, [[0.34, 0.6], [0.66, 0.6], [0.5 + 0.28 * s0, 0.8], [0.5 - 0.28 * s0, 0.8]], Color("e02a3a") if not big else Color("ff3a4a"))
			poly(ci, r, [[0.42, 0.13], [0.58, 0.13], [0.58, 0.21], [0.42, 0.21]], Color("8a5a2a"))
			circ(ci, r, 0.4, 0.68, 0.03, Color(1, 1, 1, 0.7))
		elif ic == "pelt":
			circ(ci, r, 0.5, 0.52, 0.3, c)
			circ(ci, r, 0.3, 0.36, 0.12, c)
			circ(ci, r, 0.7, 0.36, 0.12, c)
			circ(ci, r, 0.32, 0.72, 0.1, c)
			circ(ci, r, 0.68, 0.72, 0.1, c)
			line(ci, r, [0.38, 0.44], [0.46, 0.66], d, 0.03)
			line(ci, r, [0.56, 0.4], [0.62, 0.64], d, 0.03)
		else:
			for k in 3:
				arc(ci, r, 0.3 + 0.2 * k, 0.9, 0.5, 4.3, 5.4, c, 0.08)
				poly(ci, r, [[0.24 + 0.2 * k, 0.5], [0.3 + 0.2 * k, 0.9], [0.4 + 0.2 * k, 0.5]], c)
		return
	match slot:
		"head":
			var dome := [[0.18, 0.62]]
			for i in 11:
				var a := PI + float(i) / 10.0 * PI
				dome.append([0.5 + cos(a) * 0.32, 0.62 + sin(a) * 0.42])
			dome.append([0.82, 0.62])
			poly(ci, r, dome, c)
			poly(ci, r, [[0.16, 0.62], [0.84, 0.62], [0.84, 0.72], [0.16, 0.72]], d)
			poly(ci, r, [[0.46, 0.62], [0.54, 0.62], [0.54, 0.86], [0.46, 0.86]], d)
			line(ci, r, [0.3, 0.4], [0.5, 0.26], l, 0.04)
			if look == 1:
				poly(ci, r, [[0.18, 0.5], [0.04, 0.2], [0.26, 0.38]], Color("eadfc8"))
				poly(ci, r, [[0.82, 0.5], [0.96, 0.2], [0.74, 0.38]], Color("eadfc8"))
			elif look == 2:
				poly(ci, r, [[0.5, 0.3], [0.62, 0.08], [0.72, 0.3]], Color("d03a3a"))
		"neck":
			arc(ci, r, 0.5, 0.3, 0.32, 0.25, PI - 0.25, c, 0.05)
			circ(ci, r, 0.5, 0.7, 0.13, c)
			circ(ci, r, 0.5, 0.7, 0.07, l)
		"shoulder":
			var sp := [[0.14, 0.7]]
			for i in 9:
				var a2 := PI + float(i) / 8.0 * PI
				sp.append([0.5 + cos(a2) * 0.36, 0.7 + sin(a2) * 0.5])
			sp.append([0.86, 0.7])
			poly(ci, r, sp, c)
			poly(ci, r, [[0.14, 0.7], [0.86, 0.7], [0.8, 0.82], [0.2, 0.82]], d)
			circ(ci, r, 0.38, 0.48, 0.05, l)
			circ(ci, r, 0.62, 0.48, 0.05, l)
		"back":
			poly(ci, r, [[0.34, 0.14], [0.66, 0.14], [0.84, 0.86], [0.16, 0.86]], c)
			line(ci, r, [0.42, 0.2], [0.34, 0.84], d, 0.03)
			line(ci, r, [0.58, 0.2], [0.66, 0.84], d, 0.03)
			poly(ci, r, [[0.3, 0.12], [0.7, 0.12], [0.7, 0.2], [0.3, 0.2]], l)
		"chest":
			poly(ci, r, [[0.14, 0.2], [0.36, 0.14], [0.64, 0.14], [0.86, 0.2], [0.78, 0.4], [0.72, 0.86], [0.28, 0.86], [0.22, 0.4]], c)
			line(ci, r, [0.5, 0.18], [0.5, 0.84], d, 0.04)
			line(ci, r, [0.3, 0.5], [0.7, 0.5], d, 0.03)
			poly(ci, r, [[0.14, 0.2], [0.3, 0.16], [0.28, 0.3], [0.16, 0.34]], l)
			poly(ci, r, [[0.86, 0.2], [0.7, 0.16], [0.72, 0.3], [0.84, 0.34]], l)
		"wrist":
			poly(ci, r, [[0.2, 0.26], [0.8, 0.26], [0.74, 0.46], [0.26, 0.46]], c)
			poly(ci, r, [[0.2, 0.56], [0.8, 0.56], [0.74, 0.76], [0.26, 0.76]], c)
			line(ci, r, [0.22, 0.28], [0.78, 0.28], l, 0.03)
			line(ci, r, [0.22, 0.58], [0.78, 0.58], l, 0.03)
		"hands":
			poly(ci, r, [[0.26, 0.5], [0.74, 0.5], [0.7, 0.84], [0.3, 0.84]], c)
			for k in 4:
				poly(ci, r, [[0.26 + k * 0.12, 0.5], [0.34 + k * 0.12, 0.5], [0.34 + k * 0.12, 0.16 + (0.0 if (k == 1 or k == 2) else 0.08)], [0.26 + k * 0.12, 0.16 + (0.0 if (k == 1 or k == 2) else 0.08)]], c)
			poly(ci, r, [[0.7, 0.58], [0.88, 0.46], [0.9, 0.56], [0.72, 0.7]], c)
			poly(ci, r, [[0.28, 0.74], [0.72, 0.74], [0.72, 0.84], [0.28, 0.84]], d)
		"waist":
			poly(ci, r, [[0.08, 0.4], [0.92, 0.4], [0.92, 0.62], [0.08, 0.62]], c)
			poly(ci, r, [[0.38, 0.34], [0.62, 0.34], [0.62, 0.68], [0.38, 0.68]], Color("e6b440"))
			poly(ci, r, [[0.44, 0.42], [0.56, 0.42], [0.56, 0.6], [0.44, 0.6]], d)
		"legs":
			poly(ci, r, [[0.24, 0.14], [0.49, 0.14], [0.49, 0.9], [0.36, 0.9], [0.22, 0.4]], c)
			poly(ci, r, [[0.51, 0.14], [0.76, 0.14], [0.78, 0.4], [0.64, 0.9], [0.51, 0.9]], c)
			poly(ci, r, [[0.24, 0.14], [0.76, 0.14], [0.76, 0.26], [0.24, 0.26]], d)
		"feet":
			poly(ci, r, [[0.28, 0.16], [0.58, 0.16], [0.58, 0.58], [0.88, 0.7], [0.88, 0.86], [0.28, 0.86]], c)
			poly(ci, r, [[0.28, 0.16], [0.58, 0.16], [0.58, 0.28], [0.28, 0.28]], l)
			poly(ci, r, [[0.28, 0.78], [0.88, 0.78], [0.88, 0.86], [0.28, 0.86]], d)
		"ring":
			arc(ci, r, 0.5, 0.58, 0.24, 0.0, TAU, c, 0.1)
			circ(ci, r, 0.5, 0.3, 0.1, Color("ff4a4a") if it["id"] == "rg_ruby" else Color("7fe8ff"))
			circ(ci, r, 0.47, 0.27, 0.03, Color(1, 1, 1, 0.8))
		"trinket":
			circ(ci, r, 0.5, 0.5, 0.32, c)
			circ(ci, r, 0.5, 0.5, 0.22, d)
			circ(ci, r, 0.5, 0.5, 0.1, l)
			poly(ci, r, [[0.5, 0.1], [0.56, 0.2], [0.44, 0.2]], Color("e6b440"))
		"mainhand":
			var hd := Color("6a4325")
			if look == 3:
				poly(ci, r, [[0.46, 0.12], [0.54, 0.12], [0.58, 0.62], [0.42, 0.62]], c.lightened(0.25))
				poly(ci, r, [[0.46, 0.12], [0.5, 0.06], [0.54, 0.12]], c.lightened(0.4))
				poly(ci, r, [[0.28, 0.62], [0.72, 0.62], [0.72, 0.7], [0.28, 0.7]], Color("e6b440"))
				poly(ci, r, [[0.46, 0.7], [0.54, 0.7], [0.54, 0.88], [0.46, 0.88]], hd)
			elif look == 2:
				line(ci, r, [0.5, 0.12], [0.5, 0.92], hd, 0.07)
				poly(ci, r, [[0.26, 0.14], [0.74, 0.14], [0.74, 0.42], [0.26, 0.42]], c)
				poly(ci, r, [[0.26, 0.14], [0.74, 0.14], [0.74, 0.2], [0.26, 0.2]], l)
			else:
				line(ci, r, [0.28, 0.9], [0.66, 0.2], hd, 0.07)
				poly(ci, r, [[0.6, 0.12], [0.88, 0.2], [0.9, 0.46], [0.62, 0.42], [0.58, 0.3]], c)
				poly(ci, r, [[0.6, 0.12], [0.88, 0.2], [0.84, 0.26], [0.6, 0.2]], l)
				if look == 1:
					poly(ci, r, [[0.52, 0.2], [0.28, 0.1], [0.2, 0.34], [0.5, 0.36], [0.56, 0.3]], c)
		"offhand":
			poly(ci, r, [[0.16, 0.14], [0.84, 0.14], [0.84, 0.5], [0.5, 0.9], [0.16, 0.5]], d)
			poly(ci, r, [[0.22, 0.2], [0.78, 0.2], [0.78, 0.48], [0.5, 0.82], [0.22, 0.48]], c)
			circ(ci, r, 0.5, 0.42, 0.1, Color("e6b440"))
			line(ci, r, [0.5, 0.2], [0.5, 0.8], d, 0.025)

## Boş yuva silueti (yuva adı)
static func slot_ghost(ci: CanvasItem, slot: String, r: Rect2) -> void:
	var it := {"col": Color(0.42, 0.4, 0.36), "slot": slot, "look": 0, "id": ""}
	var rr := r.grow(-r.size.x * 0.12)
	item(ci, it, rr)
	ci.draw_rect(r, Color(0.05, 0.05, 0.05, 0.6))

