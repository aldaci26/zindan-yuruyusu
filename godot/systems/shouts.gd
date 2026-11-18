extends RefCounted
## Savaş Çığlıkları: haritalardaki kelime duvarlarından kelime öğrenilir; her çığlık 1-3 kelimeyle güçlenir.
## (Özgün tasarım: Skyrim'in "Thu'um" fikrinden esinlenmiştir, ad ve kelimeler bu oyuna aittir.)

const ORDER := ["force", "skin", "flame"]

const SHOUTS := {
	"force": {"name": "Taş Yıkan", "words": [["GRAM", "Taş"], ["TORK", "Yıkım"], ["BAZUN", "Dalga"]],
		"cd": [24.0, 18.0, 12.0], "mult": [1.6, 2.4, 3.4], "knock": [3.0, 5.0, 7.0], "range": 10.0,
		"desc": "Önündeki düşmanları geri savurur ve hasar verir."},
	"skin": {"name": "Demir Deri", "words": [["DURN", "Demir"], ["KHAZ", "Deri"], ["MORD", "Dağ"]],
		"cd": [40.0, 34.0, 28.0], "red": [0.30, 0.45, 0.60], "dur": [8.0, 10.0, 12.0],
		"desc": "Kısa süre boyunca aldığın hasarı azaltır."},
	"flame": {"name": "Kül Nefesi", "words": [["ZURG", "Kor"], ["ASHK", "Kül"], ["VULK", "Alev"]],
		"cd": [30.0, 24.0, 18.0], "mult": [1.4, 2.0, 2.8], "range": 11.0,
		"desc": "Önündeki düşmanları alevle yakar."},
}

## Kelime duvarları: her haritada üç çığlığın birer kelimesi
const WALLS := [
	{"id": "w_snow_f", "map": "snow", "x": -62.0, "z": 30.0, "shout": "force", "idx": 0},
	{"id": "w_snow_s", "map": "snow", "x": 58.0, "z": 38.0, "shout": "skin", "idx": 0},
	{"id": "w_snow_a", "map": "snow", "x": -30.0, "z": -66.0, "shout": "flame", "idx": 0},
	{"id": "w_swamp_f", "map": "swamp", "x": 50.0, "z": -40.0, "shout": "force", "idx": 1},
	{"id": "w_swamp_s", "map": "swamp", "x": -55.0, "z": -30.0, "shout": "skin", "idx": 1},
	{"id": "w_swamp_a", "map": "swamp", "x": 10.0, "z": 55.0, "shout": "flame", "idx": 1},
	{"id": "w_ash_f", "map": "ash", "x": -70.0, "z": 18.0, "shout": "force", "idx": 2},
	{"id": "w_ash_s", "map": "ash", "x": 30.0, "z": -22.0, "shout": "skin", "idx": 2},
	{"id": "w_ash_a", "map": "ash", "x": 66.0, "z": 4.0, "shout": "flame", "idx": 2},
]

static func wall_def(id: String) -> Dictionary:
	for w in WALLS:
		if w["id"] == id:
			return w
	return {}

## Bu çığlık için bilinen kelime sayısı (0-3)
static func known(walls: Dictionary, shout: String) -> int:
	var n := 0
	for w in WALLS:
		if w["shout"] == shout and walls.has(w["id"]):
			n += 1
	return n

static func cooldown(shout: String, n: int) -> float:
	return SHOUTS[shout]["cd"][clampi(n, 1, 3) - 1]

static func power(shout: String, key: String, n: int) -> float:
	return SHOUTS[shout][key][clampi(n, 1, 3) - 1]

static func word_text(w: Dictionary) -> String:
	var wd: Array = SHOUTS[w["shout"]]["words"][w["idx"]]
	return "%s — %s" % [wd[0], wd[1]]

## Kayıttan gelen duvar listesini temizler
static func sanitize(raw) -> Dictionary:
	var out := {}
	if typeof(raw) == TYPE_DICTIONARY:
		for k in raw:
			if not wall_def(str(k)).is_empty():
				out[str(k)] = true
	return out
