extends RefCounted
## Runtime loader for independently licensed WotLK-style glTF assets.
## Missing assets always fall back to the existing procedural models.

const CREATURE_SCENES := {
	"wolf": ["res://assets/wotlk_local/creatures/wolf.glb", "res://assets/wotlk/creatures/wolf.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Wolf.glb"],
	"boar": ["res://assets/wotlk_local/creatures/boar.glb", "res://assets/third_party/gobkit/animalB/Boar.glb", "res://assets/third_party/gobkit/animal012/WildBoar.glb"],
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
	"shaman": ["res://assets/wotlk_local/creatures/shaman.glb", "res://assets/third_party/gobkit/human006/OrcWarShaman.glb"],
	"defias": ["res://assets/wotlk_local/creatures/defias.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Rogue_Hooded.glb"],
	"skeleton": ["res://assets/wotlk_local/creatures/skeleton.glb", "res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Warrior.glb"],
	"ashbone": ["res://assets/wotlk_local/creatures/ashbone.glb", "res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Minion.glb"],
	"frost_wolf": ["res://assets/wotlk_local/creatures/frost_wolf.glb", "res://assets/wotlk/creatures/frost_wolf.glb"],
	"murloc": ["res://assets/wotlk_local/creatures/murloc.glb", "res://assets/wotlk/creatures/murloc.glb"],
	"croc": ["res://assets/wotlk_local/creatures/croc.glb", "res://assets/wotlk/creatures/croc.glb"],
	"gobkit_minion_a": ["res://assets/third_party/gobkit/minion/minion-a01.glb"],
	"gobkit_minion_c": ["res://assets/third_party/gobkit/minion/minion-c01.glb"],
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
	"helm_cap": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet1.glb",
	"helm_iron": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet2.glb",
	"helm_horn": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
	"helm_ward": "res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet3.glb",
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

static func attach_equipment(character: Node3D, slot: String, equipment_scene: PackedScene, bone_candidates: Array[String] = [], local_position: Vector3 = Vector3.ZERO, local_rotation_degrees: Vector3 = Vector3.ZERO, local_scale: Vector3 = Vector3.ONE) -> Node3D:
	if character == null or equipment_scene == null:
		return null
	var equipment := equipment_scene.instantiate() as Node3D
	if equipment == null:
		return null
	var skeleton := _find_skeleton(character)
	if skeleton != null:
		for bone_name in bone_candidates:
			if skeleton.find_bone(bone_name) >= 0:
				var attachment := BoneAttachment3D.new()
				attachment.name = "%s_Attachment" % slot.capitalize()
				attachment.bone_name = bone_name
				skeleton.add_child(attachment)
				attachment.add_child(equipment)
				_apply_item_transform(equipment, local_position, local_rotation_degrees, local_scale)
				return equipment
	var rig: Dictionary = character.get_meta("rig", {})
	var socket_key := "armR" if slot in ["weapon", "right_hand"] else ("armL" if slot in ["shield", "left_hand"] else slot)
	var socket: Node3D = rig.get(socket_key) as Node3D
	if socket == null:
		equipment.queue_free()
		return null
	socket.add_child(equipment)
	_apply_item_transform(equipment, local_position, local_rotation_degrees, local_scale)
	return equipment

static func refresh_equipment(character: Node3D, equipped: Dictionary) -> void:
	if character == null or not is_instance_valid(character):
		return
	var previous: Dictionary = character.get_meta("wow_equipment_ids", {})
	if previous == equipped:
		return
	_clear_imported_equipment(character)
	character.set_meta("wow_equipment_ids", equipped.duplicate(true))
	for slot in equipped:
		var item_id := str(equipped[slot])
		if item_id.is_empty():
			continue
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
		if path.is_empty():
			continue
		var packed := load(path) as PackedScene
		if packed == null:
			continue
		var item := packed.instantiate() as Node3D
		if item == null:
			continue
		if not _attach_equipment_node(character, str(slot), item):
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
	var socket := sockets.get(slot) as Node3D
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
