extends RefCounted
class_name MMORPGQuestLog
## Tracks player quest state without depending on the main scene or UI.

const QuestDefinition = preload("res://mmorpg/data/quest_definition.gd")
const SAVE_VERSION := 1

signal changed

var definitions: Dictionary = {}
var active: Dictionary = {}
var completed: Array[String] = []

func register_quest(definition: Resource) -> bool:
	if not (definition is QuestDefinition):
		return false
	var errors: PackedStringArray = definition.validate()
	if not errors.is_empty():
		return false
	var key := str(definition.id)
	if definitions.has(key):
		return false
	definitions[key] = definition
	return true

func accept(quest_id: String, player_level: int) -> Dictionary:
	if not definitions.has(quest_id):
		return {"ok": false, "error": "unknown_quest"}
	var quest = definitions[quest_id]
	if active.has(quest_id):
		return {"ok": false, "error": "already_active"}
	if player_level < quest.minimum_level:
		return {"ok": false, "error": "level_too_low"}
	if completed.has(quest_id) and not quest.repeatable:
		return {"ok": false, "error": "already_completed"}
	for prerequisite in quest.prerequisites:
		if not completed.has(str(prerequisite)):
			return {"ok": false, "error": "prerequisite_missing", "prerequisite": str(prerequisite)}
	active[quest_id] = {"progress": {}, "accepted_at": Time.get_unix_time_from_system()}
	changed.emit()
	return {"ok": true}

func record_event(event_type: String, target_id: String, amount: int = 1) -> int:
	if amount <= 0:
		return 0
	var changed_count := 0
	for quest_id in active.keys():
		var quest = definitions.get(quest_id)
		if quest == null:
			continue
		var state: Dictionary = active[quest_id]
		var progress: Dictionary = state.get("progress", {})
		for objective in quest.objectives:
			if str(objective.get("type", "")) != event_type:
				continue
			if str(objective.get("target_id", "")) != target_id:
				continue
			var objective_id := str(objective.get("id", ""))
			var required := maxi(1, int(objective.get("required_count", 1)))
			var before := int(progress.get(objective_id, 0))
			var after := mini(required, before + amount)
			if after > before:
				progress[objective_id] = after
				changed_count += after - before
		state["progress"] = progress
		active[quest_id] = state
	if changed_count > 0:
		changed.emit()
	return changed_count

func get_progress(quest_id: String, objective_id: String) -> int:
	if not active.has(quest_id):
		return 0
	var progress: Dictionary = active[quest_id].get("progress", {})
	return int(progress.get(objective_id, 0))

func is_ready_to_turn_in(quest_id: String) -> bool:
	if not active.has(quest_id) or not definitions.has(quest_id):
		return false
	var quest = definitions[quest_id]
	var progress: Dictionary = active[quest_id].get("progress", {})
	for objective in quest.objectives:
		var objective_id := str(objective.get("id", ""))
		var required := maxi(1, int(objective.get("required_count", 1)))
		if int(progress.get(objective_id, 0)) < required:
			return false
	return true

func turn_in(quest_id: String) -> Dictionary:
	if not is_ready_to_turn_in(quest_id):
		return {"ok": false, "error": "objectives_incomplete"}
	var quest = definitions[quest_id]
	active.erase(quest_id)
	if not completed.has(quest_id):
		completed.append(quest_id)
	changed.emit()
	return {"ok": true, "rewards": quest.rewards.duplicate(true)}

func to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"active": active.duplicate(true),
		"completed": completed.duplicate()
	}

func from_dict(data: Dictionary) -> bool:
	if int(data.get("version", 0)) != SAVE_VERSION:
		return false
	var loaded_active = data.get("active", {})
	var loaded_completed = data.get("completed", [])
	if typeof(loaded_active) != TYPE_DICTIONARY or typeof(loaded_completed) != TYPE_ARRAY:
		return false
	var safe_active := {}
	for quest_id in loaded_active:
		if not definitions.has(str(quest_id)) or typeof(loaded_active[quest_id]) != TYPE_DICTIONARY:
			continue
		var raw_progress = loaded_active[quest_id].get("progress", {})
		if typeof(raw_progress) != TYPE_DICTIONARY:
			continue
		var safe_progress := {}
		var quest = definitions[str(quest_id)]
		for objective in quest.objectives:
			var objective_id := str(objective.get("id", ""))
			var required := maxi(1, int(objective.get("required_count", 1)))
			safe_progress[objective_id] = clampi(int(raw_progress.get(objective_id, 0)), 0, required)
		safe_active[str(quest_id)] = {
			"progress": safe_progress,
			"accepted_at": int(loaded_active[quest_id].get("accepted_at", 0))
		}
	var safe_completed: Array[String] = []
	for quest_id in loaded_completed:
		var key := str(quest_id)
		if definitions.has(key) and not safe_completed.has(key):
			safe_completed.append(key)
	active = safe_active
	completed = safe_completed
	changed.emit()
	return true
