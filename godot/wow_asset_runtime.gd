extends RefCounted
## Runtime loader for independently licensed WotLK-style glTF assets.
## Missing assets always fall back to the existing procedural models.

const CREATURE_SCENES := {
	"wolf": ["res://assets/wotlk_local/creatures/wolf.glb", "res://assets/wotlk/creatures/wolf.glb"],
	"frost_wolf": ["res://assets/wotlk_local/creatures/frost_wolf.glb", "res://assets/wotlk/creatures/frost_wolf.glb"],
	"trogg": ["res://assets/wotlk_local/creatures/trogg.glb", "res://assets/wotlk/creatures/trogg.glb"],
}
const ANIMATION_ALIASES := {
	"idle": ["idle", "stand", "breathing"],
	"walk": ["walk", "run", "move"],
	"attack": ["attack", "bite", "melee", "spell"],
	"death": ["death", "die"],
}

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
			return instance as Node3D
		instance.queue_free()
	return fallback.call() as Node3D

static func update_locomotion(root: Node3D, moving: bool, attacking: bool = false) -> void:
	if root == null or not is_instance_valid(root):
		return
	for candidate in root.find_children("*", "AnimationPlayer", true, false):
		var player := candidate as AnimationPlayer
		if player == null:
			continue
		var state := "attack" if attacking else ("walk" if moving else "idle")
		var clip := _find_clip(player, state)
		if clip.is_empty() and state == "attack":
			clip = _find_clip(player, "idle")
		if not clip.is_empty() and player.current_animation != clip:
			player.play(clip)

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
			played = true
	return played

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
		var path := local_path if ResourceLoader.exists(local_path) else public_path
		if not ResourceLoader.exists(path):
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
	for animation_name in player.get_animation_list():
		var normalized := String(animation_name).to_lower().replace(" ", "_").replace("-", "_")
		for alias in aliases:
			if normalized.contains(String(alias)):
				return String(animation_name)
	return ""

static func _apply_item_transform(item: Node3D, local_position: Vector3, local_rotation_degrees: Vector3, local_scale: Vector3) -> void:
	item.position = local_position
	item.rotation_degrees = local_rotation_degrees
	item.scale = local_scale
