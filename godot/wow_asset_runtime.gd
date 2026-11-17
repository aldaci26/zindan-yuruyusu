extends RefCounted
## Runtime loader for independently licensed WotLK-style glTF assets.
## Missing assets always fall back to the existing procedural models.

const CREATURE_SCENES := {
	"wolf": ["res://assets/wotlk_local/creatures/wolf.glb", "res://assets/wotlk/creatures/wolf.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Wolf.glb"],
	"spider": ["res://assets/wotlk_local/creatures/spider.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Spider.glb"],
	"rat": ["res://assets/wotlk_local/creatures/rat.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Rat.glb"],
	"frog": ["res://assets/wotlk_local/creatures/frog.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Frog.glb"],
	"snake": ["res://assets/wotlk_local/creatures/snake.glb", "res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Snake.glb"],
	"fox": ["res://assets/wotlk_local/creatures/fox.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Fox.glb"],
	"deer": ["res://assets/wotlk_local/creatures/deer.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Deer.glb"],
	"stag": ["res://assets/wotlk_local/creatures/stag.glb", "res://assets/wotlk/third_party/quaternius/animals_pack/Stag.glb"],
	"defias": ["res://assets/wotlk_local/creatures/defias.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Rogue_Hooded.glb"],
	"darkiron": ["res://assets/wotlk_local/creatures/darkiron.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Knight.glb"],
	"miner": ["res://assets/wotlk_local/creatures/miner.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Barbarian.glb"],
	"guard": ["res://assets/wotlk_local/creatures/guard.glb", "res://assets/third_party/kaykit/adventurers/Characters/gltf/Knight.glb"],
	"skeleton": ["res://assets/wotlk_local/creatures/skeleton.glb", "res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Warrior.glb"],
	"ashbone": ["res://assets/wotlk_local/creatures/ashbone.glb", "res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Minion.glb"],
	"frost_wolf": ["res://assets/wotlk_local/creatures/frost_wolf.glb", "res://assets/wotlk/creatures/frost_wolf.glb"],
	"trogg": ["res://assets/wotlk_local/creatures/trogg.glb", "res://assets/wotlk/creatures/trogg.glb"],
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
