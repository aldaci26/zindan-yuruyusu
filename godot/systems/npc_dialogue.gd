extends RefCounted
## NPC memory and contextual dialogue helpers, independent from presentation UI.

static func memory_entry(memory: Dictionary, npc_id: String) -> Dictionary:
	var entry = memory.get(npc_id, {})
	return entry.duplicate(true) if typeof(entry) == TYPE_DICTIONARY else {}

static func record_interaction(memory: Dictionary, npc_id: String, world_time: float) -> Dictionary:
	var result := memory.duplicate(true)
	var entry := memory_entry(result, npc_id)
	entry["interactions"] = clampi(int(entry.get("interactions", 0)) + 1, 0, 1000000)
	entry["last_seen"] = maxf(0.0, world_time)
	result[npc_id] = entry
	return result

static func greeting(npc_name: String, interactions: int, reputation: int) -> String:
	if interactions <= 1:
		return "%s seni ilk kez görüyor." % npc_name
	if reputation >= 3500:
		return "Tekrar hoş geldin, dostum. %s sana güveniyor." % npc_name
	if interactions >= 5:
		return "Yine karşılaştık. %s yaptıklarını hatırlıyor; sana %s gözüyle bakıyor." % [npc_name, reputation_tone(reputation)]
	return "%s seni hatırlıyor. Sana %s gözüyle bakıyor." % [npc_name, reputation_tone(reputation)]

static func reputation_tone(reputation: int) -> String:
	if reputation >= 6500:
		return "onurlu"
	if reputation >= 1500:
		return "dost"
	if reputation >= 500:
		return "tanıdık"
	return "yabancı"

static func remember_topic(memory: Dictionary, npc_id: String, topic: String, world_time: float) -> Dictionary:
	var result := memory.duplicate(true)
	var entry := memory_entry(result, npc_id)
	var topics: Dictionary = entry.get("topics", {}) if typeof(entry.get("topics", {})) == TYPE_DICTIONARY else {}
	topics[topic] = maxi(1, int(topics.get(topic, 0)) + 1)
	entry["topics"] = topics
	entry["last_topic"] = topic
	entry["last_seen"] = maxf(0.0, world_time)
	entry["rapport"] = clampi(int(entry.get("rapport", 0)) + 1, 0, 1000)
	result[npc_id] = entry
	return result

static func topic_response(npc_name: String, topic: String, map_name: String, repeat_count: int = 0) -> String:
	var responses := {
		"rumors": {
			"snow": "Köylüler kuzey geçidinde eski bir ganimet saklandığını söylüyor.",
			"swamp": "Bataklıkta sis çöktüğünde Murloc ayinleri yeniden başlıyor.",
			"mine": "Madende derinlere indikçe Kara Demir muhafızları çoğalıyor.",
			"ash": "Lav havuzlarının yanında Golemagg'ın çekirdek köpekleri dolaşıyor, dikkat et."
		},
		"danger": {
			"snow": "Trogglar doğuda, Gnollar güneydoğuda pusu kuruyor. Hazırlıksız gitme.",
			"swamp": "Şamanları önce durdur; diğer Murlocları güçlendiriyorlar.",
			"mine": "Dar koridorlarda geri çekilme alanı bırak. Golemler ağır ama çok sert vurur.",
			"ash": "Baron Geddon'a yaklaşma; cehennem halkası yakınındakileri yakar. Yaşayan Bomba üstündeyken uzaklaş."
		}
	}
	var line: String = responses.get(topic, {}).get(map_name, "Bu bölge hakkında şimdilik bildiğim başka bir şey yok.")
	if repeat_count > 0:
		line += " Daha önce de konuşmuştuk."
	return "%s: %s" % [npc_name, line]

static func topic_count(memory: Dictionary, npc_id: String, topic: String) -> int:
	var entry := memory_entry(memory, npc_id)
	var topics = entry.get("topics", {})
	return maxi(0, int(topics.get(topic, 0))) if typeof(topics) == TYPE_DICTIONARY else 0
