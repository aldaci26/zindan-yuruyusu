extends RefCounted
## Dünyayı canlandıran süsler: çiftlik tarlası, süzülen kuşlar, sığ sudaki kuşlar.
## Host (main.gd) `_wow_spawn`, `height_at` ve `_add_obs` sağlar; model yoksa sessizce atlanır.

const CROPS := ["Carrot_4.glb", "Corn_4.glb", "Beet_4.glb", "Lettuce_4.glb", "Pumpkin_4.glb", "Wheat_4.glb"]

## Sıralı mahsul tarlası: her sıra tek tür, sıralar arası boşluk bırakır.
static func farm_plot(host: Node3D, origin: Vector2, rows: int, cols: int, spacing: float = 1.5, crop_scale: float = 2.2) -> int:
	var placed := 0
	for r in rows:
		var model: String = CROPS[r % CROPS.size()]
		for c in cols:
			var x := origin.x + c * spacing
			var z := origin.y + r * spacing * 1.4
			var node: Node3D = host.call("_wow_spawn", "crops_pack/" + model, Vector3(x, host.call("height_at", x, z), z), float(r * 7 + c) * 0.9, crop_scale)
			if node != null:
				placed += 1
	if placed > 0:
		host.call("_add_obs", origin.x + cols * spacing * 0.5, origin.y + rows * spacing * 0.7, maxf(cols * spacing, rows * spacing * 1.4) * 0.45)
	return placed

## Merkez çevresinde daire çizen kuşlar. Her kuş kendi eksen düğümünde döner; düğüm silinince animasyon da biter.
static func circling_birds(host: Node3D, model_path: String, center: Vector3, radius: float, count: int, scale_value: float = 1.6) -> int:
	var made := 0
	for i in count:
		var r := radius * (0.75 + 0.25 * float(i % 3))
		var pivot := Node3D.new()
		pivot.position = center + Vector3(0, float(i % 3) * 2.5, 0)
		pivot.rotation.y = TAU * float(i) / float(maxi(1, count))
		host.add_child(pivot)
		var bird := _bird(model_path, "walk")
		if bird == null:
			pivot.queue_free()
			continue
		bird.position = Vector3(r, 0, 0)
		bird.rotation.y = PI
		bird.scale = Vector3.ONE * scale_value
		pivot.add_child(bird)
		var tw := pivot.create_tween().set_loops()
		tw.tween_property(pivot, "rotation:y", pivot.rotation.y - TAU, 26.0 + float(i) * 3.0)
		made += 1
	return made

## Sığ suda yürüyen/duran kuşlar: yükseklik aralığı uygun rastgele noktalara yerleşir.
static func shallows_birds(host: Node3D, model_path: String, count: int, seed_value: int, min_y: float, max_y: float, ring_min: float, ring_max: float) -> int:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = seed_value
	var made := 0
	var tries := 0
	while made < count and tries < 400:
		tries += 1
		var ang := rnd.randf() * TAU
		var dist := rnd.randf_range(ring_min, ring_max)
		var x := cos(ang) * dist
		var z := sin(ang) * dist
		var y: float = host.call("height_at", x, z)
		if y < min_y or y > max_y:
			continue
		var bird := _bird(model_path, "idle")
		if bird == null:
			return made
		bird.position = Vector3(x, y, z)
		bird.rotation.y = rnd.randf() * TAU
		bird.scale = Vector3.ONE * 1.5
		host.add_child(bird)
		made += 1
	return made

static func _bird(model_path: String, clip: String) -> Node3D:
	if not ResourceLoader.exists(model_path):
		return null
	var packed := load(model_path) as PackedScene
	if packed == null:
		return null
	var node := packed.instantiate() as Node3D
	if node == null:
		return null
	var players := node.find_children("*", "AnimationPlayer", true, false)
	if not players.is_empty():
		var ap := players[0] as AnimationPlayer
		if ap.has_animation(clip):
			ap.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
			ap.play(clip)
	return node
