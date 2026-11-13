extends RefCounted
## Eşya veritabanı (WoW Classic mantığı: nadirlik renkleri, yuvalar, istatistikler, satış fiyatı).

const RARITY_COL := [Color("9d9d9d"), Color("ffffff"), Color("1eff00"), Color("0070dd"), Color("a335ee")]
const RARITY_NAME := ["Düşük Kalite", "Sıradan", "Sıradışı", "Nadir", "Destansı"]
const SLOTS := ["head", "neck", "shoulder", "back", "chest", "wrist", "hands", "waist", "legs", "feet", "ring1", "ring2", "trinket1", "trinket2", "mainhand", "offhand"]
const SLOT_NAME := {
	"head": "Baş", "neck": "Boyun", "shoulder": "Omuz", "back": "Sırt", "chest": "Göğüs", "wrist": "Bilek", "hands": "Eller",
	"waist": "Bel", "legs": "Bacaklar", "feet": "Ayaklar", "ring": "Yüzük", "trinket": "Mücevher", "mainhand": "Ana El", "offhand": "Yan El",
	"ring1": "Yüzük", "ring2": "Yüzük", "trinket1": "Mücevher", "trinket2": "Mücevher",
}
const TIER := {"Kumaş": 0, "Deri": 1, "Zincir": 2, "Plaka": 3}
const COLS := {
	"brown": "7a5230", "tan": "b89a6a", "iron": "8a919c", "steel": "c3cfdf", "bronze": "b8782e", "gold": "e6b440", "mith": "7fb8e8",
	"fur": "d8d0c0", "bone": "eadfc8", "dark": "4a4a54", "red": "a32a2a", "blue": "2a55b8", "wood": "8a6238", "green": "3f7a4a",
}

## Takımlar: parça sayısına göre ek güç (WoW'daki set bonusları gibi).
const SETS := {
	"deep": {"name": "Derin Ocak Takımı", "pieces": ["ch_deep", "hd_deep", "ft_deep", "sh_deep", "axe_deepf"], "bonus": [
		{"n": 2, "txt": "+4 Dayanıklılık", "sta": 4},
		{"n": 3, "txt": "Kritik vuruş şansı %2 artar", "crit": 2.0},
		{"n": 5, "txt": "Verdiğin hasar %6 artar", "dmg": 0.06}]},
	"king": {"name": "Dağ Kralının Mirası", "pieces": ["helm_king", "rg_king", "sh_king", "axe_king"], "bonus": [
		{"n": 2, "txt": "+6 Güç", "str": 6},
		{"n": 3, "txt": "Kritik vuruş şansı %3 artar", "crit": 3.0},
		{"n": 4, "txt": "Verdiğin hasar %8 artar, her vuruşta +2 öfke", "dmg": 0.08, "rage": 2.0}]},
}

static var _db := {}

static func db() -> Dictionary:
	if _db.is_empty():
		_build()
	return _db

static func get_item(id: String) -> Dictionary:
	return db().get(id, {})

static func _eq(id: String, nm: String, slot: String, rar: int, req: int, armor: int, s: int, a: int, st: int, price: int, type: String, col: String, look: int = 0) -> void:
	_db[id] = {"id": id, "name": nm, "slot": slot, "rar": rar, "req": req, "armor": armor, "str": s, "agi": a, "sta": st, "price": price,
		"type": type, "col": Color(COLS[col]), "look": look, "stack": 1}

static func _wp(id: String, nm: String, rar: int, req: int, dmin: int, dmax: int, spd: float, s: int, a: int, st: int, price: int, col: String, look: int) -> void:
	_db[id] = {"id": id, "name": nm, "slot": "mainhand", "rar": rar, "req": req, "armor": 0, "str": s, "agi": a, "sta": st, "price": price,
		"type": "Tek El", "col": Color(COLS[col]), "look": look, "stack": 1, "dmin": dmin, "dmax": dmax, "spd": spd}

static func _misc(id: String, nm: String, rar: int, req: int, price: int, stack: int, icon: String, heal: float = 0.0, col: String = "iron") -> void:
	_db[id] = {"id": id, "name": nm, "slot": "", "rar": rar, "req": req, "armor": 0, "str": 0, "agi": 0, "sta": 0, "price": price,
		"type": "", "col": Color(COLS[col]), "look": 0, "stack": stack, "icon": icon, "heal": heal}

static func _build() -> void:
	# kafa
	_eq("helm_cap", "Deri Kasket", "head", 1, 1, 5, 0, 0, 0, 8, "Deri", "brown")
	_eq("helm_iron", "Demir Miğfer", "head", 1, 3, 16, 0, 0, 1, 70, "Zincir", "iron")
	_eq("helm_horn", "Boynuzlu Miğfer", "head", 2, 4, 22, 2, 0, 2, 160, "Plaka", "steel", 1)
	_eq("helm_ward", "Muhafız Miğferi", "head", 2, 6, 30, 2, 0, 3, 260, "Plaka", "blue", 2)
	_eq("helm_bear", "Ayı Başlığı", "head", 3, 5, 26, 4, 0, 4, 420, "Deri", "fur", 1)
	_eq("helm_king", "Dağ Kralı Tacı", "head", 4, 9, 52, 6, 3, 7, 1800, "Plaka", "gold", 2)
	# boyun
	_eq("nk_tooth", "Kurt Dişi Kolye", "neck", 2, 2, 0, 0, 2, 0, 40, "", "fur")
	_eq("nk_rune", "Rünlü Madalyon", "neck", 2, 5, 0, 2, 0, 3, 220, "", "bronze")
	_eq("nk_gold", "Altın Zincir", "neck", 3, 7, 0, 3, 0, 4, 520, "", "gold")
	# omuz
	_eq("so_pad", "Yastıklı Omuzluk", "shoulder", 1, 2, 6, 0, 0, 0, 20, "Deri", "brown")
	_eq("so_iron", "Demir Omuzluk", "shoulder", 1, 3, 14, 1, 0, 0, 60, "Zincir", "iron")
	_eq("so_boar", "Domuz Dişi Omuzluk", "shoulder", 2, 5, 20, 2, 0, 2, 190, "Zincir", "bronze")
	_eq("so_peak", "Zirve Omuzlukları", "shoulder", 3, 7, 30, 3, 0, 4, 480, "Plaka", "steel")
	# sırt
	_eq("bk_cloak", "Yün Pelerin", "back", 1, 1, 2, 0, 0, 0, 8, "Kumaş", "brown")
	_eq("bk_fur", "Kurt Postu Pelerin", "back", 2, 2, 3, 0, 0, 2, 50, "Kumaş", "fur")
	_eq("bk_bear", "Ayı Postu Pelerin", "back", 3, 5, 6, 0, 2, 3, 360, "Kumaş", "brown")
	# göğüs
	_eq("ch_tunic", "Çırak Gömleği", "chest", 1, 1, 3, 0, 0, 0, 5, "Kumaş", "tan")
	_eq("ch_leather", "Deri Yelek", "chest", 1, 2, 12, 0, 0, 0, 40, "Deri", "brown")
	_eq("ch_mail", "Zincir Gömlek", "chest", 2, 4, 32, 0, 0, 2, 190, "Zincir", "iron")
	_eq("ch_plate", "Demirkazan Plaka Zırhı", "chest", 3, 6, 58, 4, 0, 4, 640, "Plaka", "steel")
	_eq("ch_deep", "Ocak Plakası", "chest", 4, 8, 84, 6, 0, 7, 1500, "Plaka", "dark")
	# bilek
	_eq("wr_cloth", "Bez Bilek Bandı", "wrist", 1, 1, 2, 0, 0, 0, 5, "Kumaş", "tan")
	_eq("wr_iron", "Demir Bileklik", "wrist", 1, 3, 8, 0, 0, 0, 45, "Zincir", "iron")
	_eq("wr_rune", "Rünlü Bileklik", "wrist", 3, 6, 12, 3, 0, 2, 380, "Plaka", "bronze")
	# eller
	_eq("hd_glove", "Deri Eldiven", "hands", 1, 2, 5, 0, 0, 0, 18, "Deri", "brown")
	_eq("hd_iron", "Demir Eldiven", "hands", 2, 4, 14, 1, 0, 0, 110, "Zincir", "iron")
	_eq("hd_deep", "Ocak Eldiveni", "hands", 3, 7, 22, 3, 0, 3, 450, "Plaka", "steel")
	# bel
	_eq("wt_belt", "Deri Kemer", "waist", 1, 1, 3, 0, 0, 0, 8, "Deri", "brown")
	_eq("wt_iron", "Demir Kemer", "waist", 1, 4, 12, 0, 0, 1, 80, "Zincir", "iron")
	_eq("wt_rune", "Rünlü Kemer", "waist", 3, 6, 18, 2, 0, 3, 360, "Plaka", "gold")
	# bacak
	_eq("lg_pants", "Çırak Pantolonu", "legs", 1, 1, 3, 0, 0, 0, 5, "Kumaş", "brown")
	_eq("lg_leather", "Deri Pantolon", "legs", 1, 2, 10, 0, 0, 0, 36, "Deri", "brown")
	_eq("lg_mail", "Zincir Pantolon", "legs", 2, 4, 28, 0, 0, 2, 170, "Zincir", "iron")
	_eq("lg_plate", "Plaka Bacaklık", "legs", 3, 7, 48, 3, 0, 4, 540, "Plaka", "steel")
	# ayak
	_eq("ft_boots", "Çırak Çizmeleri", "feet", 1, 1, 3, 0, 0, 0, 5, "Deri", "brown")
	_eq("ft_hide", "Deri Çizme", "feet", 1, 3, 9, 0, 0, 0, 30, "Deri", "tan")
	_eq("ft_iron", "Demir Çizme", "feet", 2, 5, 20, 0, 1, 1, 150, "Zincir", "iron")
	_eq("ft_deep", "Ocak Çizmeleri", "feet", 3, 7, 28, 0, 2, 3, 420, "Plaka", "steel")
	# yüzük
	_eq("rg_iron", "Demir Yüzük", "ring", 2, 3, 0, 0, 0, 2, 60, "", "iron")
	_eq("rg_sig", "Mühür Yüzüğü", "ring", 2, 5, 0, 2, 2, 0, 200, "", "gold")
	_eq("rg_ruby", "Yakut Yüzük", "ring", 3, 7, 0, 3, 0, 4, 500, "", "red")
	_eq("rg_king", "Dağ Kralı Mührü", "ring", 4, 9, 0, 5, 5, 5, 1600, "", "gold")
	# mücevher
	_eq("tr_whet", "Bileme Taşı", "trinket", 2, 4, 0, 3, 0, 0, 140, "", "dark")
	_eq("tr_horn", "Savaş Borusu", "trinket", 3, 6, 0, 4, 0, 4, 460, "", "bone")
	_eq("tr_eye", "Kartal Gözü", "trinket", 4, 8, 0, 5, 5, 0, 1400, "", "green")
	# silahlar
	_wp("axe_old", "Eski Balta", 1, 1, 4, 8, 2.0, 0, 0, 0, 6, "iron", 0)
	_wp("axe_iron", "Demir Balta", 1, 2, 7, 12, 2.1, 0, 0, 0, 55, "iron", 0)
	_wp("axe_wolf", "Kurt Dişi Baltası", 2, 2, 8, 14, 1.8, 0, 3, 0, 90, "fur", 0)
	_wp("axe_boar", "Domuz Parçalayıcı", 2, 3, 10, 17, 2.3, 3, 0, 0, 130, "bronze", 0)
	_wp("axe_forge", "Ocak Baltası", 2, 4, 12, 19, 2.2, 2, 0, 1, 170, "steel", 1)
	_wp("sword_gate", "Kapı Bekçisi Kılıcı", 2, 5, 13, 21, 2.0, 2, 1, 0, 230, "steel", 3)
	_wp("hammer_smith", "Demirci Çekici", 2, 5, 14, 22, 2.4, 2, 0, 2, 240, "iron", 2)
	_wp("axe_deepf", "Derin Ocak Baltası", 3, 5, 18, 29, 2.3, 5, 0, 3, 520, "mith", 1)
	_wp("axe_storm", "Fırtına Kıran", 3, 7, 22, 35, 2.1, 4, 4, 0, 700, "mith", 0)
	_wp("axe_king", "Dağ Kralının Baltası", 4, 8, 30, 47, 2.4, 8, 3, 5, 2200, "gold", 1)
	# kalkanlar
	_eq("sh_wood", "Tahta Kalkan", "offhand", 1, 1, 10, 0, 0, 0, 8, "Kalkan", "wood")
	_eq("sh_iron", "Demir Kalkan", "offhand", 1, 3, 26, 0, 0, 0, 90, "Kalkan", "iron")
	_eq("sh_gate", "Kapı Muhafızı Kalkanı", "offhand", 2, 3, 34, 0, 0, 3, 150, "Kalkan", "blue")
	_eq("sh_rein", "Takviyeli Kalkan", "offhand", 2, 5, 42, 0, 0, 2, 240, "Kalkan", "steel")
	_eq("sh_deep", "Derin Ocak Burçlu Kalkanı", "offhand", 3, 5, 62, 2, 0, 5, 560, "Kalkan", "bronze")
	_eq("sh_king", "Kral Kalkanı", "offhand", 4, 9, 90, 4, 0, 8, 2000, "Kalkan", "gold")
	# tüketilenler ve çerçöp
	_misc("pot_heal", "Can İksiri", 1, 1, 20, 20, "potion", 0.45, "red")
	_misc("pot_big", "Büyük Can İksiri", 1, 5, 60, 20, "potion", 0.7, "red")
	_misc("j_wolf", "Yıpranmış Kurt Postu", 0, 1, 9, 20, "pelt", 0.0, "fur")
	_misc("j_boar", "Domuz Derisi", 0, 1, 13, 20, "pelt", 0.0, "brown")
	_misc("j_bear", "Ayı Pençesi", 0, 1, 28, 20, "claw", 0.0, "bone")

# ---------- yardımcılar ----------
static func slot_fits(it: Dictionary, slot: String) -> bool:
	var s: String = it.get("slot", "")
	if s == "":
		return false
	if s == "ring":
		return slot == "ring1" or slot == "ring2"
	if s == "trinket":
		return slot == "trinket1" or slot == "trinket2"
	return s == slot

static func is_equip(it: Dictionary) -> bool:
	return it.get("slot", "") != ""

static func buy_price(it: Dictionary) -> int:
	return maxi(1, it["price"] * 4)

static func money_plain(c: int) -> String:
	var g := c / 10000
	var sv := (c / 100) % 100
	var k := c % 100
	var out := ""
	if g > 0:
		out += "%d altın " % g
	if sv > 0 or g > 0:
		out += "%d gümüş " % sv
	return out + "%d bakır" % k

static func money_short(c: int) -> String:
	var g := c / 10000
	var sv := (c / 100) % 100
	if g > 0:
		return "%dg %ds %dc" % [g, sv, c % 100]
	if sv > 0:
		return "%ds %dc" % [sv, c % 100]
	return "%dc" % c

static func money_bb(c: int) -> String:
	var g := c / 10000
	var s := (c / 100) % 100
	var k := c % 100
	var out := ""
	if g > 0:
		out += "[color=#ffd100]%dg[/color] " % g
	if s > 0 or g > 0:
		out += "[color=#c9c9d0]%ds[/color] " % s
	out += "[color=#c97a3a]%dc[/color]" % k
	return out

static func weapon_dps(it: Dictionary) -> float:
	return (it["dmin"] + it["dmax"]) * 0.5 / it["spd"]

static func tip_bb(it: Dictionary, lvl: int, eq: Dictionary = {}) -> String:
	if it.is_empty():
		return ""
	var rc: Color = RARITY_COL[it["rar"]]
	var out := "[b][color=#%s]%s[/color][/b]\n" % [rc.to_html(false), it["name"]]
	if it["slot"] != "":
		var typ: String = it["type"]
		var sl: String = SLOT_NAME[it["slot"]]
		if it["slot"] == "mainhand":
			out += "%s\n" % typ
			out += "%d - %d Hasar    Hız %.2f\n" % [it["dmin"], it["dmax"], it["spd"]]
			out += "[color=#cfcfcf](saniyede %.1f hasar)[/color]\n" % weapon_dps(it)
		else:
			out += "%s%s\n" % [sl, ("    " + typ) if typ != "" else ""]
			if it["armor"] > 0:
				out += "%d Zırh\n" % it["armor"]
		if it["str"] > 0:
			out += "+%d Güç\n" % it["str"]
		if it["agi"] > 0:
			out += "+%d Çeviklik\n" % it["agi"]
		if it["sta"] > 0:
			out += "+%d Dayanıklılık\n" % it["sta"]
		var rq := "[color=#ff2020]" if lvl < it["req"] else "[color=#ffffff]"
		out += "%sGereken Seviye: %d[/color]\n" % [rq, it["req"]]
		out += set_bb(it["id"], eq)
	else:
		if it.get("heal", 0.0) > 0.0:
			out += "[color=#1eff00]Kullanım: Canının %%%d kadarını geri verir.[/color]\n" % roundi(it["heal"] * 100.0)
		if it["rar"] == 0:
			out += "[color=#9d9d9d]Çerçöp[/color]\n"
	out += "Satış Fiyatı: " + money_bb(it["price"])
	return out

static func set_of(id: String) -> String:
	for k in SETS:
		if id in SETS[k]["pieces"]:
			return k
	return ""

static func set_count(k: String, eq: Dictionary) -> int:
	var n := 0
	for p in SETS[k]["pieces"]:
		for slot in eq:
			if eq[slot] == p:
				n += 1
				break
	return n

static func set_bb(id: String, eq: Dictionary) -> String:
	var k := set_of(id)
	if k == "":
		return ""
	var S: Dictionary = SETS[k]
	var have := set_count(k, eq)
	var out := "\n[color=#ffd100]%s (%d/%d)[/color]\n" % [S["name"], have, S["pieces"].size()]
	for p in S["pieces"]:
		var worn := false
		for slot in eq:
			if eq[slot] == p:
				worn = true
		out += "[color=%s]  %s[/color]\n" % ["#ffffaa" if worn else "#808080", get_item(p)["name"]]
	out += "\n"
	for b in S["bonus"]:
		out += "[color=%s]Takım (%d): %s[/color]\n" % ["#1eff00" if have >= b["n"] else "#808080", b["n"], b["txt"]]
	return out

## Giyilen eşyalardan toplam istatistik. eq: yuva -> eşya kimliği ("" boş)
static func totals(eq: Dictionary) -> Dictionary:
	var t := {"str": 0, "agi": 0, "sta": 0, "armor": 0, "wmin": 2.0, "wmax": 4.0, "wspd": 2.0, "armed": false, "crit": 0.0, "dmg": 0.0, "rage": 0.0}
	for slot in eq:
		var id: String = eq[slot]
		if id == "":
			continue
		var it := get_item(id)
		if it.is_empty():
			continue
		t["str"] += it["str"]
		t["agi"] += it["agi"]
		t["sta"] += it["sta"]
		t["armor"] += it["armor"]
		if slot == "mainhand":
			t["wmin"] = float(it["dmin"])
			t["wmax"] = float(it["dmax"])
			t["wspd"] = it["spd"]
			t["armed"] = true
	for k in SETS:
		var have := set_count(k, eq)
		for b in SETS[k]["bonus"]:
			if have >= b["n"]:
				for key in ["str", "agi", "sta", "armor", "crit", "dmg", "rage"]:
					t[key] += b.get(key, 0)
	return t

## Dünya ganimeti için uygun eşyalar
static func pool(rar: int, lo: int, hi: int) -> Array:
	var out: Array = []
	for id in db():
		var it: Dictionary = db()[id]
		if it["slot"] != "" and it["rar"] == rar and it["req"] >= lo and it["req"] <= hi:
			out.append(id)
	return out
