extends RefCounted
## Kodla çizilen modeller: cüce, kurt, yaban domuzu, ayı. Dış dosya yok.

static func mat(c: Color, metal: float = 0.05, rough: float = 0.8, emit_c: Color = Color.BLACK, emit_e: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
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

static func make_bear() -> Node3D:
	var g := Node3D.new()
	var fur = mat(Color.html("5a3b24"), 0.0, 0.95)
	var dk = mat(Color.html("3a2415"), 0.0, 0.95)
	var lt = mat(Color.html("9a6d46"), 0.0, 0.95)
	box(g, Vector3(1.1, 1.0, 1.6), fur, Vector3(0, 1.1, 0))
	box(g, Vector3(0.95, 0.5, 0.7), fur, Vector3(0, 1.7, 0.4))
	box(g, Vector3(0.75, 0.65, 0.7), fur, Vector3(0, 1.35, 1.15))
	box(g, Vector3(0.4, 0.3, 0.4), lt, Vector3(0, 1.2, 1.55))
	box(g, Vector3(0.14, 0.1, 0.08), dk, Vector3(0, 1.3, 1.76))
	for s in [-1.0, 1.0]:
		sph(g, 0.15, dk, Vector3(s * 0.3, 1.72, 1.0))
	g.set_meta("legs", _legs(g, [[-0.4, 0.6, 0.65], [0.4, 0.6, 0.65], [-0.4, -0.6, 0.65], [0.4, -0.6, 0.65]], Vector3(0.3, 0.65, 0.32), dk))
	return g
