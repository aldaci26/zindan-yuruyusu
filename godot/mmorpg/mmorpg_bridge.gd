extends RefCounted
class_name MMORPGBridge
## Mevcut oyun verisini (eşya, görev, yaratık, yetenek) mmorpg servislerine yansıtan köprü.
## Oyunun kendi görev/çanta/kayıt sistemi asıl kaynaktır; burası onun doğrulanmış, serileştirilebilir aynasıdır.
## Kayıt biçimine dokunmaz: oyun yüklenince ayna kayıtlı durumdan yeniden kurulur.

const ItemDef = preload("res://mmorpg/data/item_definition.gd")
const QuestDef = preload("res://mmorpg/data/quest_definition.gd")
const CreatureDef = preload("res://mmorpg/data/creature_definition.gd")
const SpellDef = preload("res://mmorpg/data/spell_definition.gd")
const QuestLogScript = preload("res://mmorpg/services/quest_log.gd")
const InventoryScript = preload("res://mmorpg/services/inventory_service.gd")

var items: Dictionary = {}
var quests: Dictionary = {}
var creatures: Dictionary = {}
var spells: Dictionary = {}
var quest_log = QuestLogScript.new()
var inventory = InventoryScript.new(16)
var errors: PackedStringArray = PackedStringArray()

const CATEGORY_BY_SLOT := {"mainhand": "weapon", "offhand": "armor"}

## items_db: Items.db(), quest_tables: [QUESTS, SWAMP...] (id -> sözlük), mob_tables: MTYPES benzeri tablolar, abilities: HudScript.ABIL
func build(items_db: Dictionary, quest_table: Dictionary, mob_tables: Array, abilities: Array) -> void:
	errors = PackedStringArray()
	for id in items_db:
		_add_item(items_db[id])
	for id in quest_table:
		_add_quest(str(id), quest_table[id])
	for table in mob_tables:
		for kind in table:
			_add_creature(str(kind), table[kind])
	for a in abilities:
		_add_spell(a)

func _add_item(src: Dictionary) -> void:
	var d := ItemDef.new()
	d.id = StringName(str(src["id"]))
	d.display_name = str(src.get("name", ""))
	d.quality = clampi(int(src.get("rar", 1)), 0, 5)
	d.max_stack = clampi(int(src.get("stack", 1)), 1, 100)
	d.required_level = maxi(1, int(src.get("req", 1)))
	d.vendor_value = maxi(0, int(src.get("price", 0)))
	var slot := str(src.get("slot", ""))
	d.equipment_slot = StringName(slot)
	if slot == "mainhand":
		d.category = "weapon"
	elif slot != "":
		d.category = "armor"
	elif float(src.get("heal", 0.0)) > 0.0:
		d.category = "consumable"
	else:
		d.category = "misc"
	var stats := {}
	for k in ["armor", "str", "agi", "sta", "dmin", "dmax"]:
		if int(src.get(k, 0)) != 0:
			stats[k] = src[k]
	d.stats = stats
	_keep(d.validate(), "eşya " + str(d.id))
	items[str(d.id)] = d

func _add_quest(id: String, src: Dictionary) -> void:
	var d := QuestDef.new()
	d.id = StringName(id)
	d.title = str(src.get("title", ""))
	d.description = str(src.get("text", ""))
	d.minimum_level = maxi(1, int(src.get("lvl", 1)))
	d.objectives.assign([{"id": "kill", "type": "kill", "target_id": str(src.get("kill", "")), "required_count": int(src.get("n", 1))}])
	d.rewards.assign([
		{"type": "xp", "amount": int(src.get("xp", 0))},
		{"type": "money", "amount": int(src.get("money", 0))},
		{"type": "item_choice", "item_ids": src.get("rew", [])}])
	_keep(d.validate(), "görev " + id)
	if quest_log.register_quest(d):
		quests[id] = d

func _add_creature(kind: String, src: Dictionary) -> void:
	var d := CreatureDef.new()
	d.id = StringName(kind)
	d.display_name = str(src.get("name", ""))
	d.minimum_level = maxi(1, int(src.get("lo", 1)))
	d.maximum_level = maxi(d.minimum_level, int(src.get("hi", d.minimum_level)))
	d.base_health = maxi(1, int(src.get("hp", 1)))
	d.base_damage = maxi(0, int(src.get("dmg", 0)))
	d.aggro_range = float(src.get("aggro", 8.0))
	d.attack_range = maxf(0.1, float(src.get("ranged", 2.0)))
	_keep(d.validate(), "yaratık " + kind)
	creatures[kind] = d

func _add_spell(src: Dictionary) -> void:
	var d := SpellDef.new()
	d.id = StringName(str(src.get("kind", "")))
	d.display_name = str(src.get("name", ""))
	d.description = str(src.get("desc", ""))
	d.resource_cost = maxi(0, int(src.get("cost", 0)))
	d.cooldown_seconds = maxf(0.0, float(src.get("cd", 0.0)))
	d.target_type = "self" if str(src.get("rng", "")) == "Kendin" else "single_enemy"
	d.effects.assign([{"type": str(src.get("kind", "")), "required_level": int(src.get("lvl", 1))}])
	_keep(d.validate(), "yetenek " + str(d.id))
	spells[str(d.id)] = d

func _keep(errs: PackedStringArray, what: String) -> void:
	for e in errs:
		errors.append("%s: %s" % [what, e])

# ---------- oyun olayları ----------
func on_accept(quest_id: String, player_level: int) -> bool:
	return bool(quest_log.accept(quest_id, player_level).get("ok", false))

func on_kill(target_name: String) -> int:
	return quest_log.record_event("kill", target_name, 1)

func on_turn_in(quest_id: String) -> bool:
	return bool(quest_log.turn_in(quest_id).get("ok", false))

## Oyunun görev durumundan ({id: {st, n}}) aynayı baştan kurar (yükleme sonrası).
func sync_quests(game_qs: Dictionary, player_level: int) -> void:
	quest_log.active.clear()
	quest_log.completed.clear()
	for id in game_qs:
		var e: Dictionary = game_qs[id]
		var st := str(e.get("st", ""))
		if st == "done":
			quest_log.completed.append(str(id))
		elif quest_log.definitions.has(str(id)):
			quest_log.active[str(id)] = {"progress": {"kill": int(e.get("n", 0))}, "accepted_at": 0}
	quest_log.changed.emit()

## Çantayı (Inv.bag + para) envanter servisine kopyalar.
func sync_inventory(bag: Array, money: int) -> void:
	var slots: Array = []
	for e in bag:
		if e != null and items.has(str(e["id"])):
			slots.append({"id": str(e["id"]), "count": clampi(int(e["n"]), 1, int(items[str(e["id"])].max_stack))})
		else:
			slots.append(null)
	inventory.slots = slots
	inventory.currency = maxi(0, money)

## Ayna ile oyun durumu uyuşuyor mu? Uyuşmazlık listesi döner (boş = tutarlı).
func check_against(game_qs: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	for id in game_qs:
		var e: Dictionary = game_qs[id]
		var st := str(e.get("st", ""))
		if st == "done" and not quest_log.completed.has(str(id)):
			out.append("%s: tamamlanmış görünmüyor" % id)
		elif st == "ready" and not quest_log.is_ready_to_turn_in(str(id)):
			out.append("%s: teslime hazır görünmüyor" % id)
		elif st == "active" and quest_log.get_progress(str(id), "kill") != int(e.get("n", 0)):
			out.append("%s: ilerleme farklı" % id)
	return out
