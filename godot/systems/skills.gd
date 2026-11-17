extends RefCounted
## Skyrim tarzı beceriler: kullandıkça gelişir, perk puanıyla güçlenir. Veri ve saf yardımcılar.

const MAX := 50

## per: seviye başına kalıcı bonus (yüzde). use: becerinin nasıl geliştiği.
const SKILLS := {
	"onehand": {"name": "Tek Elli Silah", "icon": "strike", "use": "Silahınla vurdukça gelişir.", "per": "Saldırı gücü her seviyede %0,4 artar.", "k": 0.004},
	"heavy": {"name": "Ağır Zırh", "icon": "laststand", "use": "Hasar aldıkça gelişir.", "per": "Zırh her seviyede %0,5 artar.", "k": 0.005},
	"block": {"name": "Blok", "icon": "shield", "use": "Kalkan Bloğu ile darbe emdikçe gelişir.", "per": "Bloklu darbelerde her seviyede %0,2 ek öfke kazanırsın.", "k": 0.0},
	"athletics": {"name": "Atletizm", "icon": "charge", "use": "Koştukça gelişir.", "per": "Hareket hızı her seviyede %0,3 artar.", "k": 0.003},
	"speech": {"name": "Hitabet", "icon": "shout", "use": "Alışverişte ve ikna denemelerinde gelişir.", "per": "Satıcı indirimi her seviyede %0,3 artar.", "k": 0.003},
}
const ORDER := ["onehand", "heavy", "block", "athletics", "speech"]

## eff anahtarları: dmg, crit, armor, hp, dr, blk (sn), rage, spd, agi, disc, qxp
const PERKS := [
	{"id": "oh1", "skill": "onehand", "req": 10, "name": "Sağlam Tutuş", "desc": "Saldırı gücü %6 artar.", "eff": {"dmg": 0.06}},
	{"id": "oh2", "skill": "onehand", "req": 25, "name": "Keskin Göz", "desc": "Kritik şansı %5 artar.", "eff": {"crit": 0.05}},
	{"id": "oh3", "skill": "onehand", "req": 40, "name": "Kasabın Hüneri", "desc": "Saldırı gücü %10 artar.", "eff": {"dmg": 0.10}},
	{"id": "hv1", "skill": "heavy", "req": 10, "name": "Çelik Deri", "desc": "Zırh %8 artar.", "eff": {"armor": 0.08}},
	{"id": "hv2", "skill": "heavy", "req": 25, "name": "Taşıyıcı", "desc": "En yüksek can %5 artar.", "eff": {"hp": 0.05}},
	{"id": "hv3", "skill": "heavy", "req": 40, "name": "Yıkılmaz", "desc": "Aldığın hasar %4 azalır.", "eff": {"dr": 0.04}},
	{"id": "bl1", "skill": "block", "req": 10, "name": "Kalkan Duvarı", "desc": "Kalkan Bloğu 1 sn daha uzun sürer.", "eff": {"blk": 1.0}},
	{"id": "bl2", "skill": "block", "req": 25, "name": "Çınlayan Kalkan", "desc": "Bloklu her darbe 4 ek öfke verir.", "eff": {"rage": 4.0}},
	{"id": "bl3", "skill": "block", "req": 40, "name": "Dağ Duvarı", "desc": "Aldığın hasar %3 azalır.", "eff": {"dr": 0.03}},
	{"id": "at1", "skill": "athletics", "req": 10, "name": "Hafif Adım", "desc": "Hareket hızı %5 artar.", "eff": {"spd": 0.05}},
	{"id": "at2", "skill": "athletics", "req": 25, "name": "Dağ Keçisi", "desc": "Çeviklik +6 (kaçınma şansı artar).", "eff": {"agi": 6.0}},
	{"id": "at3", "skill": "athletics", "req": 40, "name": "Rüzgâr Yürüyüşü", "desc": "Hareket hızı %5 daha artar.", "eff": {"spd": 0.05}},
	{"id": "sp1", "skill": "speech", "req": 10, "name": "Pazarlıkçı", "desc": "Satıcı indirimi %5 artar.", "eff": {"disc": 0.05}},
	{"id": "sp2", "skill": "speech", "req": 25, "name": "Tatlı Dil", "desc": "Görev tecrübesi %10 artar.", "eff": {"qxp": 0.10}},
	{"id": "sp3", "skill": "speech", "req": 40, "name": "Cüce Yemini", "desc": "Satıcı indirimi %5 daha artar.", "eff": {"disc": 0.05}},
]

static func perk_def(id: String) -> Dictionary:
	for p in PERKS:
		if p["id"] == id:
			return p
	return {}

static func need(lv: int) -> float:
	return 4.0 + float(lv) * 1.6

static func level_of(skl: Dictionary, id: String) -> int:
	var e = skl.get(id, null)
	return clampi(int(e.get("lv", 1)), 1, MAX) if typeof(e) == TYPE_DICTIONARY else 1

static func xp_of(skl: Dictionary, id: String) -> float:
	var e = skl.get(id, null)
	return maxf(0.0, float(e.get("xp", 0.0))) if typeof(e) == TYPE_DICTIONARY else 0.0

## Beceriye tecrübe ekler. Kazanılan seviye sayısını döndürür.
static func add_xp(skl: Dictionary, id: String, amt: float) -> int:
	if not SKILLS.has(id) or amt <= 0.0:
		return 0
	var lv := level_of(skl, id)
	if lv >= MAX:
		return 0
	var xp := xp_of(skl, id) + amt
	var gained := 0
	while lv < MAX and xp >= need(lv):
		xp -= need(lv)
		lv += 1
		gained += 1
	skl[id] = {"lv": lv, "xp": 0.0 if lv >= MAX else xp}
	return gained

static func perk_sum(perks: Dictionary, key: String) -> float:
	var s := 0.0
	for p in PERKS:
		if perks.has(p["id"]):
			s += float(p["eff"].get(key, 0.0))
	return s

## Kazanılan toplam perk puanı: iki seviyede bir 1, ayrıca seviyesi 30+ her beceri için 1.
static func points_earned(player_lvl: int, skl: Dictionary) -> int:
	var n := maxi(0, (player_lvl - 1) / 2)
	for id in ORDER:
		if level_of(skl, id) >= 30:
			n += 1
	return n

static func points_free(player_lvl: int, skl: Dictionary, perks: Dictionary) -> int:
	return points_earned(player_lvl, skl) - perks.size()

## nul: alınabilir; yoksa neden alınamadığını söyler
static func can_take(player_lvl: int, skl: Dictionary, perks: Dictionary, id: String) -> String:
	var p := perk_def(id)
	if p.is_empty():
		return "Bilinmeyen perk."
	if perks.has(id):
		return "Zaten alındı."
	if level_of(skl, p["skill"]) < int(p["req"]):
		return "%s seviye %d gerekli." % [SKILLS[p["skill"]]["name"], p["req"]]
	if points_free(player_lvl, skl, perks) <= 0:
		return "Perk puanı yok."
	return ""
