extends Resource
class_name MMORPGCreatureDefinition
## Data-only creature template. AI and encounter logic are separate systems.

@export var id: StringName = &""
@export var display_name: String = ""
@export_range(1, 1000, 1) var minimum_level: int = 1
@export_range(1, 1000, 1) var maximum_level: int = 1
@export_range(1, 100000000, 1) var base_health: int = 100
@export_range(0, 1000000, 1) var base_damage: int = 5
@export_range(0, 1000000, 1) var armor: int = 0
@export_range(0.0, 1000.0, 0.1) var aggro_range: float = 8.0
@export_range(0.1, 100.0, 0.1) var attack_range: float = 2.0
@export_range(0, 1000000, 1) var experience_reward: int = 0
@export var faction: StringName = &"hostile"
@export var loot_table: Array[Dictionary] = []

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id.is_empty():
		errors.append("Creature id is required.")
	if display_name.strip_edges().is_empty():
		errors.append("Creature display_name is required.")
	if minimum_level < 1 or maximum_level < minimum_level:
		errors.append("Creature level range is invalid.")
	if base_health < 1:
		errors.append("Creature base_health must be positive.")
	if base_damage < 0 or armor < 0 or experience_reward < 0:
		errors.append("Creature combat and reward values cannot be negative.")
	if attack_range <= 0.0 or aggro_range < 0.0:
		errors.append("Creature ranges are invalid.")
	return errors
