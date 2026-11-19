extends RefCounted
## Yetenek kombinasyonları: belirli sırayla kullanılan yetenekler ikincisine ek hasar verir.
## `bonus` önceki yeteneği, ondan geçen süreyi ve hedefin kanayıp kanamadığını bakar.

## from: önceki yetenek, to: şimdi kullanılan, window: sn, mult: hasar çarpanı
const CHAINS := [
	{"from": "charge", "to": "strike", "window": 4.0, "mult": 1.35, "text": "Hamle Kombosu!"},
	{"from": "slam", "to": "mortal", "window": 4.0, "mult": 1.4, "text": "Sersemletici Kombo!"},
	{"from": "pummel", "to": "execute", "window": 4.0, "mult": 1.3, "text": "Kafa Kırıcı Kombosu!"},
	{"from": "shout", "to": "whirl", "window": 6.0, "mult": 1.3, "text": "Nara Kasırgası!"},
	{"from": "clap", "to": "whirl", "window": 5.0, "mult": 1.25, "text": "Gök Kasırgası!"},
	{"from": "mortal", "to": "execute", "window": 5.0, "mult": 1.2, "text": "Son Vuruş Kombosu!"},
]

## Kanayan hedefe bu yeteneklerle vurmak ek hasar verir.
const BLEED_BONUS := {"mortal": 1.25, "execute": 1.2, "strike": 1.1}

## {"mult": float, "text": String} döner; kombo yoksa mult = 1.0 ve text = "".
static func bonus(last_kind: String, since: float, kind: String, target_bleeding: bool) -> Dictionary:
	var mult := 1.0
	var text := ""
	for c in CHAINS:
		if c["from"] == last_kind and c["to"] == kind and since <= float(c["window"]):
			mult *= float(c["mult"])
			text = str(c["text"])
			break
	if target_bleeding and BLEED_BONUS.has(kind):
		mult *= float(BLEED_BONUS[kind])
		if text == "":
			text = "Kanayan Hedef!"
	return {"mult": mult, "text": text}
