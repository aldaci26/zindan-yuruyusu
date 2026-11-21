extends RefCounted

const Items = preload("res://items.gd")
## Runtime loader for independently licensed WotLK-style glTF assets.
## Missing assets always fall back to the existing procedural models.

const CREATURE_SCENES := {
	"wolf": ["res://assets/wotlk_local/creatures/wolf.glb", "res://assets/wotlk/creatures/wolf.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Wolf.glb"],
	"bear": [],
	"bog": ["res://assets/third_party/gobkit/animal/Hippo.glb"],
	"golem": ["res://assets/third_party/gobkit/minion/minion-d01.glb"],
	"slag": ["res://assets/third_party/gobkit/minion/minion-b01.glb"],
	"cinder": ["res://assets/third_party/gobkit/minion/minion-c01.glb"],
	"gorduk": ["res://assets/third_party/gobkit/human010/BloodironJuggernaut.glb"],
	"vurgan": ["res://assets/third_party/gobkit/human006/OrcWarbandChampion.glb"],
	"golemagg": ["res://assets/third_party/gobkit/minion/minion-a01.glb"],
	"geddon": ["res://assets/third_party/gobkit/human010/OrcPyromancer.glb"],
	"sulfuron": ["res://assets/third_party/gobkit/minion/minion-d01.glb"],
	"ragnaros": ["res://assets/third_party/gobkit/human011/StitchedBrute.glb"],
	"boar": ["res://assets/wotlk_local/creatures/boar.glb", "res://assets/third_party/gobkit/animal012/WildBoar.glb", "res://assets/third_party/gobkit/animalB/Boar.glb"],
	"gobkit_wild_boar": ["res://assets/third_party/gobkit/animal012/WildBoar.glb"],
	"rat": ["res://assets/wotlk_local/creatures/rat.glb", "res://assets/third_party/gobkit/animalB/Rat.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Rat.glb"],
	"deer": ["res://assets/wotlk_local/creatures/deer.glb", "res://assets/third_party/gobkit/animal006/Doe.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Deer.glb"],
	"stag": ["res://assets/wotlk_local/creatures/stag.glb", "res://assets/third_party/gobkit/animal011/SkullDeer.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Stag.glb"],
	"spider": ["res://assets/wotlk_local/creatures/spider.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Spider.glb"],
	"frog": ["res://assets/wotlk_local/creatures/frog.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Frog.glb"],
	"snake": ["res://assets/wotlk_local/creatures/snake.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Snake.glb"],
	"fox": ["res://assets/wotlk_local/creatures/fox.glb", "res://assets/third_party/gobkit/animal006/Fox.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Fox.glb"],
	"gnoll": ["res://assets/wotlk_local/creatures/gnoll.glb", "res://assets/third_party/gobkit/human011/WerewolfCaptain.glb"],
	"trogg": ["res://assets/wotlk_local/creatures/trogg.glb", "res://assets/third_party/gobkit/human010/OrcChainBrute.glb"],
	"ashogre": ["res://assets/wotlk_local/creatures/ashogre.glb", "res://assets/third_party/gobkit/human011/StitchedBrute.glb"],
	"darkiron": ["res://assets/wotlk_local/creatures/darkiron.glb", "res://assets/third_party/gobkit/human010/BloodironKnight.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Knight.glb"],
	"miner": ["res://assets/wotlk_local/creatures/miner.glb", "res://assets/third_party/gobkit/human010/BloodironSmith.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Barbarian.glb"],
	"guard": ["res://assets/wotlk_local/creatures/guard.glb", "res://assets/third_party/gobkit/human003/Footman.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Knight.glb"],
	"ironclad": ["res://assets/third_party/gobkit/human010/BloodironHalberdier.glb"],
	"kezan": ["res://assets/third_party/gobkit/human010/BloodironShieldwall.glb"],
	"modrek": ["res://assets/third_party/gobkit/human016/Berserker.glb"],
	# Murloc shaman remains procedural: an orc shaman is not a suitable species match.
	"shaman": [],
	"defias": ["res://assets/wotlk_local/creatures/defias.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Rogue_Hooded.glb"],
	"skeleton": ["res://assets/wotlk_local/creatures/skeleton.glb", "res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Warrior.glb"],
	"ashbone": ["res://assets/wotlk_local/creatures/ashbone.glb", "res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Minion.glb"],
	"frost_wolf": ["res://assets/wotlk/third_party/quaternius/animals_pack/Wolf.glb"],
	# No matching CC0 Murloc or crocodile model is present in the imported packs.
	"murloc": [],
	"croc": [],
	"gobkit_minion_a": ["res://assets/third_party/gobkit/minion/minion-a01.glb"],
	"gobkit_minion_c": ["res://assets/third_party/gobkit/minion/minion-c01.glb"],
	"gobkit_minion_b": ["res://assets/third_party/gobkit/minion/minion-b01.glb"],
	"gobkit_minion_d": ["res://assets/third_party/gobkit/minion/minion-d01.glb"],
	"gobkit_bat": ["res://assets/third_party/gobkit/animal/Bat.glb"],
	"gobkit_hippo": ["res://assets/third_party/gobkit/animal/Hippo.glb"],
	"gobkit_shark": ["res://assets/third_party/gobkit/animal/Shark.glb"],
}
const EQUIPMENT_ASSET_MAP := {
	"axe_old": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Small.glb",
	"axe_iron": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe.glb",
	"axe_wolf": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe.glb",
	"axe_boar": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"axe_forge": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe.glb",
	"axe_deepf": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Axe_Double_Golden.glb",
	"axe_storm": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Axe_Double.glb",
	"axe_king": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Axe_Double_Golden.glb",
	"axe_grik": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"axe_gruff": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"axe_mine": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe.glb",
	"axe_vurgan": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"axe_ash": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"axe_sulf": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Axe_Double_Golden.glb",
	"axe_craft1": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe.glb",
	"axe_craft2": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"sword_gate": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Sword.glb",
	"sword_cruel": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Claymore.glb",
	"hammer_smith": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Hammer_Small.glb",
	"hammer_chok": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Hammer_Double.glb",
	"hammer_sulf": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Hammer_Double_Golden.glb",
	"hammer_gorduk": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Hammer_Double.glb",
	"hammer_ash": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Hammer_Double.glb",
	"hammer_golemagg": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Hammer_Double_Golden.glb",
	"sh_wood": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Round.glb",
	"sh_iron": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Heater.glb",
	"sh_gate": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Heater_2.glb",
	"sh_rein": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Round_2.glb",
	"sh_deep": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Celtic_Golden.glb",
	"sh_king": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Celtic_Golden.glb",
	"sh_marsh": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Round_2.glb",
	"sh_mine": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Heater.glb",
	"sh_ash": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Heater_2.glb",
	"sh_sulf": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Celtic_Golden.glb",
	"sh_craft": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Heater_2.glb",
	"helm_ward": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"ch_craft2": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"helm_cap": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet1.glb",
	"helm_iron": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet2.glb",
	"helm_horn": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"helm_king": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"so_pad": "res://assets/wotlk/third_party/quaternius/single_knight_pack/ShoulderPads.glb",
	"so_iron": "res://assets/wotlk/third_party/quaternius/single_knight_pack/ShoulderPads.glb",
	"so_boar": "res://assets/wotlk/third_party/quaternius/single_knight_pack/ShoulderPads.glb",
	"so_peak": "res://assets/wotlk/third_party/quaternius/single_knight_pack/ShoulderPads.glb",
	"axe_marsh": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb",
	"ch_plate": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_deep": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_rag": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_marsh": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_mine": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_vurgan": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_ash": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_geddon": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"ch_craft1": "res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb",
	"helm_bear": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet2.glb",
	"helm_marsh": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"helm_defias": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet2.glb",
	"helm_rag": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"helm_mine": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet2.glb",
	"helm_vurgan": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"helm_ash": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"helm_geddon": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"sh_thokk": "res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Celtic_Golden.glb",
}
const ANIMATION_ALIASES := {
	"idle": ["idle", "stand", "breathing"],
	"walk": ["walk", "run", "move"],
	"attack": ["attack", "bite", "melee", "spell"],
	"death": ["death", "dead", "die"],
}
static var _gobkit_segments_loaded := false
static var _gobkit_segments: Dictionary = {}

static func spawn_creature(kind: String, fallback: Callable) -> Node3D:
	var paths: Array = CREATURE_SCENES.get(kind, [])
	for path_value in paths:
		var path := str(path_value)
		if not ResourceLoader.exists(path):
			continue
		var packed := load(path) as PackedScene
		if packed == null:
			continue
		var instance := packed.instantiate()
		if instance is Node3D:
			var node := instance as Node3D
			node.set_meta("wow_asset_source", path)
			_sanitize_imported_scene(node)
			_configure_gobkit_animation_segments(node, path)
			return node
		instance.queue_free()
	return fallback.call() as Node3D

static func update_locomotion(root: Node3D, moving: bool, attacking: bool = false) -> void:
	if root == null or not is_instance_valid(root):
		return
	_sanitize_imported_scene(root)
	for candidate in root.find_children("*", "AnimationPlayer", true, false):
		var player := candidate as AnimationPlayer
		if player == null:
			continue
		var previous_state := str(player.get_meta("wow_animation_state", ""))
		if previous_state == "death" and player.is_playing():
			continue
		if previous_state == "attack" and player.is_playing():
			var current_name := str(player.current_animation)
			if not current_name.is_empty():
				var current_clip := player.get_animation(current_name)
				if current_clip != null and current_clip.loop_mode == Animation.LOOP_NONE:
					continue
		var state := "attack" if attacking else ("walk" if moving else "idle")
		var clip := _find_clip(player, state)
		if clip.is_empty() and state == "attack":
			state = "idle"
			clip = _find_clip(player, "idle")
		if not clip.is_empty() and (str(player.current_animation) != clip or not player.is_playing()):
			player.play(clip)
			player.set_meta("wow_animation_state", state)

static func play_death(root: Node3D) -> bool:
	if root == null or not is_instance_valid(root):
		return false
	var played := false
	for candidate in root.find_children("*", "AnimationPlayer", true, false):
		var player := candidate as AnimationPlayer
		if player == null:
			continue
		var clip := _find_clip(player, "death")
		if not clip.is_empty():
			player.play(clip)
			player.set_meta("wow_animation_state", "death")
			played = true
	return played

static func _sanitize_imported_scene(root: Node3D) -> void:
	if root.has_meta("wow_meshes_sanitized"):
		return
	root.set_meta("wow_meshes_sanitized", true)
	var empty_meshes: Array[String] = []
	for candidate in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := candidate as MeshInstance3D
		if mesh_instance != null and mesh_instance.mesh == null:
			empty_meshes.append(str(mesh_instance.get_path()))
			var parent := mesh_instance.get_parent()
			if parent != null:
				parent.remove_child(mesh_instance)
			mesh_instance.free()
			continue
		# Some imported rigs store vertex positions in joint-local space, so the
		# mesh resource's own (unskinned) AABB is a few centimetres across even
		# though the skinned result is character-sized. Godot's frustum culling
		# uses that tiny bind-pose AABB, so the creature pops out of view the
		# moment the camera is more than a step away. A generous cull margin on
		# any suspiciously small mesh keeps it from ever being culled like that.
		if mesh_instance != null and mesh_instance.mesh != null:
			var local_aabb := mesh_instance.mesh.get_aabb()
			if maxf(local_aabb.size.x, maxf(local_aabb.size.y, local_aabb.size.z)) < 0.6:
				mesh_instance.extra_cull_margin = 10.0
	for candidate in root.find_children("*", "MultiMeshInstance3D", true, false):
		var multimesh_instance := candidate as MultiMeshInstance3D
		if multimesh_instance != null and (multimesh_instance.multimesh == null or multimesh_instance.multimesh.mesh == null):
			var parent := multimesh_instance.get_parent()
			if parent != null:
				parent.remove_child(multimesh_instance)
			multimesh_instance.free()
	if not empty_meshes.is_empty():
		push_warning("Removed empty mesh nodes from %s: %s" % [str(root.get_meta("wow_asset_source", root.name)), str(empty_meshes)])

static func _load_gobkit_segments() -> void:
	if _gobkit_segments_loaded:
		return
	_gobkit_segments_loaded = true
	var manifest_path := "res://assets/third_party/gobkit/ANIMATION_SEGMENTS.json"
	if not FileAccess.file_exists(manifest_path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if parsed is Dictionary:
		_gobkit_segments = parsed.get("assets", {})

static func _configure_gobkit_animation_segments(root: Node3D, source_path: String) -> void:
	const PREFIX := "res://assets/third_party/gobkit/"
	if not source_path.begins_with(PREFIX):
		return
	_load_gobkit_segments()
	var relative_path := source_path.trim_prefix(PREFIX)
	var config: Dictionary = _gobkit_segments.get(relative_path, {})
	if config.is_empty():
		return
	var fps := maxf(float(config.get("fps", 24.0)), 1.0)
	var segments: Array = config.get("animations", [])
	for candidate in root.find_children("*", "AnimationPlayer", true, false):
		var player := candidate as AnimationPlayer
		if player == null:
			continue
		var source_animation: Animation = null
		var longest := 0.0
		for animation_name in player.get_animation_list():
			var candidate_animation := player.get_animation(animation_name)
			if candidate_animation != null and candidate_animation.length > longest:
				longest = candidate_animation.length
				source_animation = candidate_animation
		if source_animation == null:
			continue
		var library := player.get_animation_library("")
		if library == null:
			continue
		for segment in segments:
			if not segment is Dictionary or not segment.has("from") or not segment.has("to"):
				continue
			var clip_name := str(segment.get("name", "")).to_lower()
			if clip_name.is_empty():
				continue
			var start_time := float(segment["from"]) / fps
			var end_time := (float(segment["to"]) + 1.0) / fps
			var default_loop := clip_name == "idle" or clip_name == "walk" or clip_name == "run"
			var subclip := _slice_animation(source_animation, start_time, end_time, bool(segment.get("loop", default_loop)))
			if subclip == null:
				continue
			if library.has_animation(clip_name):
				library.remove_animation(clip_name)
			var error := library.add_animation(clip_name, subclip)
			if error != OK:
				push_warning("Could not add Gobkit animation clip: " + clip_name)
		player.clear_caches()
	root.set_meta("wow_gobkit_segments_ready", true)

static func _slice_animation(source: Animation, start_time: float, end_time: float, looped: bool) -> Animation:
	if source == null or end_time <= start_time:
		return null
	var result := Animation.new()
	result.length = end_time - start_time
	result.step = source.step
	result.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var copied_keys := 0
	for track_index in range(source.get_track_count()):
		if source.track_is_compressed(track_index):
			return null
		source.copy_track(track_index, result)
		var target_track := result.get_track_count() - 1
		result.track_set_imported(target_track, false)
		for key_index in range(result.track_get_key_count(target_track) - 1, -1, -1):
			var key_time := result.track_get_key_time(target_track, key_index)
			if key_time < start_time or key_time >= end_time:
				result.track_remove_key(target_track, key_index)
			else:
				result.track_set_key_time(target_track, key_index, key_time - start_time)
				copied_keys += 1
	if copied_keys == 0:
		return null
	return result

static func _gear_material(item_id: String) -> StandardMaterial3D:
	var data: Dictionary = Items.get_item(item_id)
	var material := StandardMaterial3D.new()
	material.albedo_color = data.get("col", Color("8a919c"))
	material.metallic = 0.62 if str(data.get("type", "")) in ["Plaka", "Zincir", "Kalkan"] else 0.12
	material.roughness = 0.72
	return material

static func _gear_piece(parent: Node3D, mesh: Mesh, material: Material, position: Vector3, rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	piece.mesh = mesh
	piece.material_override = material
	piece.position = position
	piece.rotation_degrees = rotation_degrees
	parent.add_child(piece)
	return piece

static func _gear_box(parent: Node3D, size: Vector3, material: Material, position: Vector3, rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _gear_piece(parent, mesh, material, position, rotation_degrees)

static func _gear_sphere(parent: Node3D, radius: float, material: Material, position: Vector3, scale_value: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var piece := _gear_piece(parent, mesh, material, position)
	piece.scale = scale_value
	return piece

static func _make_wearable_overlay(item_id: String, slot: String) -> Node3D:
	var root := Node3D.new()
	root.name = "Wearable_" + item_id
	root.set_meta("wow_imported_equipment", true)
	var material := _gear_material(item_id)
	var dark := material.duplicate() as StandardMaterial3D
	dark.albedo_color = material.albedo_color.darkened(0.28)
	var trim := StandardMaterial3D.new()
	trim.albedo_color = Color("d7b56b")
	trim.metallic = 0.72
	trim.roughness = 0.38
	match slot:
		"chest":
			_gear_box(root, Vector3(0.98, 0.72, 0.13), material, Vector3(0, 0, 0))
			_gear_box(root, Vector3(0.18, 0.72, 0.15), dark, Vector3(-0.42, 0, -0.005))
			_gear_box(root, Vector3(0.18, 0.72, 0.15), dark, Vector3(0.42, 0, -0.005))
			_gear_box(root, Vector3(0.14, 0.64, 0.035), trim, Vector3(0, 0, 0.085))
			_gear_box(root, Vector3(0.56, 0.1, 0.04), trim, Vector3(0, 0.28, 0.09))
		"head":
			var helmet := SphereMesh.new()
			helmet.radius = 0.34
			helmet.height = 0.44
			helmet.is_hemisphere = true
			helmet.radial_segments = 18
			helmet.rings = 8
			_gear_piece(root, helmet, material, Vector3(0, 0.09, 0))
			_gear_box(root, Vector3(0.58, 0.09, 0.12), dark, Vector3(0, -0.02, 0.2))
			_gear_box(root, Vector3(0.08, 0.2, 0.05), trim, Vector3(0, -0.04, 0.265))
		"shoulder":
			for side in [-1.0, 1.0]:
				_gear_sphere(root, 0.31, material, Vector3(side * 0.59, 0.02, 0), Vector3(1.0, 0.82, 1.0))
				_gear_box(root, Vector3(0.28, 0.09, 0.36), trim, Vector3(side * 0.59, -0.16, 0))
		"back":
			_gear_box(root, Vector3(0.82, 1.12, 0.07), material, Vector3(0, -0.55, -0.03), Vector3(-8, 0, 0))
			_gear_box(root, Vector3(0.9, 0.1, 0.1), trim, Vector3(0, -0.06, -0.02))
		"neck":
			var necklace := TorusMesh.new()
			necklace.inner_radius = 0.22
			necklace.outer_radius = 0.28
			necklace.rings = 20
			necklace.ring_segments = 8
			_gear_piece(root, necklace, material, Vector3(0, -0.02, 0))
			_gear_sphere(root, 0.09, trim, Vector3(0, -0.27, 0.08))
		"ring1", "ring2":
			var ring_mesh := TorusMesh.new()
			ring_mesh.inner_radius = 0.055
			ring_mesh.outer_radius = 0.085
			ring_mesh.rings = 16
			ring_mesh.ring_segments = 8
			_gear_piece(root, ring_mesh, material, Vector3.ZERO)
			_gear_sphere(root, 0.045, trim, Vector3(0, 0.055, 0))
		"trinket1", "trinket2":
			_gear_box(root, Vector3(0.2, 0.26, 0.07), material, Vector3(0, -0.04, 0))
			_gear_box(root, Vector3(0.1, 0.12, 0.035), trim, Vector3(0, -0.04, 0.055))
			_gear_sphere(root, 0.045, trim, Vector3(0, -0.2, 0.02))
		"wrist":
			var cuff := CylinderMesh.new()
			cuff.top_radius = 0.18
			cuff.bottom_radius = 0.2
			cuff.height = 0.24
			cuff.radial_segments = 16
			_gear_piece(root, cuff, material, Vector3.ZERO)
		"hands":
			_gear_box(root, Vector3(0.34, 0.28, 0.34), material, Vector3(0, -0.02, 0))
			_gear_box(root, Vector3(0.14, 0.2, 0.24), dark, Vector3(0, -0.2, 0.04))
		"waist":
			_gear_box(root, Vector3(1.0, 0.15, 0.7), material, Vector3(0, 0, 0))
			_gear_box(root, Vector3(0.2, 0.18, 0.08), trim, Vector3(0, 0, 0.37))
		"legs":
			for side in [-1.0, 1.0]:
				_gear_box(root, Vector3(0.39, 0.72, 0.48), material, Vector3(side * 0.24, -0.08, 0))
				_gear_box(root, Vector3(0.41, 0.1, 0.5), trim, Vector3(side * 0.24, -0.42, 0.01))
		"feet":
			for side in [-1.0, 1.0]:
				_gear_box(root, Vector3(0.46, 0.24, 0.62), material, Vector3(side * 0.24, -0.03, 0.08))
				_gear_box(root, Vector3(0.47, 0.06, 0.63), dark, Vector3(side * 0.24, -0.16, 0.08))
	return root

static func _equipment_bounds(root: Node3D) -> AABB:
	var bounds := AABB()
	var has_bounds := false
	for candidate in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := candidate as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var transform := mesh_instance.transform
		var parent := mesh_instance.get_parent()
		while parent != null and parent != root:
			transform = (parent as Node3D).transform * transform
			parent = parent.get_parent()
		var mesh_bounds := transform * mesh_instance.mesh.get_aabb()
		if not has_bounds:
			bounds = mesh_bounds
			has_bounds = true
		else:
			bounds = bounds.merge(mesh_bounds)
	return bounds if has_bounds else AABB(Vector3(-0.25, -0.25, -0.25), Vector3(0.5, 0.5, 0.5))

static func _fit_equipment_model(item: Node3D, slot: String) -> void:
	var bounds := _equipment_bounds(item)
	var dimensions := bounds.size
	var center := bounds.position + dimensions * 0.5
	var target := 1.0
	match slot:
		"mainhand": target = 1.12
		"offhand": target = 0.88
		"head": target = 0.62
		"shoulder": target = 1.22
	var longest := maxf(dimensions.x, maxf(dimensions.y, dimensions.z))
	var scale_value := target / maxf(longest, 0.001)
	item.scale = Vector3.ONE * scale_value
	if slot == "mainhand":
		item.position = Vector3(-center.x * scale_value, -bounds.position.y * scale_value, -center.z * scale_value)
	else:
		item.position = -center * scale_value
	if slot == "head":
		item.position.y += 0.06
	elif slot == "shoulder":
		item.position.y += 0.04

static func refresh_equipment(character: Node3D, equipped: Dictionary) -> void:
	if character == null or not is_instance_valid(character):
		return
	var previous: Dictionary = character.get_meta("wow_equipment_ids", {})
	if previous == equipped:
		return
	_clear_imported_equipment(character)
	character.set_meta("wow_equipment_ids", equipped.duplicate(true))
	for slot_value in equipped:
		var slot := str(slot_value)
		var item_id := str(equipped[slot_value])
		if item_id.is_empty():
			continue
		var item: Node3D = null
		# Torso and soft-armor slots use fitted wearable geometry rather than
		# attaching a world-pickup prop to the character.
		if slot in ["neck", "chest", "back", "wrist", "hands", "waist", "legs", "feet", "ring1", "ring2", "trinket1", "trinket2"]:
			item = _make_wearable_overlay(item_id, slot)
		else:
			var local_path := "res://assets/wotlk_local/equipment/%s.glb" % item_id
			var public_path := "res://assets/wotlk/equipment/%s.glb" % item_id
			var mapped_path := str(EQUIPMENT_ASSET_MAP.get(item_id, ""))
			var path := ""
			if ResourceLoader.exists(local_path):
				path = local_path
			elif ResourceLoader.exists(public_path):
				path = public_path
			elif not mapped_path.is_empty() and ResourceLoader.exists(mapped_path):
				path = mapped_path
			if not path.is_empty():
				var packed := load(path) as PackedScene
				if packed != null:
					item = packed.instantiate() as Node3D
			if item == null and slot in ["head", "shoulder"]:
				item = _make_wearable_overlay(item_id, slot)
		if item == null:
			continue
		if not item.has_meta("wow_imported_equipment"):
			item.set_meta("wow_imported_equipment", true)
			_fit_equipment_model(item, slot)
		if not _attach_equipment_node(character, slot, item):
			item.queue_free()

static func _attach_equipment_node(character: Node3D, slot: String, item: Node3D) -> bool:
	var skeleton := _find_skeleton(character)
	var bone_map := {
		"head": ["Head", "head"],
		"shoulder": ["Shoulder.R", "RightShoulder", "shoulder_r"],
		"back": ["Back", "Spine2", "spine_03"],
		"chest": ["Chest", "Spine2", "spine_02"],
		"wrist": ["Forearm.R", "LowerArm.R", "RightForeArm"],
		"hands": ["Hand.R", "RightHand", "hand_r"],
		"waist": ["Pelvis", "Hips", "pelvis"],
		"legs": ["Thigh.R", "UpperLeg.R", "LeftUpLeg"],
		"feet": ["Foot.R", "RightFoot", "foot_r"],
		"mainhand": ["Hand.R", "RightHand", "hand_r"],
		"offhand": ["Hand.L", "LeftHand", "hand_l"],
	}
	if skeleton != null:
		for bone_name in bone_map.get(slot, []):
			if skeleton.find_bone(bone_name) >= 0:
				var attachment := BoneAttachment3D.new()
				attachment.name = "ImportedEquipment_%s" % slot
				attachment.bone_name = bone_name
				attachment.set_meta("wow_imported_equipment", true)
				skeleton.add_child(attachment)
				attachment.add_child(item)
				_set_default_part_visibility(character, slot, false)
				return true
	var sockets: Dictionary = character.get_meta("gear_sockets", {})
	var socket_value: Variant = sockets.get(slot)
	if socket_value is Array:
		var socket_list: Array = socket_value
		if socket_list.is_empty():
			return false
		for socket_index in range(socket_list.size()):
			var paired_socket := socket_list[socket_index] as Node3D
			if paired_socket == null:
				continue
			var paired_item := item if socket_index == 0 else item.duplicate() as Node3D
			if paired_item == null:
				continue
			paired_item.set_meta("wow_imported_equipment", true)
			paired_socket.add_child(paired_item)
		_set_default_part_visibility(character, slot, false)
		return true
	var socket := socket_value as Node3D
	if socket == null:
		var rig: Dictionary = character.get_meta("rig", {})
		var fallback_key := "armR" if slot == "mainhand" else ("armL" if slot == "offhand" else "")
		socket = rig.get(fallback_key) as Node3D if not fallback_key.is_empty() else null
	if socket == null:
		return false
	item.set_meta("wow_imported_equipment", true)
	socket.add_child(item)
	_set_default_part_visibility(character, slot, false)
	return true

static func _set_default_part_visibility(character: Node3D, slot: String, visible: bool) -> void:
	var rig: Dictionary = character.get_meta("rig", {})
	var part_name := "axe" if slot == "mainhand" else ("shield" if slot == "offhand" else "")
	if not part_name.is_empty():
		var part := rig.get(part_name) as Node3D
		if part != null:
			part.visible = visible
	if slot == "head":
		for part in rig.get("helm", []):
			if part is Node3D:
				(part as Node3D).visible = visible
	if slot == "shoulder":
		for part in rig.get("shoulder", []):
			if part is Node3D:
				(part as Node3D).visible = visible

static func _clear_imported_equipment(root: Node) -> void:
	for child in root.get_children():
		if child.has_meta("wow_imported_equipment"):
			root.remove_child(child)
			child.queue_free()
		else:
			_clear_imported_equipment(child)
	var rig: Dictionary = root.get_meta("rig", {})
	for part_name in ["axe", "shield"]:
		var part := rig.get(part_name) as Node3D
		if part != null:
			part.visible = true
	var helm_parts: Array = rig.get("helm", [])
	for part in helm_parts:
		if part is Node3D:
			(part as Node3D).visible = true
	for part in rig.get("shoulder", []):
		if part is Node3D:
			(part as Node3D).visible = true

static func _find_skeleton(root: Node) -> Skeleton3D:
	if root is Skeleton3D:
		return root as Skeleton3D
	var found := root.find_children("*", "Skeleton3D", true, false)
	return found[0] as Skeleton3D if not found.is_empty() else null

static func _find_clip(player: AnimationPlayer, state: String) -> String:
	var aliases: Array = ANIMATION_ALIASES.get(state, [])
	var names := player.get_animation_list()
	# Prefer exact semantic clips before compound names such as 2H_Melee_Idle.
	for alias in aliases:
		for animation_name in names:
			var normalized := String(animation_name).to_lower().replace(" ", "_").replace("-", "_")
			if normalized == String(alias).to_lower():
				return String(animation_name)
	for alias in aliases:
		for animation_name in names:
			var normalized := String(animation_name).to_lower().replace(" ", "_").replace("-", "_")
			if normalized.contains(String(alias).to_lower()):
				return String(animation_name)
	return ""

static func _apply_item_transform(item: Node3D, local_position: Vector3, local_rotation_degrees: Vector3, local_scale: Vector3) -> void:
	item.position = local_position
	item.rotation_degrees = local_rotation_degrees
	item.scale = local_scale
