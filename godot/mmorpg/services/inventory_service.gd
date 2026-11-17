extends RefCounted
class_name MMORPGInventoryService
## Stack-aware inventory data service. It deliberately contains no UI or scene logic.

signal changed

var slots: Array = []
var currency: int = 0

func _init(slot_count: int = 16) -> void:
	resize_slots(slot_count)

func resize_slots(slot_count: int) -> void:
	var safe_count := clampi(slot_count, 1, 256)
	slots.resize(safe_count)
	for index in slots.size():
		if slots[index] == null:
			slots[index] = null

func count_item(item_id: String) -> int:
	var total := 0
	for entry in slots:
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == item_id:
			total += maxi(0, int(entry.get("count", 0)))
	return total

func can_add_item(item_id: String, amount: int, definitions: Dictionary) -> bool:
	if amount <= 0 or not definitions.has(item_id):
		return false
	var definition = definitions[item_id]
	var max_stack := maxi(1, int(definition.max_stack))
	var capacity := 0
	for entry in slots:
		if entry == null:
			capacity += max_stack
		elif typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == item_id:
			capacity += maxi(0, max_stack - int(entry.get("count", 0)))
	return capacity >= amount

## Returns the amount that could not fit (zero means success).
func add_item(item_id: String, amount: int, definitions: Dictionary) -> int:
	if amount <= 0 or not definitions.has(item_id):
		return maxi(0, amount)
	var definition = definitions[item_id]
	var max_stack := maxi(1, int(definition.max_stack))
	var remaining := amount
	for index in slots.size():
		if remaining <= 0:
			break
		var entry = slots[index]
		if typeof(entry) == TYPE_DICTIONARY and str(entry.get("id", "")) == item_id:
			var room := maxi(0, max_stack - int(entry.get("count", 0)))
			var moved := mini(room, remaining)
			if moved > 0:
				entry["count"] = int(entry.get("count", 0)) + moved
				slots[index] = entry
				remaining -= moved
	for index in slots.size():
		if remaining <= 0:
			break
		if slots[index] == null:
			var moved := mini(max_stack, remaining)
			slots[index] = {"id": item_id, "count": moved}
			remaining -= moved
	if remaining != amount:
		changed.emit()
	return remaining

func remove_item(item_id: String, amount: int) -> bool:
	if amount <= 0 or count_item(item_id) < amount:
		return false
	var remaining := amount
	for index in range(slots.size() - 1, -1, -1):
		var entry = slots[index]
		if typeof(entry) != TYPE_DICTIONARY or str(entry.get("id", "")) != item_id:
			continue
		var moved := mini(remaining, int(entry.get("count", 0)))
		entry["count"] = int(entry.get("count", 0)) - moved
		remaining -= moved
		slots[index] = null if int(entry["count"]) <= 0 else entry
		if remaining <= 0:
			break
	changed.emit()
	return true

func add_currency(amount: int) -> void:
	if amount <= 0:
		return
	currency += amount
	changed.emit()

func spend_currency(amount: int) -> bool:
	if amount < 0 or currency < amount:
		return false
	currency -= amount
	changed.emit()
	return true

func to_dict() -> Dictionary:
	return {"version": 1, "currency": currency, "slots": slots.duplicate(true)}

func from_dict(data: Dictionary, definitions: Dictionary) -> bool:
	if int(data.get("version", 0)) != 1 or typeof(data.get("slots")) != TYPE_ARRAY:
		return false
	var loaded_slots: Array = data["slots"]
	if loaded_slots.size() != slots.size():
		return false
	var safe_slots: Array = []
	for entry in loaded_slots:
		if entry == null:
			safe_slots.append(null)
			continue
		if typeof(entry) != TYPE_DICTIONARY:
			return false
		var item_id := str(entry.get("id", ""))
		var amount := int(entry.get("count", 0))
		if not definitions.has(item_id) or amount < 1:
			return false
		var definition = definitions[item_id]
		if amount > maxi(1, int(definition.max_stack)):
			return false
		safe_slots.append({"id": item_id, "count": amount})
	slots = safe_slots
	currency = maxi(0, int(data.get("currency", 0)))
	changed.emit()
	return true
