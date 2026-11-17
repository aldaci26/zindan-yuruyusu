extends Resource
class_name MMORPGQuestDefinition
## Quest content definition. Progress is stored by QuestLog, not here.

@export var id: StringName = &""
@export var title: String = ""
@export_multiline var description: String = ""
@export_range(1, 1000, 1) var minimum_level: int = 1
@export var prerequisites: PackedStringArray = []
@export var repeatable: bool = false
@export var objectives: Array[Dictionary] = []
@export var rewards: Array[Dictionary] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id.is_empty():
		errors.append("Quest id is required.")
	if title.strip_edges().is_empty():
		errors.append("Quest title is required.")
	if minimum_level < 1:
		errors.append("Quest minimum_level must be at least 1.")
	if objectives.is_empty():
		errors.append("Quest must have at least one objective.")
	var seen := {}
	for objective in objectives:
		var objective_id := str(objective.get("id", "")).strip_edges()
		if objective_id.is_empty():
			errors.append("Every quest objective needs an id.")
		elif seen.has(objective_id):
			errors.append("Duplicate quest objective id: %s" % objective_id)
		seen[objective_id] = true
		if str(objective.get("type", "")).is_empty():
			errors.append("Objective %s needs a type." % objective_id)
		if str(objective.get("target_id", "")).is_empty():
			errors.append("Objective %s needs a target_id." % objective_id)
		if int(objective.get("required_count", 0)) < 1:
			errors.append("Objective %s required_count must be at least 1." % objective_id)
	return errors
