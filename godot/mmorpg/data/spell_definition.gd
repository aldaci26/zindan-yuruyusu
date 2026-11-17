extends Resource
class_name MMORPGSpellDefinition
## Spell data only. Effects are interpreted by a future spell execution service.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("physical", "magic", "healing", "utility") var school: String = "physical"
@export_enum("self", "single_enemy", "single_ally", "area_enemy", "area_ally") var target_type: String = "single_enemy"
@export_range(0, 100000, 1) var resource_cost: int = 0
@export_range(0.0, 3600.0, 0.05) var cooldown_seconds: float = 0.0
@export_range(0.0, 600.0, 0.05) var cast_time_seconds: float = 0.0
@export_range(0.0, 10000.0, 0.1) var range_units: float = 2.0
@export var effects: Array[Dictionary] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id.is_empty():
		errors.append("Spell id is required.")
	if display_name.strip_edges().is_empty():
		errors.append("Spell display_name is required.")
	if resource_cost < 0 or cooldown_seconds < 0.0 or cast_time_seconds < 0.0 or range_units < 0.0:
		errors.append("Spell costs, times and range cannot be negative.")
	if effects.is_empty():
		errors.append("Spell must define at least one effect.")
	for index in effects.size():
		if str(effects[index].get("type", "")).is_empty():
			errors.append("Spell effect %d needs a type." % index)
	return errors
