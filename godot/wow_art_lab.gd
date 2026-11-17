extends Node3D
## İzole WotLK görsel prototipi. Ana oyun sahnesini veya kayıt sistemini değiştirmez.

const Dwarf = preload("res://dwarf.gd")

const SNOW := Color("#b9cbd8")
const STONE := Color("#59616b")
const DARK_STONE := Color("#303b48")
const GOLD := Color("#c59b4a")
const CLOTH := Color("#263f68")

func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_ruins()
	_build_forest()
	_build_banners()
	_build_characters()
	_build_camera()
	_build_overlay()

func _material(color: Color, metallic: float = 0.0, roughness: float = 0.82, glow: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if glow > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = glow
	return material

func _mesh(parent: Node3D, shape: Mesh, material: Material, at: Vector3, scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = shape
	instance.material_override = material
	instance.position = at
	instance.scale = scale
	parent.add_child(instance)
	return instance

func _box(parent: Node3D, size: Vector3, material: Material, at: Vector3) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return _mesh(parent, shape, material, at)

func _cylinder(parent: Node3D, top: float, bottom: float, height: float, material: Material, at: Vector3, sides: int = 12) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = top
	shape.bottom_radius = bottom
	shape.height = height
	shape.radial_segments = sides
	return _mesh(parent, shape, material, at)

func _sphere(parent: Node3D, material: Material, at: Vector3, scale: Vector3) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radial_segments = 16
	shape.rings = 8
	return _mesh(parent, shape, material, at, scale)

func _cone(parent: Node3D, radius: float, height: float, material: Material, at: Vector3) -> MeshInstance3D:
	return _cylinder(parent, 0.0, radius, height, material, at, 8)

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#7895aa")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#9db7ca")
	environment.ambient_light_energy = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("#a9c2d1")
	environment.fog_density = 0.006
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_color = Color("#ffe4c2")
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 65.0
	add_child(sun)

func _build_ground() -> void:
	var ground := PlaneMesh.new()
	ground.size = Vector2(54.0, 54.0)
	ground.subdivide_width = 32
	ground.subdivide_depth = 32
	_mesh(self, ground, _material(Color("#c7d5dc"), 0.0, 0.96), Vector3.ZERO)

	var snow_shadow := _material(Color("#9eb5c4"), 0.0, 1.0)
	_sphere(self, snow_shadow, Vector3(-8.0, 0.025, -5.0), Vector3(5.0, 0.025, 2.0))
	_sphere(self, snow_shadow, Vector3(10.0, 0.03, 5.0), Vector3(4.0, 0.03, 2.0))
	_sphere(self, snow_shadow, Vector3(-13.0, 0.025, 8.0), Vector3(3.0, 0.025, 1.5))

func _build_ruins() -> void:
	var stone := _material(STONE, 0.18, 0.88)
	var dark := _material(DARK_STONE, 0.12, 0.92)
	var snow := _material(SNOW, 0.0, 1.0)
	var rune := _material(Color("#71d9ee"), 0.15, 0.35, 1.4)

	# Kırık kale kapısı: iri, okunaklı WotLK silüeti.
	for side in [-1.0, 1.0]:
		var x := side * 7.0
		_box(self, Vector3(2.0, 6.0, 2.0), stone, Vector3(x, 3.0, -7.0))
		_box(self, Vector3(2.2, 0.35, 2.2), snow, Vector3(x, 6.12, -7.0))
		_box(self, Vector3(2.15, 0.5, 2.15), dark, Vector3(x, 0.35, -7.0))
		for level in 3:
			_box(self, Vector3(2.08, 0.12, 2.08), dark, Vector3(x, 1.4 + level * 1.45, -7.0))
		_box(self, Vector3(0.18, 1.7, 0.12), rune, Vector3(x, 3.7, -5.96))
		_box(self, Vector3(0.9, 0.14, 0.12), rune, Vector3(x, 3.7, -5.96))
	_box(self, Vector3(16.0, 1.0, 2.4), dark, Vector3(0.0, 6.35, -7.0))
	_box(self, Vector3(16.0, 0.28, 2.6), snow, Vector3(0.0, 6.98, -7.0))

	for i in 4:
		_box(self, Vector3(12.0 - i * 1.2, 0.22, 1.2), stone, Vector3(0.0, 0.12 + i * 0.04, -3.8 + i * 1.15))

	var rubble := _material(Color("#46515e"), 0.05, 0.96)
	_sphere(self, rubble, Vector3(-11.0, 0.55, -4.0), Vector3(1.8, 1.1, 1.2))
	_sphere(self, rubble, Vector3(11.0, 0.4, -2.0), Vector3(1.3, 0.8, 1.0))
	_sphere(self, rubble, Vector3(-9.0, 0.35, 1.5), Vector3(1.2, 0.7, 0.9))
	_sphere(self, rubble, Vector3(9.5, 0.45, 2.0), Vector3(1.5, 0.9, 1.0))

func _tree(at: Vector3, size: float = 1.0) -> void:
	var trunk := _material(Color("#493a32"), 0.0, 0.98)
	var needles := _material(Color("#254b4c"), 0.0, 0.95)
	var snow := _material(Color("#d5e2e8"), 0.0, 1.0)
	_cylinder(self, 0.22 * size, 0.34 * size, 2.4 * size, trunk, at + Vector3(0.0, 1.2 * size, 0.0), 8)
	for tier in 3:
		var y := (2.0 + tier * 0.9) * size
		var radius := (1.45 - tier * 0.32) * size
		_cone(self, radius, 2.2 * size, needles, at + Vector3(0.0, y, 0.0))
		_cone(self, radius * 0.76, 0.55 * size, snow, at + Vector3(0.0, y + 0.82 * size, 0.0))

func _build_forest() -> void:
	_tree(Vector3(-17.0, 0.0, -13.0), 1.2)
	_tree(Vector3(-20.0, 0.0, -3.0), 0.95)
	_tree(Vector3(-17.0, 0.0, 9.0), 1.1)
	_tree(Vector3(17.0, 0.0, -14.0), 1.25)
	_tree(Vector3(20.0, 0.0, -2.0), 1.0)
	_tree(Vector3(17.0, 0.0, 11.0), 1.15)
	_tree(Vector3(-11.0, 0.0, 18.0), 0.85)
	_tree(Vector3(12.0, 0.0, 19.0), 0.9)

func _build_banners() -> void:
	var pole := _material(Color("#697785"), 0.65, 0.38)
	var cloth := _material(CLOTH, 0.0, 0.92)
	var gold := _material(GOLD, 0.72, 0.32)
	for x in [-4.8, 4.8]:
		_cylinder(self, 0.07, 0.09, 5.2, pole, Vector3(x, 2.6, -1.4), 10)
		_box(self, Vector3(1.5, 2.1, 0.12), cloth, Vector3(x, 3.7, -1.4))
		_box(self, Vector3(1.1, 0.12, 0.15), gold, Vector3(x, 4.45, -1.31))
		_box(self, Vector3(0.12, 1.2, 0.16), gold, Vector3(x, 3.65, -1.3))
		_box(self, Vector3(0.72, 0.12, 0.16), gold, Vector3(x, 3.65, -1.3))
		_cone(self, 0.12, 0.35, gold, Vector3(x, 5.35, -1.4))

func _build_characters() -> void:
	var player := Dwarf.make_dwarf({
		"skin": Color("#d9a27e"),
		"metal": Color("#8798a8"),
		"cloth": Color("#294b79"),
		"beard": Color("#a84b2b"),
		"helm": true,
		"prop": "axe",
	})
	player.position = Vector3(-2.7, 0.0, 4.0)
	player.rotation.y = -0.22
	player.scale = Vector3(1.35, 1.35, 1.35)
	add_child(player)

	var wolf := Dwarf.make_wolf()
	wolf.position = Vector3(3.4, 0.0, 5.3)
	wolf.rotation.y = 0.25
	wolf.scale = Vector3(1.2, 1.2, 1.2)
	add_child(wolf)

func _build_camera() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(13.5, 10.0, 17.5)
	camera.fov = 48.0
	camera.current = true
	add_child(camera)
	camera.look_at(Vector3(0.0, 2.2, 0.0), Vector3.UP)

func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "NORTHREND  /  VISUAL PROTOTYPE"
	title.position = Vector2(28.0, 24.0)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#e7edf1"))
	title.add_theme_color_override("font_outline_color", Color("#17232d"))
	title.add_theme_constant_override("outline_size", 6)
	layer.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "WotLK yönü • karakter + yaratık + buzlu kale kapısı • izole test sahnesi"
	subtitle.position = Vector2(30.0, 55.0)
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color("#d4e1e9"))
	subtitle.add_theme_constant_override("outline_size", 4)
	layer.add_child(subtitle)
