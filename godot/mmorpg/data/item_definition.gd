extends Resource
class_name MMORPGItemDefinition
## Data-only item definition. Runtime inventory state belongs in InventoryService.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("misc", "weapon", "armor", "consumable", "quest", "material") var category: String = "misc"
@export_range(0, 5, 1) var quality: int = 1
@export_range(1, 100, 1) var max_stack: int = 1
@export_range(1, 1000, 1) var required_level: int = 1
@export var equipment_slot: StringName = &""
@export var vendor_value: int = 0
@export var stats: Dictionary = {}
@export var tags: PackedStringArray = []

func is_equippable() -> bool:
	return not equipment_slot.is_empty()

func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if id.is_empty():
		errors.append("Item id is required.")
	if display_name.strip_edges().is_empty():
		errors.append("Item display_name is required.")
	if max_stack < 1:
		errors.append("Item max_stack must be at least 1.")
	if required_level < 1:
		errors.append("Item required_level must be at least 1.")
	if vendor_value < 0:
		errors.append("Item vendor_value cannot be negative.")
	return errors
