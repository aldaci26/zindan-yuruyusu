extends SceneTree
## Headless regression tests for the isolated MMORPG services.

const ItemDefinition = preload("res://mmorpg/data/item_definition.gd")
const QuestDefinition = preload("res://mmorpg/data/quest_definition.gd")
const CreatureDefinition = preload("res://mmorpg/data/creature_definition.gd")
const SpellDefinition = preload("res://mmorpg/data/spell_definition.gd")
const QuestLog = preload("res://mmorpg/services/quest_log.gd")
const InventoryService = preload("res://mmorpg/services/inventory_service.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error("FAIL: " + message)

func _run() -> void:
	var potion = ItemDefinition.new()
	potion.id = &"healing_potion"
	potion.display_name = "Healing Potion"
	potion.max_stack = 5
	_check(potion.validate().is_empty(), "valid item definition should pass validation")

	var creature = CreatureDefinition.new()
	creature.id = &"snow_wolf"
	creature.display_name = "Snow Wolf"
	creature.minimum_level = 2
	creature.maximum_level = 3
	creature.base_health = 80
	_check(creature.validate().is_empty(), "valid creature definition should pass validation")

	var spell = SpellDefinition.new()
	spell.id = &"heroic_strike"
	spell.display_name = "Heroic Strike"
	spell.effects = [{"type": "damage", "power": 12}]
	_check(spell.validate().is_empty(), "valid spell definition should pass validation")

	var inventory = InventoryService.new(2)
	var definitions := {"healing_potion": potion}
	_check(inventory.add_item("healing_potion", 7, definitions) == 0, "inventory should split items across stacks")
	_check(inventory.count_item("healing_potion") == 7, "inventory count should include all stacks")
	_check(inventory.remove_item("healing_potion", 3), "inventory should remove an available quantity")
	_check(inventory.count_item("healing_potion") == 4, "inventory count should update after removal")
	_check(not inventory.remove_item("healing_potion", 99), "inventory must reject removing more than owned")
	var inventory_snapshot: Dictionary = inventory.to_dict()
	var restored_inventory = InventoryService.new(2)
	_check(restored_inventory.from_dict(inventory_snapshot, definitions), "inventory state should round-trip")
	_check(restored_inventory.count_item("healing_potion") == 4, "restored inventory should preserve stack counts")

	var first = QuestDefinition.new()
	first.id = &"clear_wolves"
	first.title = "Clear the Wolves"
	first.minimum_level = 2
	first.objectives = [{
		"id": "wolves",
		"type": "kill",
		"target_id": "snow_wolf",
		"required_count": 3,
		"label": "Defeat snow wolves"
	}]
	first.rewards = [{"type": "currency", "amount": 25}]
	_check(first.validate().is_empty(), "valid quest definition should pass validation")

	var second = QuestDefinition.new()
	second.id = &"report_back"
	second.title = "Report Back"
	second.minimum_level = 1
	second.prerequisites = PackedStringArray(["clear_wolves"])
	second.objectives = [{
		"id": "talk_to_guard",
		"type": "interact",
		"target_id": "north_guard",
		"required_count": 1
	}]

	var journal = QuestLog.new()
	_check(journal.register_quest(first), "quest definition should register")
	_check(journal.register_quest(second), "second quest should register")
	_check(not journal.accept("clear_wolves", 1).ok, "quest level requirement should be enforced")
	_check(journal.accept("clear_wolves", 2).ok, "eligible player should accept quest")
	_check(journal.record_event("kill", "snow_wolf", 2) == 2, "quest event should add progress")
	_check(journal.get_progress("clear_wolves", "wolves") == 2, "quest progress should be queryable")
	_check(not journal.is_ready_to_turn_in("clear_wolves"), "incomplete quest should not be turn-in ready")
	journal.record_event("kill", "snow_wolf", 5)
	_check(journal.is_ready_to_turn_in("clear_wolves"), "objective progress should cap at required count")
	var turn_in: Dictionary = journal.turn_in("clear_wolves")
	_check(turn_in.get("ok", false), "completed quest should turn in")
	_check(turn_in.get("rewards", []).size() == 1, "turn-in should return reward definitions")
	_check(journal.accept("report_back", 2).ok, "completed prerequisite should unlock next quest")
	journal.record_event("interact", "north_guard")
	_check(journal.is_ready_to_turn_in("report_back"), "interaction objective should progress")

	var journal_snapshot: Dictionary = journal.to_dict()
	var restored_journal = QuestLog.new()
	restored_journal.register_quest(first)
	restored_journal.register_quest(second)
	_check(restored_journal.from_dict(journal_snapshot), "quest journal should round-trip")
	_check(restored_journal.is_ready_to_turn_in("report_back"), "restored journal should preserve objective progress")

	if failures.is_empty():
		print("MMORPG CORE TESTS OK")
		quit(0)
	else:
		printerr("MMORPG CORE TESTS FAILED: %d" % failures.size())
		quit(1)
