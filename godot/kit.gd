class_name Kit

## Kenney (CC0) modellerini yükler ve sahneye yerleştirir.
static var _cache := {}

static func spawn(parent: Node, kit: String, name: String, pos: Vector3, rot: float = 0.0, scl: float = 1.0, tint: Color = Color.WHITE, mat: Material = null, sv := Vector3.ONE) -> Node3D:
	var path := "res://assets/kenney/%s/%s.glb" % [kit, name]
	if not _cache.has(path):
		_cache[path] = load(path) if ResourceLoader.exists(path) else null
	var ps = _cache[path]
	if ps == null:
		return null
	var n: Node3D = ps.instantiate()
	n.position = pos
	n.rotation.y = rot
	n.scale = sv * scl
	parent.add_child(n)
	if mat != null or tint != Color.WHITE:
		for mi in n.find_children("*", "MeshInstance3D", true, false):
			if mat != null:
				(mi as MeshInstance3D).material_override = mat
			else:
				var m = (mi as MeshInstance3D).get_active_material(0)
				if m is StandardMaterial3D:
					var m2: StandardMaterial3D = m.duplicate()
					m2.albedo_color = m2.albedo_color * tint
					m2.roughness = 0.9
					(mi as MeshInstance3D).material_override = m2
	return n

## Modüler Kenney parçalarından ev kurar. Orijin: ev tabanının ortası, ön cephe +z.
static func house(parent: Node, tw: int, td: int, s: float, tint: Color = Color.WHITE, roof_mat: Material = null) -> Node3D:
	var g := Node3D.new()
	parent.add_child(g)
	var ox := -(tw - 1) * 0.5 * s
	var oz := -(td - 1) * 0.5 * s
	var door_i := tw / 2
	for ix in tw:
		for iz in td:
			var p := Vector3(ox + ix * s, 0, oz + iz * s)
			var sides := []
			if ix == tw - 1: sides.append(["wall-window-shutters" if iz % 2 == 0 else "wall", 0.0])
			if ix == 0: sides.append(["wall-window-shutters" if iz % 2 == 0 else "wall", PI])
			if iz == td - 1: sides.append(["wall-door" if ix == door_i else ("wall-window-shutters" if ix % 2 == 0 else "wall"), -PI / 2.0])
			if iz == 0: sides.append(["wall", PI / 2.0])
			for sd in sides:
				spawn(g, "fantasy-town", sd[0], p, sd[1], s, tint)
	spawn(g, "fantasy-town", "roof-gable", Vector3(0, s, 0), 0.0, s, tint, roof_mat, Vector3(tw, 1.0, td))
	return g
