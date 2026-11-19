extends RefCounted
## Meslekler, itibar ve başarımlar: veri tabloları ve saf yardımcılar.

const SKILL_MAX := 75

const PROFS := {
	"mine": {"name": "Madencilik", "trainer": "Madenci Başı Durin", "desc": "Maden damarlarından cevher çıkarırsın. Damara yaklaşıp G'ye bas."},
	"skin": {"name": "Deri İşleme", "trainer": "Avcı Başı Ragna", "desc": "Avladığın hayvanlardan ham deri alır, deriyi işlersin."},
	"smith": {"name": "Demircilik", "trainer": "Demirci Borga", "desc": "Cevher ve deriden silah ve zırh dökersin. Demirkazan içinde üretilir."},
}

## prof: hangi meslek üretir, skill: gereken seviye, mats: malzemeler
const RECIPES := [
	{"id": "r_cure", "prof": "skin", "name": "İşlenmiş Deri", "skill": 1, "mats": {"hide_raw": 2}, "out": "hide_cured", "n": 1},
	{"id": "r_cloak", "prof": "skin", "name": "Avcı Pelerini", "skill": 15, "mats": {"hide_cured": 4}, "out": "bk_hunter", "n": 1},
	{"id": "r_belt", "prof": "skin", "name": "Sağlam Savaş Kemeri", "skill": 40, "mats": {"hide_cured": 5, "bar_iron": 2}, "out": "wt_craft", "n": 1},
	{"id": "r_bar1", "prof": "smith", "name": "Demir Külçe", "skill": 1, "mats": {"ore_iron": 2}, "out": "bar_iron", "n": 1},
	{"id": "r_bar2", "prof": "smith", "name": "Kara Demir Külçe", "skill": 20, "mats": {"ore_dark": 2}, "out": "bar_dark", "n": 1},
	{"id": "r_axe1", "prof": "smith", "name": "Cüce Savaş Baltası", "skill": 10, "mats": {"bar_iron": 4, "hide_cured": 1}, "out": "axe_craft1", "n": 1},
	{"id": "r_ch1", "prof": "smith", "name": "Dövme Demir Göğüslük", "skill": 25, "mats": {"bar_iron": 6, "hide_cured": 2}, "out": "ch_craft1", "n": 1},
	{"id": "r_ch2", "prof": "smith", "name": "Kara Demir Göğüslük", "skill": 45, "mats": {"bar_dark": 8, "hide_cured": 3}, "out": "ch_craft2", "n": 1},
	{"id": "r_sh", "prof": "smith", "name": "Kara Demir Kalkan", "skill": 50, "mats": {"bar_dark": 6, "hide_cured": 2}, "out": "sh_craft", "n": 1},
	{"id": "r_axe2", "prof": "smith", "name": "Kara Demir Balta", "skill": 60, "mats": {"bar_dark": 6, "hide_cured": 2}, "out": "axe_craft2", "n": 1},
	{"id": "r_axe3", "prof": "smith", "name": "Büyülü Çelik Balta", "skill": 70, "mats": {"bar_dark": 4, "dust_arc": 8}, "out": "axe_craft3", "n": 1},
	{"id": "r_ch3", "prof": "smith", "name": "Büyülü Plaka Göğüslük", "skill": 75, "mats": {"bar_dark": 6, "dust_arc": 10, "ess_arc": 1}, "out": "ch_craft3", "n": 1},
]

## Maden damarı türleri
const NODES := {
	"iron": {"name": "Demir Damarı", "item": "ore_iron", "skill": 1, "cap": 45, "col": Color("a8744a"), "glow": Color("ff9a4a")},
	"dark": {"name": "Kara Demir Damarı", "item": "ore_dark", "skill": 20, "cap": 75, "col": Color("5a4a6a"), "glow": Color("b06aff")},
}

const FACTIONS := {
	"dem": {"name": "Demirkazan Kalesi", "col": Color("6aa0ff")},
	"kar": {"name": "Bataklık Karakolu", "col": Color("8ad06a")},
	"mad": {"name": "Maden Loncası", "col": Color("ffb04a")},
	"kul": {"name": "Kül Nöbetçileri", "col": Color("ff7a4a")},
}

## [ad, gereken itibar]
const RANKS := [["Yabancı", 0], ["Tanıdık", 500], ["Dost", 1500], ["Saygın", 3500], ["Onurlu", 6500], ["Yüce", 10000]]
const DISCOUNT := [0.0, 0.0, 0.05, 0.10, 0.15, 0.20]

## Satıcı hangi grubun
const VENDOR_FACTION := {"fenn": "kar", "hilda": "dem", "borga": "dem", "rolf": "kul"}

## stat: sayaç anahtarı; özel anahtarlar main.gd içinde ach_value() ile çözülür
const ACHS := [
	{"id": "a_first", "name": "İlk Kan", "desc": "Bir düşman öldür.", "stat": "kills", "goal": 1, "pts": 5},
	{"id": "a_50", "name": "Avcı", "desc": "50 düşman öldür.", "stat": "kills", "goal": 50, "pts": 10},
	{"id": "a_250", "name": "Kıyıcı", "desc": "250 düşman öldür.", "stat": "kills", "goal": 250, "pts": 15},
	{"id": "a_l10", "name": "Dağın Kahramanı", "desc": "Seviye 10'a ulaş.", "stat": "level", "goal": 10, "pts": 10},
	{"id": "a_l20", "name": "Zirvede", "desc": "Seviye 20'ye ulaş.", "stat": "level", "goal": 20, "pts": 25},
	{"id": "a_arc", "name": "Ayı Avcısı", "desc": "Büyük Baba Arctikus'u devir.", "stat": "boss_arctikus", "goal": 1, "pts": 10},
	{"id": "a_grik", "name": "Soğuk Reis", "desc": "Grik'nir the Cold'u devir.", "stat": "boss_grik", "goal": 1, "pts": 10},
	{"id": "a_chok", "name": "Ogre Yıkıcı", "desc": "Chok'sul'u devir.", "stat": "boss_choksul", "goal": 1, "pts": 10},
	{"id": "a_hog", "name": "Gnoll Elebaşı", "desc": "Hogger'ı devir.", "stat": "boss_hogger", "goal": 1, "pts": 10},
	{"id": "a_vc", "name": "Defias Reisi", "desc": "Edwin VanCleef'i devir.", "stat": "boss_vancleef", "goal": 1, "pts": 10},
	{"id": "a_rag", "name": "Ateşi Söndüren", "desc": "Ragnaros'u devir.", "stat": "boss_ragnaros", "goal": 1, "pts": 25},
	{"id": "a_gruff", "name": "Bataklık Efendisi", "desc": "Gruff Swiftbite'ı devir.", "stat": "boss_gruff", "goal": 1, "pts": 15},
	{"id": "a_gor", "name": "Taşı Kıran", "desc": "Gorduk Taşyürek'i devir.", "stat": "boss_gorduk", "goal": 1, "pts": 15},
	{"id": "a_vur", "name": "Maden Lordu", "desc": "Vurgan'ı devir.", "stat": "boss_vurgan", "goal": 1, "pts": 25},
	{"id": "a_gol", "name": "Çekirdek Kıran", "desc": "Golemagg'ı devir.", "stat": "boss_golemagg", "goal": 1, "pts": 15},
	{"id": "a_ged", "name": "Baronu Söndüren", "desc": "Baron Geddon'u devir.", "stat": "boss_geddon", "goal": 1, "pts": 20},
	{"id": "a_sul", "name": "Kül Lordu", "desc": "Sulfuron'u devir.", "stat": "boss_sulfuron", "goal": 1, "pts": 25},
	{"id": "a_boss9", "name": "Efsane Avcısı", "desc": "On üç bossun hepsini devir.", "stat": "bosses", "goal": 13, "pts": 30},
	{"id": "a_q5", "name": "Görev İnsanı", "desc": "5 görev tamamla.", "stat": "quests", "goal": 5, "pts": 10},
	{"id": "a_qall", "name": "Her İşin Ustası", "desc": "Bütün görevleri tamamla.", "stat": "quests_all", "goal": 1, "pts": 25},
	{"id": "a_rich", "name": "Zengin Cüce", "desc": "Çantanda 5 altın biriktir.", "stat": "money", "goal": 50000, "pts": 10},
	{"id": "a_ore", "name": "Cevher Avcısı", "desc": "25 maden damarı topla.", "stat": "ore", "goal": 25, "pts": 10},
	{"id": "a_skin", "name": "Deri Tüccarı", "desc": "20 ham deri topla.", "stat": "skinned", "goal": 20, "pts": 10},
	{"id": "a_craft1", "name": "Çırak Demirci", "desc": "İlk eşyanı üret.", "stat": "crafts", "goal": 1, "pts": 5},
	{"id": "a_craft15", "name": "Usta Demirci", "desc": "15 eşya üret.", "stat": "crafts", "goal": 15, "pts": 15},
	{"id": "a_profs", "name": "Çok Yönlü", "desc": "Üç mesleği de öğren.", "stat": "profs", "goal": 3, "pts": 10},
	{"id": "a_skill", "name": "Meslek Ustası", "desc": "Bir mesleği 75'e çıkar.", "stat": "skill_max", "goal": 75, "pts": 20},
	{"id": "a_friend", "name": "Her Yerde Dost", "desc": "Üç grupta da Dost ol.", "stat": "rep_friend", "goal": 3, "pts": 15},
	{"id": "a_exalt", "name": "Yüce Dost", "desc": "Bir grupla Yüce itibara ulaş.", "stat": "rep_exalted", "goal": 1, "pts": 25},
	{"id": "a_die10", "name": "Düşen Kalkar", "desc": "10 kez öl ve yine kalk.", "stat": "deaths", "goal": 10, "pts": 5},
]

static func rank_of(rep: int) -> int:
	var r := 0
	for i in RANKS.size():
		if rep >= int(RANKS[i][1]):
			r = i
	return r

static func skill_rank(skill: int) -> String:
	if skill >= 50:
		return "Usta"
	if skill >= 25:
		return "Kalfa"
	return "Çırak"

static func recipe(id: String) -> Dictionary:
	for r in RECIPES:
		if r["id"] == id:
			return r
	return {}

static func faction_of_quest(qid: String, swamp_ids: Array) -> String:
	if qid.begins_with("q_mine"):
		return "mad"
	if qid.begins_with("q_ash"):
		return "kul"
	if swamp_ids.has(qid):
		return "kar"
	return "dem"
