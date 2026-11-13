extends RefCounted
## Çanta, giyilen eşyalar ve para (bakır cinsinden). Saf veri/mantık, arayüz yok.

const Items = preload("res://items.gd")
const BAG_SIZE := 16

var bag: Array = []
var eq := {}
var money := 0
var buyback: Array = []

func _init() -> void:
	reset()

func reset() -> void:
	bag.clear()
	for i in BAG_SIZE:
		bag.append(null)
	eq = {}
	for s in Items.SLOTS:
		eq[s] = ""
	money = 0
	buyback.clear()
	eq["mainhand"] = "axe_old"
	eq["offhand"] = "sh_wood"
	eq["chest"] = "ch_tunic"
	eq["legs"] = "lg_pants"
	eq["feet"] = "ft_boots"
	add("pot_heal", 3)

func count(id: String) -> int:
	var n := 0
	for e in bag:
		if e != null and e["id"] == id:
			n += e["n"]
	return n

func free_slots() -> int:
	var n := 0
	for e in bag:
		if e == null:
			n += 1
	return n

func can_add(id: String, n: int = 1) -> bool:
	var it := Items.get_item(id)
	var room := 0
	for e in bag:
		if e == null:
			room += it["stack"]
		elif e["id"] == id:
			room += it["stack"] - e["n"]
	return room >= n

## Eklenemeyen miktarı döndürür.
func add(id: String, n: int = 1) -> int:
	var it := Items.get_item(id)
	if it.is_empty():
		return n
	var left := n
	if it["stack"] > 1:
		for e in bag:
			if left <= 0:
				break
			if e != null and e["id"] == id and e["n"] < it["stack"]:
				var k := mini(left, it["stack"] - e["n"])
				e["n"] += k
				left -= k
	for i in BAG_SIZE:
		if left <= 0:
			break
		if bag[i] == null:
			var k2 := mini(left, it["stack"])
			bag[i] = {"id": id, "n": k2}
			left -= k2
	return left

func remove(id: String, n: int = 1) -> bool:
	if count(id) < n:
		return false
	var left := n
	for i in range(BAG_SIZE - 1, -1, -1):
		var e = bag[i]
		if e != null and e["id"] == id and left > 0:
			var k := mini(left, e["n"])
			e["n"] -= k
			left -= k
			if e["n"] <= 0:
				bag[i] = null
	return true

func first_free() -> int:
	for i in BAG_SIZE:
		if bag[i] == null:
			return i
	return -1

## Eşyanın girebileceği yuva ("" = giyilemez). Boş olanı tercih eder.
func target_slot(it: Dictionary) -> String:
	var s: String = it.get("slot", "")
	if s == "":
		return ""
	if s == "ring":
		return "ring1" if eq["ring1"] == "" else ("ring2" if eq["ring2"] == "" else "ring1")
	if s == "trinket":
		return "trinket1" if eq["trinket1"] == "" else ("trinket2" if eq["trinket2"] == "" else "trinket1")
	return s

## "" = başarılı, aksi halde hata mesajı. bag_i: çantadaki eşyanın yeri.
func equip_from_bag(i: int, lvl: int, slot: String = "") -> String:
	var e = bag[i]
	if e == null:
		return ""
	var it := Items.get_item(e["id"])
	if not Items.is_equip(it):
		return "Bu eşya giyilemez."
	if lvl < it["req"]:
		return "Bu eşya için seviyen yetersiz."
	if slot == "":
		slot = target_slot(it)
	if not Items.slot_fits(it, slot):
		return "Bu eşya o yuvaya uymuyor."
	var old: String = eq[slot]
	eq[slot] = e["id"]
	bag[i] = {"id": old, "n": 1} if old != "" else null
	return ""

func unequip(slot: String) -> String:
	if eq[slot] == "":
		return ""
	var f := first_free()
	if f < 0:
		return "Çantan dolu."
	bag[f] = {"id": eq[slot], "n": 1}
	eq[slot] = ""
	return ""

func swap_bag(a: int, b: int) -> void:
	if a == b:
		return
	var ea = bag[a]
	var eb = bag[b]
	if ea != null and eb != null and ea["id"] == eb["id"]:
		var st: int = Items.get_item(ea["id"])["stack"]
		var k := mini(ea["n"], st - eb["n"])
		if k > 0:
			eb["n"] += k
			ea["n"] -= k
			if ea["n"] <= 0:
				bag[a] = null
			return
	bag[a] = eb
	bag[b] = ea

func sell(i: int) -> int:
	var e = bag[i]
	if e == null:
		return 0
	var it := Items.get_item(e["id"])
	var gain: int = it["price"] * e["n"]
	money += gain
	buyback.push_front({"id": e["id"], "n": e["n"], "price": gain})
	while buyback.size() > 12:
		buyback.pop_back()
	bag[i] = null
	return gain

func buy(id: String, n: int, cost: int) -> String:
	if money < cost:
		return "Yeterli paran yok."
	if not can_add(id, n):
		return "Çantan dolu."
	money -= cost
	add(id, n)
	return ""

func rebuy(bi: int) -> String:
	var b: Dictionary = buyback[bi]
	if money < b["price"]:
		return "Yeterli paran yok."
	if not can_add(b["id"], b["n"]):
		return "Çantan dolu."
	money -= b["price"]
	add(b["id"], b["n"])
	buyback.remove_at(bi)
	return ""

func to_dict() -> Dictionary:
	var bg: Array = []
	for e in bag:
		bg.append(null if e == null else [e["id"], e["n"]])
	return {"bag": bg, "eq": eq.duplicate(), "money": money}

func from_dict(d: Dictionary) -> bool:
	if typeof(d.get("bag")) != TYPE_ARRAY or typeof(d.get("eq")) != TYPE_DICTIONARY:
		return false
	reset()
	bag.fill(null)
	for s in Items.SLOTS:
		eq[s] = ""
	var i := 0
	for e in d["bag"]:
		if i >= BAG_SIZE:
			break
		if typeof(e) == TYPE_ARRAY and e.size() == 2 and Items.db().has(str(e[0])):
			bag[i] = {"id": str(e[0]), "n": clampi(int(e[1]), 1, Items.get_item(str(e[0]))["stack"])}
		i += 1
	for s in d["eq"]:
		if eq.has(s) and Items.db().has(str(d["eq"][s])) and Items.slot_fits(Items.get_item(str(d["eq"][s])), s):
			eq[s] = str(d["eq"][s])
	money = maxi(0, int(d.get("money", 0)))
	return true
