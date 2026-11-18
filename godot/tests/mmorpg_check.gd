extends SceneTree
## godot --headless --path . --script tests/mmorpg_check.gd
const MMBridge = preload("res://mmorpg/mmorpg_bridge.gd")
const Items = preload("res://items.gd")
const Inv = preload("res://inv.gd")
const Hud = preload("res://hud.gd")

func _init() -> void:
	var main = load("res://main.gd")
	var consts: Dictionary = main.get_script_constant_map()
	var mm = MMBridge.new()
	mm.build(Items.db(), consts["QUESTS"], [consts["MTYPES"], consts["SWAMP_MTYPES"], consts["MINE_MTYPES"], consts["ASH_MTYPES"]], Hud.ABIL)
	var bad := 0
	for e in mm.errors:
		print("DOGRULAMA: ", e); bad += 1
	print("esya=%d gorev=%d yaratik=%d yetenek=%d" % [mm.items.size(), mm.quests.size(), mm.creatures.size(), mm.spells.size()])
	if mm.quests.size() != consts["QUESTS"].size():
		print("HATA: gorev sayisi uyusmuyor"); bad += 1
	# görev akışı
	var q: String = "q_murloc"
	var d: Dictionary = consts["QUESTS"][q]
	if mm.on_accept(q, 1): print("HATA: seviye kontrolu"); bad += 1
	if not mm.on_accept(q, 8): print("HATA: kabul"); bad += 1
	for i in d["n"]: mm.on_kill(d["kill"])
	if not mm.quest_log.is_ready_to_turn_in(q): print("HATA: hazir degil"); bad += 1
	if not mm.on_turn_in(q): print("HATA: teslim"); bad += 1
	var qs := {q: {"st": "done", "n": d["n"]}, "q_trogg": {"st": "active", "n": 2}}
	mm.sync_quests(qs, 8)
	var diff: PackedStringArray = mm.check_against(qs)
	if not diff.is_empty(): print("HATA: ", diff); bad += 1
	var save: Dictionary = mm.quest_log.to_dict()
	if not mm.quest_log.from_dict(save): print("HATA: quest from_dict"); bad += 1
	# çanta
	var inv = Inv.new()
	mm.sync_inventory(inv.bag, inv.money)
	if mm.inventory.count_item("pot_heal") != 3: print("HATA: iksir sayisi"); bad += 1
	if not mm.inventory.from_dict(mm.inventory.to_dict(), mm.items): print("HATA: envanter from_dict"); bad += 1
	print("MMORPG OK" if bad == 0 else "MMORPG HATA %d" % bad)
	quit(1 if bad else 0)
