extends RefCounted
## Kodla çizilen modeller: cüce, kurt, yaban domuzu, ayı. Dış dosya yok.

const TexScript = preload("res://tex.gd")
static var _grain: ImageTexture

static func mat(c: Color, metal: float = 0.05, rough: float = 0.8, emit_c: Color = Color.BLACK, emit_e: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	if emit_e <= 0.0:
		# el boyaması hissi: ince lekeli doku, nesne uzayında üç yönlü
		if _grain == null:
			_grain = TexScript.grain()
		m.albedo_texture = _grain
		m.uv1_triplanar = true
		m.uv1_scale = Vector3(1.4, 1.4, 1.4)
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	m.metallic = metal
	m.roughness = rough
	if emit_e > 0.0:
		m.emission_enabled = true
		m.emission = emit_c
		m.emission_energy_multiplier = emit_e
	return m

static func _add(parent: Node, mesh: Mesh, m: Material, pos: Vector3 = Vector3.ZERO, shadow: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	mi.position = pos
	if not shadow:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

static func box(parent: Node, size: Vector3, m: Material, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	return _add(parent, b, m, pos)

static func sph(parent: Node, r: float, m: Material, pos: Vector3 = Vector3.ZERO, sc: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 14
	s.rings = 8
	var n := _add(parent, s, m, pos)
	n.scale = sc
	return n

static func cyl(parent: Node, rt: float, rb: float, h: float, m: Material, pos: Vector3 = Vector3.ZERO, seg: int = 12) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.top_radius = rt
	c.bottom_radius = rb
	c.height = h
	c.radial_segments = seg
	c.rings = 1
	return _add(parent, c, m, pos)

static func cone(parent: Node, r: float, h: float, m: Material, pos: Vector3 = Vector3.ZERO, seg: int = 8) -> MeshInstance3D:
	return cyl(parent, 0.0, r, h, m, pos, seg)

static func torus(parent: Node, ring_r: float, tube: float, m: Material, pos: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var t := TorusMesh.new()
	t.inner_radius = ring_r - tube
	t.outer_radius = ring_r + tube
	t.rings = 20
	t.ring_segments = 8
	return _add(parent, t, m, pos)

static func pivot(parent: Node, pos: Vector3) -> Node3D:
	var p := Node3D.new()
	p.position = pos
	parent.add_child(p)
	return p

## Cüce savaşçı. o: skin, metal, cloth, beard (Color), helm (bool), prop ("axe", "hammer", "spear", "none")
static func make_dwarf(o: Dictionary = {}) -> Node3D:
	var g := Node3D.new()
	var rig := {}
	var skin = mat(o.get("skin", Color.html("e3a985")), 0.0, 0.8)
	var steel = mat(o.get("metal", Color.html("8196b0")), 0.6, 0.4)
	var blue = mat(o.get("cloth", Color.html("2a4fa3")), 0.0, 0.85)
	var gold = mat(Color.html("e0b040"), 0.8, 0.28)
	var leather = mat(Color.html("6a4325"), 0.0, 0.9)
	var beard = mat(o.get("beard", Color.html("c4561f")), 0.0, 0.9)
	var dark = mat(Color.html("16181c"), 0.0, 0.6)
	# bacaklar
	rig["legL"] = pivot(g, Vector3(-0.24, 0.62, 0))
	rig["legR"] = pivot(g, Vector3(0.24, 0.62, 0))
	for l in [rig["legL"], rig["legR"]]:
		box(l, Vector3(0.34, 0.4, 0.38), blue, Vector3(0, -0.2, 0))
		box(l, Vector3(0.4, 0.34, 0.52), leather, Vector3(0, -0.46, 0.05))
		box(l, Vector3(0.44, 0.08, 0.44), gold, Vector3(0, -0.3, 0))
	# gövde
	box(g, Vector3(0.95, 0.72, 0.62), steel, Vector3(0, 0.98, 0))
	box(g, Vector3(1.0, 0.14, 0.66), leather, Vector3(0, 0.66, 0))
	box(g, Vector3(0.2, 0.16, 0.06), gold, Vector3(0, 0.66, 0.34))
	box(g, Vector3(0.5, 0.62, 0.05), blue, Vector3(0, 0.96, 0.33))
	box(g, Vector3(0.1, 0.62, 0.06), gold, Vector3(0, 0.96, 0.34))
	box(g, Vector3(0.9, 0.2, 0.58), blue, Vector3(0, 0.55, 0))
	# omuzluklar
	for s in [-1.0, 1.0]:
		sph(g, 0.34, steel, Vector3(s * 0.62, 1.3, 0), Vector3(1, 0.8, 1))
		torus(g, 0.3, 0.05, gold, Vector3(s * 0.62, 1.22, 0))
		var sp := cone(g, 0.1, 0.32, gold, Vector3(s * 0.72, 1.56, 0), 5)
		sp.rotation.z = -s * 0.4
	# kafa
	var head := pivot(g, Vector3(0, 1.62, 0))
	rig["head"] = head
	sph(head, 0.29, skin)
	sph(head, 0.1, mat(Color.html("d8906c")), Vector3(0, -0.02, 0.29))
	for s in [-1.0, 1.0]:
		var eye := sph(head, 0.035, dark, Vector3(s * 0.11, 0.06, 0.26))
		eye.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var brow := box(head, Vector3(0.15, 0.04, 0.06), beard, Vector3(s * 0.11, 0.12, 0.26))
		brow.rotation.z = -s * 0.25
		var must := cone(head, 0.07, 0.34, beard, Vector3(s * 0.14, -0.1, 0.27), 5)
		must.rotation.z = s * 1.3
	var helm_nodes: Array = []
	var hm := SphereMesh.new()
	hm.radius = 0.34
	hm.height = 0.34
	hm.is_hemisphere = true
	hm.radial_segments = 14
	hm.rings = 6
	helm_nodes.append(_add(head, hm, steel, Vector3(0, 0.02, 0)))
	helm_nodes.append(torus(head, 0.33, 0.04, gold, Vector3(0, 0.08, 0)))
	helm_nodes.append(box(head, Vector3(0.07, 0.2, 0.05), steel, Vector3(0, 0.08, 0.31)))
	for s in [-1.0, 1.0]:
		var horn := cone(head, 0.08, 0.5, mat(Color.html("eadfc8"), 0.0, 0.7), Vector3(s * 0.34, 0.24, 0), 6)
		horn.rotation.z = -s * 0.9
		helm_nodes.append(horn)
	# sakal ve örgüler
	var bd := cone(head, 0.3, 0.78, beard, Vector3(0, -0.42, 0.14), 8)
	bd.rotation.x = PI
	bd.scale = Vector3(1, 1, 0.8)
	for s in [-1.0, 1.0]:
		var br := cone(head, 0.06, 0.55, beard, Vector3(s * 0.14, -0.62, 0.28), 5)
		br.rotation.x = PI
		sph(head, 0.05, gold, Vector3(s * 0.14, -0.84, 0.28))
	# kollar
	rig["armR"] = pivot(g, Vector3(0.62, 1.28, 0))
	rig["armL"] = pivot(g, Vector3(-0.62, 1.28, 0))
	for a in [rig["armR"], rig["armL"]]:
		box(a, Vector3(0.26, 0.6, 0.28), steel, Vector3(0, -0.3, 0))
		box(a, Vector3(0.3, 0.24, 0.3), leather, Vector3(0, -0.68, 0))
		box(a, Vector3(0.31, 0.1, 0.33), gold, Vector3(0, -0.5, 0))
	# balta
	var axe := pivot(rig["armR"], Vector3(0, -0.68, 0.05))
	cyl(axe, 0.05, 0.06, 1.5, leather, Vector3(0, 0.35, 0), 6)
	box(axe, Vector3(0.06, 0.55, 0.5), steel, Vector3(0, 0.95, 0.3))
	box(axe, Vector3(0.06, 0.5, 0.45), steel, Vector3(0, 0.95, -0.3))
	cone(axe, 0.07, 0.25, gold, Vector3(0, 1.18, 0), 5)
	axe.rotation.x = PI / 2.2
	rig["axe"] = axe
	# kalkan
	var sh := pivot(rig["armL"], Vector3(-0.22, -0.55, 0.12))
	var disk := cyl(sh, 0.5, 0.5, 0.1, blue, Vector3.ZERO, 20)
	disk.rotation.z = PI / 2
	var rim := torus(sh, 0.5, 0.05, gold)
	rim.rotation.z = PI / 2
	sph(sh, 0.15, gold, Vector3(-0.08, 0, 0))
	rig["shield"] = sh
	rig["armL"].rotation.x = -0.3
	# seçenekler
	if o.get("helm", true) == false:
		for n in helm_nodes:
			n.visible = false
	var prop: String = o.get("prop", "axe")
	if prop != "axe":
		axe.visible = false
		sh.visible = false
		var pr := pivot(rig["armR"], Vector3(0, -0.68, 0.05))
		if prop == "hammer":
			cyl(pr, 0.05, 0.06, 1.0, leather, Vector3(0, 0.3, 0), 6)
			box(pr, Vector3(0.3, 0.3, 0.5), mat(Color.html("55606c"), 0.6, 0.4), Vector3(0, 0.85, 0))
			pr.rotation.x = PI / 2.2
		elif prop == "spear":
			cyl(pr, 0.035, 0.045, 2.6, leather, Vector3(0, 0.6, 0), 6)
			cone(pr, 0.1, 0.4, steel, Vector3(0, 2.0, 0), 5)
			pr.rotation.x = 0.05
		rig["prop"] = pr
	g.scale = Vector3(1.12, 1.0, 1.05)
	g.set_meta("rig", rig)
	return g

static func _legs(g: Node3D, defs: Array, leg_size: Vector3, m: Material) -> Array:
	var legs: Array = []
	for d in defs:
		var l := pivot(g, Vector3(d[0], d[2], d[1]))
		box(l, leg_size, m, Vector3(0, -leg_size.y * 0.5, 0))
		legs.append(l)
	return legs

static func make_wolf() -> Node3D:
	var g := Node3D.new()
	var fur = mat(Color.html("7d838c"), 0.0, 0.95)
	var dk = mat(Color.html("4b5058"), 0.0, 0.95)
	var lt = mat(Color.html("cfd5db"), 0.0, 0.95)
	var eye = mat(Color.html("ffd23a"), 0.0, 0.5, Color.html("ffa000"), 1.5)
	box(g, Vector3(0.55, 0.55, 1.2), fur, Vector3(0, 0.75, 0))
	box(g, Vector3(0.62, 0.6, 0.5), lt, Vector3(0, 0.8, 0.45))
	box(g, Vector3(0.42, 0.4, 0.45), fur, Vector3(0, 0.95, 0.85))
	box(g, Vector3(0.22, 0.2, 0.32), dk, Vector3(0, 0.88, 1.16))
	for s in [-1.0, 1.0]:
		cone(g, 0.09, 0.22, dk, Vector3(s * 0.14, 1.22, 0.78), 4)
		sph(g, 0.04, eye, Vector3(s * 0.12, 1.0, 1.06))
	var tail := cone(g, 0.14, 0.7, dk, Vector3(0, 0.85, -0.85), 5)
	tail.rotation.x = -2.2
	g.set_meta("legs", _legs(g, [[-0.2, 0.45, 0.5], [0.2, 0.45, 0.5], [-0.2, -0.45, 0.5], [0.2, -0.45, 0.5]], Vector3(0.15, 0.5, 0.17), dk))
	return g

static func make_boar() -> Node3D:
	var g := Node3D.new()
	var fur = mat(Color.html("6b4a33"), 0.0, 0.95)
	var dk = mat(Color.html("3b281b"), 0.0, 0.95)
	var tusk = mat(Color.html("f0e6cf"), 0.0, 0.6)
	box(g, Vector3(0.8, 0.75, 1.3), fur, Vector3(0, 0.8, 0))
	box(g, Vector3(0.7, 0.4, 0.6), dk, Vector3(0, 1.25, 0.25))
	box(g, Vector3(0.6, 0.55, 0.55), fur, Vector3(0, 0.8, 0.95))
	box(g, Vector3(0.35, 0.28, 0.3), mat(Color.html("b98a7a"), 0.0, 0.9), Vector3(0, 0.7, 1.32))
	for s in [-1.0, 1.0]:
		var t := cone(g, 0.05, 0.38, tusk, Vector3(s * 0.2, 0.62, 1.34), 5)
		t.rotation.x = -0.9
		t.rotation.z = s * 0.3
		cone(g, 0.1, 0.22, dk, Vector3(s * 0.2, 1.12, 0.85), 4)
	g.set_meta("legs", _legs(g, [[-0.28, 0.5, 0.45], [0.28, 0.5, 0.45], [-0.28, -0.5, 0.45], [0.28, -0.5, 0.45]], Vector3(0.2, 0.45, 0.2), dk))
	return g

static func make_bear(o: Dictionary = {}) -> Node3D:
	var g := Node3D.new()
	var fur = mat(o.get("fur", Color.html("5a3b24")), 0.0, 0.95)
	var dk = mat(o.get("dk", Color.html("3a2415")), 0.0, 0.95)
	var lt = mat(o.get("lt", Color.html("9a6d46")), 0.0, 0.95)
	box(g, Vector3(1.1, 1.0, 1.6), fur, Vector3(0, 1.1, 0))
	box(g, Vector3(0.95, 0.5, 0.7), fur, Vector3(0, 1.7, 0.4))
	box(g, Vector3(0.75, 0.65, 0.7), fur, Vector3(0, 1.35, 1.15))
	box(g, Vector3(0.4, 0.3, 0.4), lt, Vector3(0, 1.2, 1.55))
	box(g, Vector3(0.14, 0.1, 0.08), dk, Vector3(0, 1.3, 1.76))
	for s in [-1.0, 1.0]:
		sph(g, 0.15, dk, Vector3(s * 0.3, 1.72, 1.0))
	g.set_meta("legs", _legs(g, [[-0.4, 0.6, 0.65], [0.4, 0.6, 0.65], [-0.4, -0.6, 0.65], [0.4, -0.6, 0.65]], Vector3(0.3, 0.65, 0.32), dk))
	return g

# ---------- boss ve yeni düşman modelleri ----------
static func _biped_legs(g: Node3D, x: float, y: float, size: Vector3, m: Material) -> Array:
	var l := pivot(g, Vector3(-x, y, 0))
	var r := pivot(g, Vector3(x, y, 0))
	box(l, size, m, Vector3(0, -size.y * 0.5, 0))
	box(r, size, m, Vector3(0, -size.y * 0.5, 0))
	return [l, r, r, l]

static func _fake_legs(g: Node3D) -> Array:
	var p := pivot(g, Vector3.ZERO)
	return [p, p, p, p]

## Trogg: kambur, gri-mavi derili, sopalı. ice: buz kristalleri (Grik'nir)
static func make_trogg(ice: bool = false) -> Node3D:
	var g := Node3D.new()
	var skin = mat(Color.html("7f8a96") if ice else Color.html("8a7f6a"), 0.0, 0.9)
	var dk = mat(Color.html("4a525c") if ice else Color.html("5a5040"), 0.0, 0.9)
	var wood = mat(Color.html("5a3b24"), 0.0, 0.9)
	var eye = mat(Color.html("ffe060"), 0.0, 0.5, Color.html("ffc020"), 1.5)
	var crys = mat(Color.html("9fe4ff"), 0.0, 0.3, Color.html("60c8ff"), 1.6)
	box(g, Vector3(0.9, 0.9, 0.6), skin, Vector3(0, 1.15, 0))
	box(g, Vector3(0.8, 0.5, 0.55), skin, Vector3(0, 1.7, 0.18))
	box(g, Vector3(0.55, 0.45, 0.5), skin, Vector3(0, 1.85, 0.5))
	box(g, Vector3(0.4, 0.14, 0.12), dk, Vector3(0, 1.72, 0.76))
	for sd in [-1.0, 1.0]:
		sph(g, 0.05, eye, Vector3(sd * 0.14, 1.98, 0.76))
		box(g, Vector3(0.28, 0.9, 0.3), skin, Vector3(sd * 0.6, 1.1, 0.1))
		if ice:
			cone(g, 0.1, 0.5, crys, Vector3(sd * 0.5, 1.9, -0.1), 5)
	var bone := mat(Color.html("e8dcc0"), 0.0, 0.8)
	var fur := mat(Color.html("6a5a44"), 0.0, 0.95)
	box(g, Vector3(1.0, 0.34, 0.66), fur, Vector3(0, 0.78, 0))
	box(g, Vector3(0.9, 0.12, 0.64), dk, Vector3(0, 0.96, 0))
	for sd in [-1.0, 1.0]:
		cone(g, 0.06, 0.28, bone, Vector3(sd * 0.17, 1.62, 0.78), 5).rotation.x = -0.6
		sph(g, 0.14, fur, Vector3(sd * 0.55, 1.62, 0.0))
	for k in 5:
		cone(g, 0.12, 0.34, fur, Vector3(0, 1.9 - k * 0.0, -0.1 - k * 0.1), 4).rotation.x = -0.9 - k * 0.05
	var arm := pivot(g, Vector3(0.62, 1.5, 0.1))
	cyl(arm, 0.06, 0.1, 1.3, wood, Vector3(0, -0.4, 0.4), 6).rotation.x = 1.2
	sph(arm, 0.2, dk, Vector3(0, -0.6, 0.95))
	for k in 3:
		cone(arm, 0.04, 0.2, bone, Vector3(0.12 - k * 0.12, -0.6, 1.12), 4).rotation.x = 1.2
	g.set_meta("legs", _biped_legs(g, 0.25, 0.8, Vector3(0.3, 0.8, 0.34), dk))
	return g

static func make_ogre() -> Node3D:
	var g := Node3D.new()
	var skin = mat(Color.html("a07a58"), 0.0, 0.9)
	var dk = mat(Color.html("5a3a24"), 0.0, 0.9)
	var cloth = mat(Color.html("6a3a2a"), 0.0, 0.95)
	var eye = mat(Color.html("ffcf40"), 0.0, 0.5, Color.html("ff9000"), 1.2)
	var wood = mat(Color.html("4a3020"), 0.0, 0.9)
	var iron = mat(Color.html("55606c"), 0.6, 0.4)
	box(g, Vector3(1.5, 1.5, 0.95), skin, Vector3(0, 1.7, 0))
	box(g, Vector3(1.55, 0.5, 1.0), cloth, Vector3(0, 1.05, 0))
	box(g, Vector3(0.7, 0.65, 0.65), skin, Vector3(0, 2.75, 0.1))
	box(g, Vector3(0.5, 0.16, 0.12), dk, Vector3(0, 2.62, 0.45))
	var tusk := mat(Color.html("efe6cc"), 0.0, 0.7)
	box(g, Vector3(1.6, 0.16, 1.04), dk, Vector3(0, 1.3, 0))
	box(g, Vector3(0.24, 0.24, 0.06), mat(Color.html("d0a840"), 0.7, 0.3), Vector3(0, 1.3, 0.54))
	for k in 5:
		box(g, Vector3(0.12, 0.12, 0.08), tusk, Vector3(-0.2 + k * 0.1, 2.5, 0.43))
	for sd in [-1.0, 1.0]:
		cone(g, 0.07, 0.4, tusk, Vector3(sd * 0.2, 2.65, 0.45), 5).rotation.x = -0.5
		cone(g, 0.12, 0.5, iron, Vector3(sd * 0.95, 2.78, 0), 5)
		sph(g, 0.06, eye, Vector3(sd * 0.18, 2.88, 0.43))
		sph(g, 0.34, skin, Vector3(sd * 0.95, 2.35, 0), Vector3(1, 0.9, 1))
		box(g, Vector3(0.38, 1.3, 0.42), skin, Vector3(sd * 1.05, 1.6, 0.1))
	var arm := pivot(g, Vector3(1.05, 2.1, 0.1))
	cyl(arm, 0.1, 0.18, 1.8, wood, Vector3(0, -0.2, 0.7), 6).rotation.x = 1.1
	box(arm, Vector3(0.5, 0.5, 0.5), iron, Vector3(0, -0.8, 1.45))
	g.set_meta("legs", _biped_legs(g, 0.42, 1.0, Vector3(0.5, 1.0, 0.5), dk))
	return g

## Gnoll: kamburlu, tüylü. big: Hogger
static func make_gnoll(big: bool = false) -> Node3D:
	var g := Node3D.new()
	var fur = mat(Color.html("9a6a3a") if big else Color.html("8a7050"), 0.0, 0.95)
	var dk = mat(Color.html("4a3220"), 0.0, 0.95)
	var lt = mat(Color.html("c8a878"), 0.0, 0.95)
	var eye = mat(Color.html("ff5030"), 0.0, 0.5, Color.html("ff2000"), 1.5)
	var cloth = mat(Color.html("7a2a2a") if not big else Color.html("3a5a8a"), 0.0, 0.95)
	var iron = mat(Color.html("8a919c"), 0.6, 0.4)
	box(g, Vector3(0.7, 0.8, 0.5), fur, Vector3(0, 1.1, 0))
	box(g, Vector3(0.72, 0.3, 0.52), cloth, Vector3(0, 0.75, 0))
	box(g, Vector3(0.55, 0.45, 0.5), fur, Vector3(0, 1.65, 0.25))
	box(g, Vector3(0.28, 0.24, 0.4), lt, Vector3(0, 1.55, 0.65))
	box(g, Vector3(0.1, 0.08, 0.08), dk, Vector3(0, 1.58, 0.86))
	var tooth := mat(Color.html("f0e8d4"), 0.0, 0.7)
	for k in 4:
		box(g, Vector3(0.03, 0.07, 0.03), tooth, Vector3(-0.09 + k * 0.06, 1.44, 0.8))
	for k in 5:
		cone(g, 0.08, 0.35, dk, Vector3(0, 1.95 - k * 0.12, 0.0 - k * 0.07), 4).rotation.x = -0.4 - k * 0.15
	box(g, Vector3(0.74, 0.08, 0.54), iron, Vector3(0, 0.95, 0))
	for sd in [-1.0, 1.0]:
		sph(g, 0.04, eye, Vector3(sd * 0.14, 1.78, 0.5))
		cone(g, 0.1, 0.3, dk, Vector3(sd * 0.2, 2.0, 0.15), 4)
		box(g, Vector3(0.2, 0.75, 0.22), fur, Vector3(sd * 0.48, 1.05, 0.1))
	var arm := pivot(g, Vector3(0.5, 1.4, 0.1))
	box(arm, Vector3(0.1, 0.9, 0.18), iron, Vector3(0, -0.5, 0.55)).rotation.x = 1.1
	g.set_meta("legs", _biped_legs(g, 0.2, 0.75, Vector3(0.24, 0.75, 0.28), dk))
	return g

## Alev Oğlu: ateşli küçük yaratık
static func make_ember() -> Node3D:
	var g := Node3D.new()
	var core = mat(Color.html("ffb030"), 0.0, 0.5, Color.html("ff7010"), 3.0)
	var shell = mat(Color.html("3a1a10"), 0.0, 0.9)
	sph(g, 0.5, core, Vector3(0, 1.0, 0), Vector3(1, 1.2, 1))
	cone(g, 0.3, 0.8, core, Vector3(0, 1.9, 0), 6)
	for sd in [-1.0, 1.0]:
		box(g, Vector3(0.25, 0.7, 0.25), shell, Vector3(sd * 0.5, 0.9, 0))
	var light := OmniLight3D.new()
	light.light_color = Color("ff8030")
	light.omni_range = 5.0
	light.light_energy = 1.2
	light.position = Vector3(0, 1.0, 0)
	g.add_child(light)
	g.set_meta("legs", _biped_legs(g, 0.2, 0.6, Vector3(0.28, 0.6, 0.28), shell))
	return g

## Ragnaros: lavdan yükselen dev gövde, çekiç
static func make_ragnaros() -> Node3D:
	var g := Node3D.new()
	var rock = mat(Color.html("2a1a14"), 0.0, 0.9)
	var fire = mat(Color.html("ff7a1f"), 0.0, 0.5, Color.html("ff5a00"), 3.2)
	var hot = mat(Color.html("ffd060"), 0.0, 0.4, Color.html("ffb020"), 4.0)
	cyl(g, 2.6, 3.0, 3.0, rock, Vector3(0, 1.0, 0), 16)
	cyl(g, 2.2, 2.6, 1.0, fire, Vector3(0, 2.4, 0), 16)
	box(g, Vector3(3.8, 3.0, 2.2), rock, Vector3(0, 4.4, 0))
	box(g, Vector3(2.2, 2.2, 0.2), fire, Vector3(0, 4.4, 1.1))
	sph(g, 1.2, rock, Vector3(0, 6.4, 0.2), Vector3(1, 1.0, 1))
	for sd in [-1.0, 1.0]:
		sph(g, 0.22, hot, Vector3(sd * 0.45, 6.5, 1.15))
		sph(g, 1.0, rock, Vector3(sd * 2.4, 5.6, 0), Vector3(1, 0.8, 1))
		box(g, Vector3(0.9, 3.4, 0.9), rock, Vector3(sd * 2.7, 3.8, 0.3))
		cone(g, 0.3, 1.4, fire, Vector3(sd * 0.7, 7.5, 0), 5)
	cone(g, 0.5, 2.0, hot, Vector3(0, 7.7, 0), 5)
	var arm := pivot(g, Vector3(2.7, 5.4, 0.3))
	cyl(arm, 0.18, 0.2, 4.0, rock, Vector3(0, 0.6, 1.0), 6).rotation.x = 0.5
	box(arm, Vector3(1.6, 1.4, 1.6), fire, Vector3(0, 2.4, 2.0))
	var light := OmniLight3D.new()
	light.light_color = Color("ff7a30")
	light.omni_range = 26.0
	light.light_energy = 3.5
	light.position = Vector3(0, 5.0, 2.0)
	g.add_child(light)
	g.set_meta("legs", _fake_legs(g))
	return g
