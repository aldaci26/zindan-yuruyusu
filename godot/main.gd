extends Node3D
## Cüce Savaşçı: ana sahne. Tüm dünya kodla kurulur.

const Dwarf = preload("res://dwarf.gd")
const WowAssets = preload("res://wow_asset_runtime.gd")
const Tex = preload("res://tex.gd")
const HudScript = preload("res://hud.gd")
const SfxScript = preload("res://sfx.gd")
const Items = preload("res://items.gd")
const Inv = preload("res://inv.gd")
const MMBridge = preload("res://mmorpg/mmorpg_bridge.gd")
const WorldDressing = preload("res://systems/world_dressing.gd")
const Interiors = preload("res://systems/interiors.gd")
const Combos = preload("res://systems/combos.gd")
const SaveManager = preload("res://systems/save_manager.gd")
const CombatRules = preload("res://systems/combat_rules.gd")
const SpawnDirector = preload("res://systems/spawn_director.gd")
const NavSteer = preload("res://systems/navigation_steering.gd")
const NPCDialogue = preload("res://systems/npc_dialogue.gd")
const InvUI = preload("res://invui.gd")
const TalentUI = preload("res://talentui.gd")
const ProgUI = preload("res://progui.gd")
const Skills = preload("res://systems/skills.gd")
const Journal = preload("res://systems/journal.gd")
const Shouts = preload("res://systems/shouts.gd")
const DialogueTrees = preload("res://systems/dialogue_trees.gd")
const Prog = preload("res://prog.gd")
const SWAMP_QS := ["q_murloc", "q_shaman", "q_croc", "q_bog", "q_gruff"]
const BEASTS := ["Kurt", "Yaban Domuzu", "Dağ Ayısı", "Timsah", "Mağara Örümceği"]

const WORLD_R := 92.0
const CITY := {"x": 0.0, "z": -58.0, "r": 24.0, "y": 3.0}

const MTYPES := {
	"wolf": {"name": "Kurt", "lo": 1, "hi": 3, "hp": 26.0, "dmg": 2.2, "spd": 4.6, "aggro": 9.0, "rad": 0.7, "sc": 1.0},
	"boar": {"name": "Yaban Domuzu", "lo": 2, "hi": 4, "hp": 34.0, "dmg": 2.4, "spd": 3.8, "aggro": 7.0, "rad": 0.8, "sc": 1.0},
	"bear": {"name": "Dağ Ayısı", "lo": 4, "hi": 6, "hp": 46.0, "dmg": 2.8, "spd": 3.6, "aggro": 8.0, "rad": 1.1, "sc": 1.15},
	"trogg": {"name": "Trogg", "lo": 3, "hi": 6, "hp": 36.0, "dmg": 2.5, "spd": 3.6, "aggro": 8.0, "rad": 0.8, "sc": 1.15},
	"gnoll": {"name": "Gnoll", "lo": 4, "hi": 7, "hp": 38.0, "dmg": 2.7, "spd": 4.0, "aggro": 9.0, "rad": 0.7, "sc": 1.05},
	"defias": {"name": "Defias Haydudu", "lo": 6, "hi": 8, "hp": 40.0, "dmg": 2.8, "spd": 4.0, "aggro": 9.0, "rad": 0.7, "sc": 1.0},
	"darkiron": {"name": "Kara Demir Büyücüsü", "lo": 7, "hi": 9, "hp": 34.0, "dmg": 2.6, "spd": 3.4, "aggro": 13.0, "rad": 0.7, "sc": 1.05, "ranged": 12.0},
	"frost": {"name": "Kar Elementali", "lo": 5, "hi": 8, "hp": 44.0, "dmg": 2.6, "spd": 3.3, "aggro": 11.0, "rad": 0.8, "sc": 1.1, "ranged": 10.0},
	"skeleton": {"name": "Gezgin İskelet", "lo": 6, "hi": 9, "hp": 42.0, "dmg": 2.8, "spd": 3.9, "aggro": 9.0, "rad": 0.7, "sc": 1.0},
}

## Düşman kampları: tür, merkez, sayı
const CAMPS := [
	{"kind": "trogg", "x": 70.0, "z": 12.0, "n": 6},
	{"kind": "gnoll", "x": 58.0, "z": -22.0, "n": 6},
	{"kind": "defias", "x": -30.0, "z": 62.0, "n": 6},
	{"kind": "darkiron", "x": -78.0, "z": 8.0, "n": 5},
	{"kind": "frost", "x": 62.0, "z": 52.0, "n": 5},
	{"kind": "skeleton", "x": -58.0, "z": -22.0, "n": 5},
]

const MAX_LVL := 20

## Yetenek ağacı. tree: 0 Silahlar, 1 Öfke, 2 Koruma. row: sıra (daldan 2*row puan gerekir). v: rütbe başına değer.
const TALENTS := [
	{"id": "arm_dmg", "tree": 0, "row": 0, "name": "Keskin Savruluş", "max": 5, "v": 3, "icon": "strike", "fmt": "Saldırı gücü %%%d artar."},
	{"id": "arm_crit", "tree": 0, "row": 1, "name": "Ölümcül Hedef", "max": 3, "v": 2, "icon": "mortal", "fmt": "Kritik vuruş şansı %%%d artar."},
	{"id": "arm_rend", "tree": 0, "row": 2, "name": "Derin Yaralar", "max": 2, "v": 25, "icon": "rend", "fmt": "Yaralama hasarı %%%d artar."},
	{"id": "arm_exec", "tree": 0, "row": 3, "name": "Cellat", "max": 2, "v": 20, "icon": "execute", "fmt": "İnfaz hasarı %%%d artar."},
	{"id": "fur_rage", "tree": 1, "row": 0, "name": "Öfke Seli", "max": 3, "v": 10, "icon": "shout", "fmt": "Kazandığın öfke %%%d artar."},
	{"id": "fur_speed", "tree": 1, "row": 1, "name": "Ani Hamleler", "max": 5, "v": 4, "icon": "charge", "fmt": "Otomatik saldırı %%%d hızlanır."},
	{"id": "fur_cleave", "tree": 1, "row": 2, "name": "Biçici", "max": 3, "v": 10, "icon": "whirl", "fmt": "Alan hasarı (Gök Gürültüsü, Kasırga, Kılıç Fırtınası) %%%d artar."},
	{"id": "fur_reck", "tree": 1, "row": 3, "name": "Kızıl Sis", "max": 2, "v": 10, "icon": "reck", "fmt": "Delice Öfke bekleme süresi %d sn kısalır."},
	{"id": "pro_hp", "tree": 2, "row": 0, "name": "Demir Beden", "max": 5, "v": 3, "icon": "laststand", "fmt": "En yüksek can %%%d artar."},
	{"id": "pro_armor", "tree": 2, "row": 1, "name": "Katman Katman", "max": 5, "v": 5, "icon": "shield", "fmt": "Zırh %%%d artar."},
	{"id": "pro_shield", "tree": 2, "row": 2, "name": "Kalkan Ustası", "max": 3, "v": 1, "icon": "slam", "fmt": "Kalkan Bloğu %d sn daha uzun sürer."},
	{"id": "pro_dr", "tree": 2, "row": 3, "name": "Dağ Gibi", "max": 3, "v": 2, "icon": "clap", "fmt": "Aldığın hasar %%%d azalır."},
]

const SWAMP_MTYPES := {
	"murloc": {"name": "Murloc", "lo": 8, "hi": 11, "hp": 40.0, "dmg": 2.8, "spd": 4.2, "aggro": 9.0, "rad": 0.6, "sc": 1.05},
	"shaman": {"name": "Murloc Şamanı", "lo": 10, "hi": 12, "hp": 34.0, "dmg": 2.7, "spd": 3.4, "aggro": 13.0, "rad": 0.6, "sc": 1.05, "ranged": 12.0},
	"croc": {"name": "Timsah", "lo": 9, "hi": 12, "hp": 52.0, "dmg": 3.0, "spd": 3.9, "aggro": 8.0, "rad": 1.0, "sc": 1.15},
	"bog": {"name": "Bataklık Canavarı", "lo": 11, "hi": 13, "hp": 64.0, "dmg": 3.2, "spd": 3.2, "aggro": 8.0, "rad": 1.0, "sc": 1.2},
}

const SWAMP_CAMPS := [
	{"kind": "murloc", "x": -56.0, "z": 26.0, "n": 7},
	{"kind": "shaman", "x": 52.0, "z": -30.0, "n": 5},
	{"kind": "murloc", "x": 42.0, "z": 56.0, "n": 6},
	{"kind": "bog", "x": -46.0, "z": -44.0, "n": 4},
]

## Kara Demir Madeni: odalar [x, z, yarıçap], yan odalar [x, z, yarıçap, bağlı oda]
const MINE_ROOMS := [[0.0, 79.0, 9.0], [-8.0, 48.0, 14.0], [8.0, 11.0, 15.0], [-8.0, -26.0, 14.0], [0.0, -68.0, 20.0], [16.0, -98.0, 9.0], [16.0, -128.0, 15.0], [-6.0, -158.0, 19.0]]  # son üçü Kara Demir Zindanı
const MINE_ALC := [[-26.0, 48.0, 5.0, 1], [26.0, 11.0, 5.0, 2], [-30.0, -26.0, 5.0, 3]]
const MINE_MTYPES := {
	"miner": {"name": "Kara Demir Madencisi", "lo": 12, "hi": 13, "hp": 70.0, "dmg": 3.2, "spd": 3.6, "aggro": 9.0, "rad": 0.6, "sc": 1.0},
	"spider": {"name": "Mağara Örümceği", "lo": 12, "hi": 14, "hp": 55.0, "dmg": 3.0, "spd": 4.6, "aggro": 10.0, "rad": 0.7, "sc": 1.15},
	"golem": {"name": "Taş Golem", "lo": 13, "hi": 14, "hp": 100.0, "dmg": 3.4, "spd": 2.6, "aggro": 7.0, "rad": 1.0, "sc": 1.3},
	"guard": {"name": "Kara Demir Muhafızı", "lo": 14, "hi": 15, "hp": 90.0, "dmg": 3.6, "spd": 3.4, "aggro": 9.0, "rad": 0.7, "sc": 1.1},
	"ironclad": {"name": "Kara Demir Zindan Muhafızı", "lo": 17, "hi": 19, "hp": 130.0, "dmg": 4.0, "spd": 3.2, "aggro": 10.0, "rad": 0.75, "sc": 1.15},
}
const MINE_CAMPS := [
	{"kind": "miner", "x": -8.0, "z": 48.0, "n": 5, "sp": 9.0},
	{"kind": "spider", "x": -8.0, "z": 48.0, "n": 3, "sp": 10.0},
	{"kind": "golem", "x": 8.0, "z": 11.0, "n": 2, "sp": 10.0},
	{"kind": "spider", "x": -8.0, "z": -26.0, "n": 4, "sp": 10.0},
	{"kind": "miner", "x": -8.0, "z": -26.0, "n": 3, "sp": 9.0},
	{"kind": "guard", "x": -8.0, "z": -26.0, "n": 2, "sp": 8.0},
	{"kind": "guard", "x": 0.0, "z": -58.0, "n": 2, "sp": 6.0},
	# Kara Demir Zindanı: madenin güneyindeki mühürlü koridorların ardında
	{"kind": "ironclad", "x": 16.0, "z": -98.0, "n": 4, "sp": 8.0},
	{"kind": "ironclad", "x": 16.0, "z": -128.0, "n": 3, "sp": 10.0},
]

## Kül Diyarı (Sv 14-20): lav havuzları [x, z, yarıçap]
const ASH_POOLS := [[-30.0, -10.0, 6.0], [34.0, 12.0, 7.0], [8.0, -42.0, 8.0], [-54.0, -34.0, 6.0], [52.0, -52.0, 6.0], [-20.0, 52.0, 6.0], [62.0, 44.0, 5.0]]
const ASH_MTYPES := {
	"cinder": {"name": "Kül Elementali", "lo": 14, "hi": 16, "hp": 62.0, "dmg": 3.2, "spd": 3.4, "aggro": 12.0, "rad": 0.8, "sc": 1.1, "ranged": 11.0},
	"slag": {"name": "Cüruf Golemi", "lo": 15, "hi": 17, "hp": 105.0, "dmg": 3.6, "spd": 2.6, "aggro": 7.0, "rad": 1.0, "sc": 1.3},
	"ashogre": {"name": "Kül Ogresi", "lo": 16, "hi": 18, "hp": 95.0, "dmg": 3.8, "spd": 3.2, "aggro": 9.0, "rad": 1.0, "sc": 0.85},
	"ashbone": {"name": "Yanık İskelet", "lo": 15, "hi": 18, "hp": 70.0, "dmg": 3.4, "spd": 4.0, "aggro": 10.0, "rad": 0.7, "sc": 1.05},
}
const ASH_CAMPS := [
	{"kind": "cinder", "x": -50.0, "z": 30.0, "n": 6, "sp": 9.0},
	{"kind": "slag", "x": 50.0, "z": -34.0, "n": 4, "sp": 9.0},
	{"kind": "ashogre", "x": 40.0, "z": 52.0, "n": 5, "sp": 9.0},
	{"kind": "ashbone", "x": -44.0, "z": -46.0, "n": 5, "sp": 9.0},
	{"kind": "cinder", "x": 4.0, "z": 66.0, "n": 4, "sp": 8.0},
]
const ASH_NPCS := [
	{"id": "torga", "name": "Nöbetçi Torga", "title": "Kül Nöbetçisi", "role": "quest", "qs": ["q_ash1", "q_ash2", "q_ash3", "q_ash4"], "x": -5.0, "z": 5.0, "face": 0.6,
		"o": {"beard": Color("8a3a22"), "cloth": Color("5a2a22"), "metal": Color("6a6068"), "helm": true, "prop": "axe"}},
	{"id": "zeyra", "name": "Kor Avcısı Zeyra", "title": "Alev Avcısı", "role": "quest", "qs": ["q_ash5", "q_ash6", "q_ash7"], "x": 6.0, "z": 4.0, "face": -0.5,
		"o": {"beard": Color("b8501a"), "cloth": Color("3a2a22"), "metal": Color("8a6a4a"), "helm": false, "prop": "spear"}},
	{"id": "rolf", "name": "Tüccar Rolf", "title": "Tüccar", "role": "vendor", "x": 0.0, "z": -7.0, "face": 0.0,
		"o": {"beard": Color("d8a04a"), "cloth": Color("6a3a22"), "metal": Color("b09060"), "helm": false, "prop": "none"}},
]

const SWAMP_NPCS := [
	{"id": "muck", "name": "Bekçi Muck", "title": "Karakol Komutanı", "role": "quest", "qs": ["q_murloc", "q_shaman", "q_croc"], "x": -5.0, "z": 5.0, "face": 0.6,
		"o": {"beard": Color("6a4a2a"), "cloth": Color("3a5a2a"), "metal": Color("7a8070"), "helm": true, "prop": "spear"}},
	{"id": "brenna", "name": "Kaşif Brenna", "title": "Bataklık Avcısı", "role": "quest", "qs": ["q_bog", "q_gruff"], "x": 6.0, "z": 4.0, "face": -0.5,
		"o": {"beard": Color("c46a2a"), "cloth": Color("5a3a22"), "metal": Color("8a7a5a"), "helm": false, "prop": "axe"}},
	{"id": "fenn", "name": "Tüccar Fenn", "title": "Tüccar", "role": "vendor", "x": 0.0, "z": -7.0, "face": 0.0,
		"o": {"beard": Color("dbb46a"), "cloth": Color("2f6a6a"), "metal": Color("b09060"), "helm": false, "prop": "none"}},
]

const QUESTS := {
	"q_murloc": {"title": "Murloc Akını", "kill": "Murloc", "n": 6, "lvl": 8, "xp": 700, "money": 2600, "rew": ["ch_marsh", "hd_marsh", "ft_marsh"],
		"text": "Murlocalar karakolun balık göllerini bastı. Altı tanesini temizle.", "done": "Göller sakinleşti. Al, hak ettin."},
	"q_shaman": {"title": "Şaman Ayini", "kill": "Murloc Şamanı", "n": 4, "lvl": 8, "xp": 760, "money": 2800, "rew": ["helm_marsh", "nk_marsh", "rg_marsh"],
		"text": "Murloc şamanları doğuda kara bir ayin yapıyor. Dördünü durdur.", "done": "Ayin bozuldu! İşte ödülün."},
	"q_croc": {"title": "Timsah Avı", "kill": "Timsah", "n": 5, "lvl": 8, "xp": 740, "money": 2700, "rew": ["lg_marsh", "sh_marsh", "wt_marsh"],
		"text": "Timsahlar kervan yolunu kapatıyor. Beşini avla.", "done": "Yol açıldı. Seç bakalım."},
	"q_bog": {"title": "Bataklığın Bekçileri", "kill": "Bataklık Canavarı", "n": 4, "lvl": 10, "xp": 900, "money": 3200, "rew": ["axe_marsh", "ch_marsh", "ft_marsh"],
		"text": "Yosunlu devler gölün kıyısında dolaşıyor. Dördünü yık.", "done": "Devler yıkıldı. Ödülünü al."},
	"q_gruff": {"title": "Gruff Swiftbite", "kill": "Gruff Swiftbite", "n": 1, "lvl": 12, "xp": 1300, "money": 5000, "rew": ["axe_gruff", "bk_gruff", "tr_gruff"],
		"text": "Dev timsah Gruff Swiftbite gölün dibinden çıkıp köyleri yutuyor. Onu bitir.", "done": "Gruff devrildi! Bataklık sana minnettar."},
	"q_trogg": {"title": "Trogg Tehdidi", "kill": "Trogg", "n": 5, "lvl": 3, "xp": 220, "money": 600, "rew": ["sh_gate", "wt_iron", "axe_forge"],
		"text": "Doğudaki trogglar sürülerimize saldırıyor. Beş tanesini temizle.", "done": "Doğu yolu rahatladı. Al, hak ettin."},
	"q_grik": {"title": "Soğuğun Reisi", "kill": "Grik'nir the Cold", "n": 1, "lvl": 5, "xp": 400, "money": 1200, "rew": ["ch_mail", "hd_iron", "rg_sig"],
		"text": "Trogg reisi Grik'nir the Cold buzdan bir kale kurdu. Onu devir, sürüsü dağılır.", "done": "Soğuk reis düştü! Ödülünü seç."},
	"q_arc": {"title": "Kar Dağının Efendisi", "kill": "Büyük Baba Arctikus", "n": 1, "lvl": 5, "xp": 500, "money": 1500, "rew": ["helm_ward", "nk_rune", "ft_iron"],
		"text": "Batı ormanında Büyük Baba Arctikus diye bir dev ayı dolaşıyor. Güçlü bir savaşçı olmadan yaklaşma.", "done": "Arctikus'u yendin! Efsane olacaksın."},
	"q_gnoll": {"title": "Gnoll Sürüsü", "kill": "Gnoll", "n": 5, "lvl": 4, "xp": 260, "money": 700, "rew": ["so_boar", "rg_iron", "sh_rein"],
		"text": "Gnolllar doğu-güney yolunu tutmuş, kervanları soyuyorlar. Beşini avla.", "done": "Yollar yine güvenli. İşte ödülün."},
	"q_chok": {"title": "Ogre Savaş Başı", "kill": "Chok'sul", "n": 1, "lvl": 6, "xp": 500, "money": 1600, "rew": ["axe_deepf", "so_peak", "wt_rune"],
		"text": "Ogre Chok'sul batıda köylere ezip geçiyor. Onu durdur.", "done": "Ogre devrildi. Seç bakalım."},
	"q_hogger": {"title": "Hogger'ı Avla", "kill": "Hogger", "n": 1, "lvl": 7, "xp": 650, "money": 2200, "rew": ["lg_plate", "wr_rune", "tr_horn"],
		"text": "Gnoll elebaşı Hogger doğuda küçük bir ordu topladı. Başını getir.", "done": "Hogger'ı yendin! Bu ödülü hak ettin."},
	"q_defias": {"title": "Defias Haydutları", "kill": "Defias Haydudu", "n": 5, "lvl": 6, "xp": 420, "money": 1300, "rew": ["ch_plate", "hd_deep", "tr_horn"],
		"text": "Güneybatıda Defias haydutları sığınak kurmuş. Beşini temizle.", "done": "Haydutlar dağıldı. Şu eşyalardan birini al."},
	"q_dark": {"title": "Kara Demir Büyücüleri", "kill": "Kara Demir Büyücüsü", "n": 5, "lvl": 7, "xp": 520, "money": 1800, "rew": ["ft_deep", "axe_storm", "nk_gold"],
		"text": "Kara Demir büyücüleri batıda ateş büyüleri deniyor. Beşini yok et, ama uzaktan vururlar, yaklaş.", "done": "Büyücüler yok oldu. Ödülünü seç."},
	"q_vc": {"title": "Defias Elebaşı", "kill": "Edwin VanCleef", "n": 1, "lvl": 8, "xp": 800, "money": 3000, "rew": ["sh_deep", "rg_ruby", "ch_deep"],
		"text": "Edwin VanCleef güneybatıdaki Defias sığınağının reisi. Onu alt et.", "done": "VanCleef öldü! Büyük zafer."},
	"q_rag": {"title": "Ateşin Efendisi", "kill": "Ragnaros", "n": 1, "lvl": 10, "xp": 1500, "money": 8000, "rew": ["helm_king", "rg_king", "tr_eye"],
		"text": "Demirkazan'ın büyük ocağında Ateş Efendisi Ragnaros uyuyor. Onu uyandırıp yen. Çok iyi donan.", "done": "Ragnaros devrildi! Krallar bile bunu başaramadı."},

	"q_mine1": {"title": "Madenci Kâbusu", "kill": "Kara Demir Madencisi", "n": 6, "lvl": 12, "xp": 1100, "money": 4200, "rew": ["ch_mine", "lg_mine", "helm_mine"],
		"text": "Kara Demir madencileri eski madenimizi ele geçirdi. Portaldan gir, altısını temizle.", "done": "Maden nefes aldı. Zırhlardan birini seç."},
	"q_mine2": {"title": "Taşın Yüreği", "kill": "Gorduk Taşyürek", "n": 1, "lvl": 13, "xp": 1500, "money": 6000, "rew": ["hd_mine", "sh_mine", "axe_mine"],
		"text": "Madenin ortasında Gorduk Taşyürek adında bir granit dev duruyor. Yerinden oynat.", "done": "Gorduk yıkıldı! Bu ödül senin."},
	"q_mine3": {"title": "Maden Lordu", "kill": "Vurgan", "n": 1, "lvl": 15, "xp": 2400, "money": 9500, "rew": ["tr_vurgan", "helm_vurgan", "ch_vurgan"],
		"text": "Madenin en dibinde Maden Lordu Vurgan oturuyor. Onu devirmeden Demirkazan rahat edemez.", "done": "Vurgan düştü! Madenin lordu artık sensin."},
	"q_dungeon1": {"title": "Zindanın Gardiyanı", "kill": "Kezan Kırgazık", "n": 1, "lvl": 18, "xp": 3800, "money": 13000, "rew": ["hd_kezan", "wt_kezan", "rg_dungeon1"],
		"text": "Kara Demir Zindanı'nın girişinde Zindan Gardiyanı Kezan Kırgazık nöbet tutuyor. Onu geçmeden derinliklere inilemez.", "done": "Kezan düştü. Zindanın yolu açık."},
	"q_dungeon2": {"title": "Kara Demir İmparatoru", "kill": "Lord Modrek Karataş", "n": 1, "lvl": 20, "xp": 6500, "money": 24000, "rew": ["nk_modrek", "sh_modrek", "rg_modrek"],
		"text": "Zindanın en derininde Lord Modrek Karataş tahtında oturuyor. Onu devir, Kara Demir Zindanı'nı özgürleştir.", "done": "Lord Modrek düştü! Kara Demir Zindanı artık özgür."},
	"q_ash1": {"title": "Kül Yağmurunun Çocukları", "kill": "Kül Elementali", "n": 6, "lvl": 14, "xp": 1700, "money": 6500, "rew": ["ch_ash", "lg_ash", "helm_ash"],
		"text": "Kül elementalleri kampın çevresinde kor saçıyor. Altısını söndür; uzaktan vururlar, yaklaş.", "done": "Kor sönüyor. Zırhlardan birini seç."},
	"q_ash2": {"title": "Cüruf Kıran", "kill": "Cüruf Golemi", "n": 5, "lvl": 15, "xp": 1900, "money": 7000, "rew": ["hd_ash", "sh_ash", "axe_ash"],
		"text": "Cüruf golemleri lav havuzlarından yürüyüp kampa yaklaşıyor. Beşini parçala.", "done": "Taşlar dağıldı. Ödülünü al."},
	"q_ash3": {"title": "Ogre Ocağı", "kill": "Kül Ogresi", "n": 5, "lvl": 16, "xp": 2100, "money": 7600, "rew": ["ft_ash", "wt_ash", "nk_ash"],
		"text": "Güneydeki Kül ogreleri kervan yolunu tutmuş. Beşini devir.", "done": "Yol açıldı. Seç bakalım."},
	"q_ash4": {"title": "Yanık Nöbet", "kill": "Yanık İskelet", "n": 6, "lvl": 16, "xp": 2200, "money": 8000, "rew": ["rg_ash", "bk_ash", "hammer_ash"],
		"text": "Eski nöbetçilerimizin iskeletleri küllerin arasında yürüyor. Altısına huzur ver.", "done": "Nöbet bitti. Ödülün burada."},
	"q_ash5": {"title": "Çekirdeğin Bekçisi", "kill": "Golemagg", "n": 1, "lvl": 17, "xp": 3200, "money": 11000, "rew": ["hammer_golemagg", "lg_golemagg", "nk_golemagg"],
		"text": "Batıdaki kor ocağında Golemagg adında dev bir golem yaşıyor. Çekirdek köpekleriyle gelir; hazırlıklı git.", "done": "Golemagg yıkıldı! Bu ödül senin."},
	"q_ash6": {"title": "Baron Geddon", "kill": "Baron Geddon", "n": 1, "lvl": 18, "xp": 4200, "money": 15000, "rew": ["ch_geddon", "helm_geddon", "rg_geddon", "tr_geddon"],
		"text": "Doğu zirvesinde Baron Geddon duruyor. Yaklaşırsan etrafı cehenneme çevirir; mesafeni koru.", "done": "Baron söndü! Efsane oldun."},
	"q_ash7": {"title": "Kül Lordu", "kill": "Sulfuron", "n": 1, "lvl": 19, "xp": 6000, "money": 22000, "rew": ["axe_sulf", "sh_sulf", "bk_sulf", "tr_sulf"],
		"text": "Güneybatıda Kül Lordu Sulfuron çekici ile oturuyor. Onu devirmeden bu diyar sakinleşmez.", "done": "Sulfuron düştü! Kül Diyarı'nın efendisi artık sensin."},
	"q_wolf": {"title": "Kurt Sürüsü", "kill": "Kurt", "n": 4, "lvl": 1, "xp": 90, "money": 250, "rew": ["axe_wolf", "bk_fur", "nk_tooth"],
		"text": "Vadide kurtlar çoğaldı, sürüler köye yaklaşıyor. Dört kurdu avla, köy sana minnettar kalır.", "done": "Sürü dağıldı, teşekkürler. İşte ödülün."},
	"q_boar": {"title": "Domuz İstilası", "kill": "Yaban Domuzu", "n": 4, "lvl": 2, "xp": 170, "money": 450, "rew": ["axe_boar", "so_boar", "ft_iron"],
		"text": "Yaban domuzları kapının önündeki yolu çiğniyor. Dört tanesini durdur.", "done": "Yol yeniden güvenli. Demirkazan sana borçlu."},
	"q_bear": {"title": "Dağın Efendisi", "kill": "Dağ Ayısı", "n": 2, "lvl": 3, "xp": 340, "money": 900, "rew": ["helm_bear", "bk_bear", "sh_deep"],
		"text": "Dağ ayıları ocak ekiplerimizi korkutuyor. İki ayıyı alt et, cephaneliğimden bir şey seçersin.", "done": "Gerçek bir savaşçısın. Cephanelikten birini seç."},
}

## WoW bosları: ad, seviye, can, hasar, ganimet ve yetenekler _boss_ai içinde.
const BOSSES := {
	"arctikus": {"name": "Büyük Baba Arctikus", "title": "Kar Dağı Efendisi", "lvl": 6, "hp": 2600.0, "dmg": 24.0, "spd": 4.2, "rad": 1.7, "sc": 1.7, "aggro": 12.0,
		"x": -62.0, "z": 38.0, "model": "bear", "kind": "bear", "respawn": 300.0, "xp": 160,
		"say": "Büyük Baba Arctikus kükreyerek saldırıya geçti!", "drops": ["wt_arc", "hd_arc", "bk_arc"]},
	"grik": {"name": "Grik'nir the Cold", "title": "Trogg Reisi", "lvl": 5, "hp": 2000.0, "dmg": 19.0, "spd": 3.6, "rad": 1.0, "sc": 1.5, "aggro": 12.0,
		"x": 66.0, "z": 40.0, "model": "trogg", "kind": "skull", "respawn": 300.0, "xp": 130,
		"say": "Grik'nir: Buzzz! Donacaksınız!", "drops": ["axe_grik", "nk_grik"]},
	"choksul": {"name": "Chok'sul", "title": "Ogre Savaş Başı", "lvl": 7, "hp": 3400.0, "dmg": 30.0, "spd": 3.4, "rad": 1.4, "sc": 1.5, "aggro": 12.0,
		"x": -70.0, "z": -28.0, "model": "ogre", "kind": "skull", "respawn": 300.0, "xp": 200,
		"say": "Chok'sul: Ezin! Hepsini ezin!", "drops": ["hammer_chok", "wt_chok"]},
	"hogger": {"name": "Hogger", "title": "Gnoll Elebaşı", "lvl": 8, "hp": 4400.0, "dmg": 28.0, "spd": 4.0, "rad": 1.1, "sc": 1.6, "aggro": 12.0,
		"x": 62.0, "z": -38.0, "model": "gnoll", "kind": "skull", "respawn": 300.0, "xp": 280,
		"say": "Hogger: Grrr... Taze et! Yiiipe!", "drops": ["lg_hogger", "wr_hogger", "tr_hogger"]},
	"vancleef": {"name": "Edwin VanCleef", "title": "Defias Elebaşı", "lvl": 9, "hp": 6500.0, "dmg": 30.0, "spd": 4.4, "rad": 0.9, "sc": 1.3, "aggro": 12.0,
		"x": -40.0, "z": 70.0, "model": "vancleef", "kind": "dwarf", "respawn": 360.0, "xp": 400,
		"say": "VanCleef: Beni durduramazsınız! Muhafızlar, saldırın!", "drops": ["sword_cruel", "helm_defias", "bk_edwin", "rg_vc"]},
	"gruff": {"name": "Gruff Swiftbite", "title": "Bataklık Devi", "lvl": 14, "hp": 9000.0, "dmg": 34.0, "spd": 4.2, "rad": 1.5, "sc": 2.0, "aggro": 12.0, "map": "swamp",
		"x": -26.0, "z": -66.0, "model": "gruff", "kind": "skull", "respawn": 420.0, "xp": 600,
		"say": "Gruff Swiftbite çamurdan fırlayıp kükredi!", "drops": ["axe_gruff", "bk_gruff", "tr_gruff", "wt_gruff"]},
	"gorduk": {"name": "Gorduk Taşyürek", "title": "Granit Muhafız", "lvl": 15, "hp": 12500.0, "dmg": 40.0, "spd": 3.4, "rad": 1.7, "sc": 1.9, "aggro": 12.0, "map": "mine",
		"x": 8.0, "z": 8.0, "model": "gorduk", "kind": "skull", "respawn": 480.0, "xp": 800,
		"say": "Gorduk Taşyürek: Yer sarsılıyor... Geri dönün!", "drops": ["hammer_gorduk", "lg_gorduk", "nk_gorduk"]},
	"vurgan": {"name": "Vurgan", "title": "Kara Demir Maden Lordu", "lvl": 17, "hp": 19000.0, "dmg": 48.0, "spd": 3.8, "rad": 1.2, "sc": 1.6, "aggro": 12.0, "map": "mine",
		"x": 0.0, "z": -73.0, "model": "vurgan", "kind": "skull", "respawn": 600.0, "xp": 1400,
		"say": "Vurgan: Madenim benim! Kazın, kazın!", "drops": ["axe_vurgan", "ch_vurgan", "helm_vurgan", "tr_vurgan"]},
	"thokk": {"name": "Buzul Devi Thokk", "title": "Gezgin Dünya Canavarı", "lvl": 9, "hp": 7800.0, "dmg": 32.0, "spd": 3.8, "rad": 1.5, "sc": 2.7, "aggro": 14.0,
		"x": 72.0, "z": 8.0, "model": "thokk", "kind": "skull", "respawn": 420.0, "xp": 450,
		"say": "Thokk: Buzul uyanıyor... Donun!", "drops": ["sh_thokk", "bk_thokk"]},
	"golemagg": {"name": "Golemagg", "title": "Yakıcı", "lvl": 17, "hp": 24000.0, "dmg": 52.0, "spd": 3.4, "rad": 1.9, "sc": 2.1, "aggro": 12.0, "map": "ash",
		"x": 24.0, "z": -72.0, "model": "golemagg", "kind": "skull", "respawn": 600.0, "xp": 1800,
		"say": "Golemagg: Çekirdeğin ateşi sizi yakacak!", "drops": ["hammer_golemagg", "lg_golemagg", "nk_golemagg"]},
	"geddon": {"name": "Baron Geddon", "title": "Yanardağ Baronu", "lvl": 19, "hp": 31000.0, "dmg": 58.0, "spd": 3.8, "rad": 1.5, "sc": 2.2, "aggro": 12.0, "map": "ash",
		"x": 70.0, "z": 30.0, "model": "geddon", "kind": "skull", "respawn": 660.0, "xp": 2600,
		"say": "Baron Geddon: Ateşin gerçek gücünü göreceksiniz!", "drops": ["ch_geddon", "helm_geddon", "rg_geddon", "tr_geddon"]},
	"sulfuron": {"name": "Sulfuron", "title": "Kül Lordu", "lvl": 20, "hp": 42000.0, "dmg": 64.0, "spd": 3.6, "rad": 1.3, "sc": 1.8, "aggro": 12.0, "map": "ash",
		"x": -62.0, "z": -52.0, "model": "sulfuron", "kind": "skull", "respawn": 720.0, "xp": 3600,
		"say": "Sulfuron: Kül Diyarı benimdir! Hizmetkârlar, saldırın!", "drops": ["axe_sulf", "sh_sulf", "bk_sulf", "tr_sulf"]},
	"ragnaros": {"name": "Ragnaros", "title": "Ateş Efendisi", "lvl": 10, "hp": 24000.0, "dmg": 60.0, "spd": 0.0, "rad": 4.6, "sc": 1.0, "aggro": 0.0, "reach": 1.9, "yoff": 1.3,
		"x": 0.0, "z": -64.0, "model": "ragnaros", "kind": "skull", "respawn": 600.0, "xp": 900,
		"say": "Ragnaros: SİZİ KÜÇÜK FANİLER! ATEŞİMDE YANACAKSINIZ!", "drops": ["helm_rag", "ch_rag", "tr_core"]},
	"kezan": {"name": "Kezan Kırgazık", "title": "Zindan Gardiyanı", "lvl": 18, "hp": 21000.0, "dmg": 50.0, "spd": 3.6, "rad": 1.3, "sc": 1.65, "aggro": 12.0, "map": "mine",
		"x": 16.0, "z": -124.0, "model": "kezan", "kind": "skull", "respawn": 540.0, "xp": 1700,
		"say": "Kezan Kırgazık: Zindanın derinliklerinden kimse canlı çıkmaz!", "drops": ["axe_kezan", "so_kezan", "ft_kezan"]},
	"modrek": {"name": "Lord Modrek Karataş", "title": "Kara Demir İmparatoru", "lvl": 20, "hp": 46000.0, "dmg": 66.0, "spd": 3.5, "rad": 1.5, "sc": 1.95, "aggro": 12.0, "map": "mine",
		"x": -6.0, "z": -154.0, "model": "modrek", "kind": "skull", "respawn": 900.0, "xp": 3200,
		"say": "Lord Modrek: Bu zindan benim tahtım! Dize gelin, fanilar!", "drops": ["hammer_modrek", "ch_modrek", "helm_modrek"]},
}

const VENDORS := {
	"fenn": ["pot_heal", "pot_big", "helm_iron", "helm_ward", "ch_mail", "ch_plate", "lg_mail", "ft_iron", "hd_iron", "sh_rein", "wt_iron", "rg_iron", "nk_tooth", "axe_forge"],
	"hilda": ["pot_heal", "pot_big", "helm_cap", "helm_iron", "so_pad", "so_iron", "bk_cloak", "ch_leather", "ch_mail", "wr_cloth", "wr_iron",
		"hd_glove", "hd_iron", "wt_belt", "wt_iron", "lg_leather", "lg_mail", "ft_hide", "ft_iron", "rg_iron", "nk_tooth"],
	"rolf": ["pot_heal", "pot_big", "helm_iron", "ch_mail", "ch_plate", "lg_mail", "ft_iron", "hd_iron", "sh_rein", "wt_iron", "rg_iron", "nk_tooth", "axe_forge", "hammer_smith", "tr_whet"],
	"borga": ["axe_iron", "axe_forge", "axe_boar", "hammer_smith", "sword_gate", "sh_iron", "sh_gate", "sh_rein", "tr_whet"],
}

class Mob:
	var kind: String
	var nm: String
	var lvl: int
	var x: float
	var z: float
	var hx: float
	var hz: float
	var yaw: float
	var maxhp: float
	var hp: float
	var dmg: float
	var spd: float
	var aggro: float
	var rad: float
	var sc: float
	var state := "idle"
	var dead := false
	var died_at := 0.0
	var atk_t := 1.0
	var stun := 0.0
	var w_t := 0.0
	var wx: float
	var wz: float
	var ph := 0.0
	var lunge := 0.0
	var bleed_t := 0.0
	var bleed_tick := 0.0
	var bleed_v := 0.0
	var slow := 0.0
	var ranged := 0.0
	var loot: Array = []
	var loot_money := 0
	var fade_t := 0.0
	var sparkle: MeshInstance3D
	var boss := ""
	var title := ""
	var reach := 1.3
	var yoff := 0.0
	var temp := false
	var gc := false
	var engaged := false
	var respawn := 32.0
	var cd := {}
	var flags := {}
	var eat_t := 0.0
	var atk_int := 2.0
	var base_dmg := 0.0
	var base_spd := 0.0
	var owner_m = null
	var rare := false
	var elite := false
	var thr := 0.0
	var node: Node3D
	var legs: Array = []
	var id: int

# ---------- durum ----------
var hud
var sfx
var paused := false
var inv
const ROOM_X := 400.0  # ev iç mekânlarının kurulduğu uzak bölge
const ROOM_STEP := 14.0
var house_doors: Array = []
var disenchant_mode := false
var last_ab := ""
var last_ab_t := -99.0
var combo_mult := 1.0
var swing_style := "axe"
var dis_rng := RandomNumberGenerator.new()
var set_aura: Node3D
var set_aura_key := ""
var mm  # mmorpg köprüsü: veri tanımları + görev/çanta aynası
var invui
var talui
var progui
var res_nodes: Array = []
var wall_list: Array = []
var held = null
var G := {}
var vendor_npc = null
var vendor_tab := 0
var loot_mob = null
var next_id := 100
var save_t := 0.0
const SAVE_PATH := "user://cuce_save.json"
var npc_mem: Dictionary = {}
var dlg_extra := ""
var cam: Camera3D
var sun: DirectionalLight3D
var player: Node3D
var rig: Dictionary
var P := {}
var mobs: Array = []
var npcs: Array = []
var obs: Array = []
var qs := {}
var T := 0.0
var mode := "title"
var cam_yaw := 0.0
var cam_pitch := 0.34
var cam_dist := 8.5
var cam_dist_t := 8.5
var rmb := false
var mouse_sens := 1.0
var dlg_open := false
var cur_npc = null
var last_rest := -999.0
var zone_now := ""
var swing_t := 0.0
var walk_ph := 0.0
var snow_node: GPUParticles3D
var swamp_fx: GPUParticles3D
var map := "snow"
var portals: Array = []
var traveling := false
var portal_cd := 0.0
var camps_now: Array = CAMPS
var worldmap: Control
const WorldMap = preload("res://worldmap.gd")
const KeyUI = preload("res://keyui.gd")
var keyui: Panel
var env_res: Environment
var sky_psm: ProceduralSkyMaterial
var we_node: WorldEnvironment
var m_thatch: StandardMaterial3D
var lava_mat: StandardMaterial3D
var mine_lantern: OmniLight3D
var _mine_torch_cache: Array = []
var fire_light: OmniLight3D
var forge_light: OmniLight3D
var gate_light: OmniLight3D
var flame_nodes: Array = []
var rings: Array = []
var m_stone: StandardMaterial3D
var m_wood: StandardMaterial3D
var m_roof: StandardMaterial3D
var m_cobble: StandardMaterial3D
var m_gold: StandardMaterial3D
var m_bronze: StandardMaterial3D
var m_snow: StandardMaterial3D
var m_blue: StandardMaterial3D

# ---------- arazi gürültüsü ----------
func hash2(x: float, y: float) -> float:
	var h := sin(x * 127.1 + y * 311.7) * 43758.5453
	return h - floorf(h)

func vn(x: float, y: float) -> float:
	var xi := floorf(x)
	var yi := floorf(y)
	var xf := x - xi
	var yf := y - yi
	var u := xf * xf * (3.0 - 2.0 * xf)
	var v := yf * yf * (3.0 - 2.0 * yf)
	var a := hash2(xi, yi)
	var b := hash2(xi + 1.0, yi)
	var c := hash2(xi, yi + 1.0)
	var d := hash2(xi + 1.0, yi + 1.0)
	return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v

func _ash_h(x: float, z: float) -> float:
	var h := vn(x * 0.035 + 11.0, z * 0.035 + 3.0) * 9.0 + vn(x * 0.1, z * 0.1) * 2.2 + vn(x * 0.26, z * 0.26) * 0.5 - 2.0
	var d := sqrt(x * x + z * z)
	var flat := clampf((d - 14.0) / 16.0, 0.0, 1.0)
	flat = flat * flat * (3.0 - 2.0 * flat)
	h = lerpf(0.4, h, flat)
	for p in ASH_POOLS:
		var pd := Vector2(x - p[0], z - p[1]).length()
		var f := clampf(1.0 - (pd - p[2]) / 4.0, 0.0, 1.0)
		f = f * f * (3.0 - 2.0 * f)
		h = lerpf(h, -0.3, f)
	var edge := maxf(0.0, (d - 78.0) / 20.0)
	return h + edge * edge * 16.0

func _swamp_h(x: float, z: float) -> float:
	var h := vn(x * 0.04 + 40.0, z * 0.04 - 17.0) * 7.0 + vn(x * 0.11, z * 0.11) * 1.8 + vn(x * 0.27, z * 0.27) * 0.4 - 3.6
	h = maxf(h, -1.7)
	var d := sqrt(x * x + z * z)
	var flat := clampf((d - 14.0) / 16.0, 0.0, 1.0)
	flat = flat * flat * (3.0 - 2.0 * flat)
	var edge := maxf(0.0, (d - 78.0) / 20.0)
	return lerpf(0.5, h, flat) + edge * edge * 16.0

## Madenin işaretli mesafe alanı: eksi = boş (yürünebilir), artı = kaya
func _mine_sd(x: float, z: float) -> float:
	var p := Vector2(x, z)
	var best := 1000.0
	for i in MINE_ROOMS.size():
		var r: Array = MINE_ROOMS[i]
		var c := Vector2(r[0], r[1])
		best = minf(best, p.distance_to(c) - float(r[2]))
		if i > 0:
			var pr: Array = MINE_ROOMS[i - 1]
			var q := Geometry2D.get_closest_point_to_segment(p, Vector2(pr[0], pr[1]), c)
			best = minf(best, p.distance_to(q) - 3.4)
	for a in MINE_ALC:
		var ar: Array = a
		var ac := Vector2(ar[0], ar[1])
		best = minf(best, p.distance_to(ac) - float(ar[2]))
		var rc: Array = MINE_ROOMS[int(ar[3])]
		var q2 := Geometry2D.get_closest_point_to_segment(p, Vector2(rc[0], rc[1]), ac)
		best = minf(best, p.distance_to(q2) - 2.4)
	return best

func _mine_h(x: float, z: float) -> float:
	var sd := _mine_sd(x, z)
	var w := clampf((sd + 0.3) / 3.2, 0.0, 1.0)
	w = w * w * (3.0 - 2.0 * w)
	var rough := vn(x * 0.35, z * 0.35) * 0.5 + vn(x * 0.9, z * 0.9) * 0.2
	return vn(x * 0.15 + 7.0, z * 0.15) * 0.35 + w * (11.0 + rough * 2.5)

func _mine_torches() -> Array:
	if not _mine_torch_cache.is_empty():
		return _mine_torch_cache
	for r in MINE_ROOMS:
		var rr: float = r[2]
		for k in 7:
			var a := float(k) / 7.0 * TAU + 0.3
			var dx := cos(a)
			var dz := sin(a)
			if _mine_sd(r[0] + dx * (rr + 2.0), r[1] + dz * (rr + 2.0)) < -0.2:
				continue
			_mine_torch_cache.append(Vector2(r[0] + dx * (rr - 1.0), r[1] + dz * (rr - 1.0)))
	for a2 in MINE_ALC:
		var al: Array = a2
		var ap := Vector2(al[0], al[1])
		for sd2 in [-1.0, 1.0]:
			_mine_torch_cache.append(ap + Vector2(0.0, sd2 * (float(al[2]) - 1.0)))
	return _mine_torch_cache

func _mine_color(x: float, z: float, _y: float) -> Color:
	var sd := _mine_sd(x, z)
	var n := vn(x * 0.2, z * 0.2)
	var n2 := vn(x * 0.6 + 3.0, z * 0.6 - 5.0)
	var fl := Color("5a4e44").lerp(Color("453c36"), clampf(n * 1.4 - 0.2, 0.0, 1.0))
	fl = fl.lerp(Color("6a5a48"), clampf((n2 - 0.6) * 3.0, 0.0, 0.5))
	var wl := Color("3a3438").lerp(Color("2a2428"), n)
	var c := fl.lerp(wl, clampf((sd + 0.2) / 2.0, 0.0, 1.0))
	if n2 > 0.8 and sd > -0.5:
		c = c.lerp(Color("c8a050"), 0.55)
	var g := 0.0
	for t in _mine_torches():
		var d := Vector2(x - t.x, z - t.y).length()
		var f := clampf(1.0 - d / 9.0, 0.0, 1.0)
		g += f * f
	for lp in [Vector2(-13.0, -77.0), Vector2(13.0, -77.0)]:
		var f2 := clampf(1.0 - Vector2(x - lp.x, z - lp.y).length() / 11.0, 0.0, 1.0)
		g += f2 * f2 * 1.6
	g = minf(g, 1.4)
	return Color(c.r + g * 0.5, c.g + g * 0.27, c.b + g * 0.08)

func height_at(x: float, z: float) -> float:
	if x > ROOM_X - 30.0:
		return 0.0
	if map == "mine":
		return _mine_h(x, z)
	if map == "swamp":
		return _swamp_h(x, z)
	if map == "ash":
		return _ash_h(x, z)
	var h := vn(x * 0.03, z * 0.03) * 16.0 + vn(x * 0.08, z * 0.08) * 4.5 + vn(x * 0.21, z * 0.21) * 0.9 - 9.0
	var d := sqrt(x * x + z * z)
	var flat := clampf((d - 13.0) / 18.0, 0.0, 1.0)
	flat = flat * flat * (3.0 - 2.0 * flat)
	var edge := maxf(0.0, (d - 78.0) / 20.0)
	var res := h * flat + edge * edge * 20.0
	var dc := sqrt((x - CITY.x) * (x - CITY.x) + (z - CITY.z) * (z - CITY.z))
	var cf := clampf((dc - CITY.r) / 12.0, 0.0, 1.0)
	cf = cf * cf * (3.0 - 2.0 * cf)
	return res * cf + CITY.y * (1.0 - cf)

# ---------- kurulum ----------
func _ready() -> void:
	randomize()
	m_stone = _tmat(Tex.stone(), 0.22, 0.0, 0.9)
	m_wood = _tmat(Tex.wood(), 0.4, 0.0, 0.85)
	m_roof = _tmat(Tex.roof(), 0.3, 0.0, 0.8)
	m_cobble = _tmat(Tex.cobble(), 0.25, 0.0, 0.95)
	m_gold = Dwarf.mat(Color.html("e6b440"), 0.85, 0.28)
	m_bronze = Dwarf.mat(Color.html("b8782e"), 0.7, 0.4)
	m_snow = Dwarf.mat(Color.html("e6eefa"), 0.0, 0.9)
	m_blue = Dwarf.mat(Color.html("2a55b8"), 0.0, 0.85)
	m_blue.cull_mode = BaseMaterial3D.CULL_DISABLED
	m_thatch = Dwarf.mat(Color.html("8a7a3a"), 0.0, 0.95)
	_setup_environment()
	_spawn_player()
	_build_world()
	hud = HudScript.new()
	add_child(hud)
	invui = InvUI.new()
	invui.game = self
	hud.add_child(invui)
	talui = TalentUI.new()
	talui.game = self
	hud.add_child(talui)
	progui = ProgUI.new()
	progui.game = self
	hud.add_child(progui)
	worldmap = WorldMap.new()
	hud.add_child(worldmap)
	keyui = KeyUI.new()
	keyui.game = self
	hud.add_child(keyui)
	keyui.build()
	hud.keys_pressed.connect(func(): keyui.open())
	hud.bag_pressed.connect(func(): toggle_win("bag"))
	hud.char_pressed.connect(func(): toggle_win("char"))
	hud.prog_pressed.connect(func(): toggle_win("prog"))
	hud.menu_pressed.connect(toggle_pause)
	hud.help_pressed.connect(hud.toggle_help)
	hud.tal_pressed.connect(func(): toggle_win("tal"))
	inv_changed()
	hud.start_pressed.connect(_on_start)
	hud.ability_pressed.connect(ability)
	hud.resume_pressed.connect(toggle_pause)
	hud.quit_pressed.connect(func():
		save_game()
		get_tree().quit())
	hud.fullscreen_pressed.connect(toggle_fullscreen)
	sfx = SfxScript.new()
	add_child(sfx)
	hud.volume_changed.connect(sfx.set_volume)
	hud.sens_changed.connect(func(x): mouse_sens = x; save_settings())
	hud.order_changed.connect(save_settings)
	hud.quality_changed.connect(func(q): apply_quality(q); save_settings())
	hud.volume_changed.connect(func(_x): save_settings())
	sfx.set_volume(0.8)
	load_settings()
	hud.set_has_save(FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(SAVE_PATH + SaveManager.BACKUP_SUFFIX))
	get_tree().set_auto_accept_quit(false)
	_update_camera(0.0)

func _build_world() -> void:
	if map == "mine":
		camps_now = MINE_CAMPS
		_build_terrain()
		_build_mine()
		_spawn_npcs()
		_spawn_mobs()
		_spawn_bosses()
		_spawn_camps()
		_spawn_nodes()
		_setup_mine_fx()
		_spawn_discoveries()
	elif map == "ash":
		camps_now = ASH_CAMPS
		_build_terrain()
		_build_ash()
		_spawn_npcs()
		_spawn_mobs()
		_spawn_bosses()
		_spawn_camps()
		_setup_ash_fx()
		_spawn_discoveries()
	elif map == "swamp":
		camps_now = SWAMP_CAMPS
		_build_terrain()
		_build_swamp()
		_spawn_npcs()
		_spawn_mobs()
		_spawn_bosses()
		_spawn_camps()
		_setup_swamp_fx()
		_spawn_discoveries()
	else:
		camps_now = CAMPS
		_build_terrain()
		_build_mountains()
		_build_forest()
		_build_village()
		_build_city()
		_spawn_npcs()
		_spawn_mobs()
		_spawn_bosses()
		_spawn_camps()
		_setup_snow()
		_spawn_nodes()
		_spawn_discoveries()
	if map != "mine" and map != "ash":
		_setup_rain()
	_spawn_walls()
	_apply_env()

func _clear_world() -> void:
	if loot_mob != null:
		close_loot()
	if dlg_open:
		close_dialog()
	if vendor_npc != null:
		close_vendor()
	for mb in mobs:
		hud.plate_hide(mb.id)
	for n in npcs:
		hud.plate_hide("npc_" + n["id"])
	var keep: Array = [player, cam, sun, we_node, hud, sfx]
	for c in get_children():
		if not keep.has(c):
			c.queue_free()
	mobs.clear()
	npcs.clear()
	obs.clear()
	flame_nodes.clear()
	house_doors.clear()
	rings.clear()
	portals.clear()
	res_nodes.clear()
	wall_list.clear()
	snow_node = null
	rain_node = null
	swamp_fx = null
	lava_mat = null
	mine_lantern = null
	fire_light = null
	forge_light = null
	gate_light = null
	P["target"] = null
	P["auto"] = false
	cur_npc = null

func _enter_map(name: String) -> void:
	_clear_world()
	map = name
	zone_now = ""
	_build_world()

## Portaldan haritalar arası geçiş (kararma ile)
func _travel(to: String, x: float, z: float, yaw: float) -> void:
	if traveling or mode != "play":
		return
	traveling = true
	mode = "travel"
	P["auto"] = false
	var cl := CanvasLayer.new()
	cl.layer = 100
	var cr := ColorRect.new()
	cr.color = Color(0, 0, 0, 0)
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(cr)
	get_tree().root.add_child(cl)
	var tw := create_tween()
	tw.tween_property(cr, "color:a", 1.0, 0.45)
	await tw.finished
	await get_tree().process_frame
	_enter_map(to)
	P["x"] = x
	P["z"] = z
	P["y"] = height_at(x, z)
	P["yaw"] = yaw
	cam_yaw = yaw - PI
	portal_cd = 4.0
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(cr, "color:a", 0.0, 0.6)
	await tw2.finished
	cl.queue_free()
	mode = "play"
	traveling = false
	save_game()

func _make_portal(x: float, z: float, col: Color, to: String, tx: float, tz: float, tyaw: float, label: String) -> void:
	var g := Node3D.new()
	g.position = Vector3(x, height_at(x, z), z)
	add_child(g)
	var stone := Dwarf.mat(Color.html("5a5a66"), 0.0, 0.9)
	Dwarf.cyl(g, 2.8, 3.1, 0.5, stone, Vector3(0, 0.25, 0), 20)
	for sd in [-1.0, 1.0]:
		Dwarf.box(g, Vector3(0.6, 4.2, 0.6), stone, Vector3(sd * 2.1, 2.3, 0))
		Dwarf.sph(g, 0.3, Dwarf.mat(col, 0.0, 0.4, col, 2.5), Vector3(sd * 2.1, 4.6, 0))
	Dwarf.box(g, Vector3(4.8, 0.6, 0.6), stone, Vector3(0, 4.5, 0))
	var em := Dwarf.mat(col, 0.0, 0.4, col, 3.0)
	var ring := Dwarf.torus(g, 1.9, 0.14, em, Vector3(0, 2.3, 0))
	ring.rotation.x = PI / 2.0
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var dm := StandardMaterial3D.new()
	dm.albedo_color = Color(col.r, col.g, col.b, 0.35)
	dm.emission_enabled = true
	dm.emission = col
	dm.emission_energy_multiplier = 1.6
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.cull_mode = BaseMaterial3D.CULL_DISABLED
	var disc := Dwarf.cyl(g, 1.8, 1.8, 0.05, dm, Vector3(0, 2.3, 0), 24)
	disc.rotation.x = PI / 2.0
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var li := OmniLight3D.new()
	li.light_color = col
	li.omni_range = 9.0
	li.light_energy = 1.1
	li.position = Vector3(0, 2.5, 0.5)
	g.add_child(li)
	_add_obs(x - 2.1, z, 0.6)
	_add_obs(x + 2.1, z, 0.6)
	portals.append({"x": x, "z": z, "to": to, "tx": tx, "tz": tz, "tyaw": tyaw, "label": label, "disc": disc, "ring": ring})

func _step_portals(dt: float) -> void:
	portal_cd = maxf(0.0, portal_cd - dt)
	for p in portals:
		(p["disc"] as Node3D).rotation.y += dt * 1.5
		(p["ring"] as Node3D).rotation.z += dt * 0.8
	if mode != "play" or P["dead"] or portal_cd > 0.0:
		return
	for p in portals:
		if Vector2(p["x"] - P["x"], p["z"] - P["z"]).length() < 2.0:
			hud.banner(String(p["label"]).to_upper(), "Portal")
			_travel(p["to"], p["tx"], p["tz"], p["tyaw"])
			return

func _tmat(tex: Texture2D, scale: float, metal: float, rough: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(scale, scale, scale)
	m.metallic = metal
	m.roughness = rough
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m

func _setup_environment() -> void:
	var env := Environment.new()
	env_res = env
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	sky_psm = psm
	psm.sky_top_color = Color("2f5fb0")
	psm.sky_horizon_color = Color("d9d2dc")
	psm.ground_horizon_color = Color("c8c9d6")
	psm.ground_bottom_color = Color("7f93b8")
	psm.sky_curve = 0.22
	psm.sun_angle_max = 28.0
	psm.sun_curve = 0.12
	sky.sky_material = psm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("9db4dc")
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 0.88
	env.tonemap_white = 6.0
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_bloom = 0.06
	env.glow_hdr_threshold = 1.0
	env.ssao_enabled = true
	env.ssao_radius = 1.6
	env.ssao_intensity = 1.8
	env.fog_enabled = true
	env.fog_light_color = Color("c5d0e6")
	env.fog_density = 0.0075
	env.fog_sky_affect = 0.45
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.12
	env.adjustment_contrast = 1.12
	var we := WorldEnvironment.new()
	we.environment = env
	we_node = we
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.light_color = Color("ffd9a0")
	sun.light_energy = 1.05
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 110.0
	sun.shadow_blur = 1.4
	sun.rotation_degrees = Vector3(-44, -35, 0)
	add_child(sun)
	cam = Camera3D.new()
	cam.fov = 62.0
	cam.far = 600.0
	cam.current = true
	add_child(cam)

func _apply_env() -> void:
	if env_res == null:
		return
	if map == "mine":
		sky_psm.sky_top_color = Color("060507")
		sky_psm.sky_horizon_color = Color("0a0809")
		sky_psm.ground_horizon_color = Color("0a0809")
		sky_psm.ground_bottom_color = Color("060507")
		env_res.ambient_light_color = Color("7a6a80")
		env_res.ambient_light_energy = 0.85
		env_res.fog_light_color = Color("14100f")
		env_res.fog_density = 0.022
		env_res.adjustment_saturation = 1.0
		sun.light_color = Color("403040")
		sun.light_energy = 0.0
	elif map == "ash":
		sky_psm.sky_top_color = Color("3a2420")
		sky_psm.sky_horizon_color = Color("b8582a")
		sky_psm.ground_horizon_color = Color("7a3a22")
		sky_psm.ground_bottom_color = Color("2a1612")
		env_res.ambient_light_color = Color("806458")
		env_res.ambient_light_energy = 0.7
		env_res.fog_light_color = Color("5a3a30")
		env_res.fog_density = 0.012
		env_res.adjustment_saturation = 1.05
		sun.light_color = Color("ff9a5a")
		sun.light_energy = 0.7
	elif map == "swamp":
		sky_psm.sky_top_color = Color("34504a")
		sky_psm.sky_horizon_color = Color("7a8868")
		sky_psm.ground_horizon_color = Color("5e6c50")
		sky_psm.ground_bottom_color = Color("303c2a")
		env_res.ambient_light_color = Color("667c6a")
		env_res.ambient_light_energy = 0.5
		env_res.fog_light_color = Color("56694f")
		env_res.fog_density = 0.028
		env_res.adjustment_saturation = 0.95
		sun.light_color = Color("c0c694")
		sun.light_energy = 0.5
	else:
		sky_psm.sky_top_color = Color("2f5fb0")
		sky_psm.sky_horizon_color = Color("d9d2dc")
		sky_psm.ground_horizon_color = Color("c8c9d6")
		sky_psm.ground_bottom_color = Color("7f93b8")
		env_res.ambient_light_color = Color("9db4dc")
		env_res.ambient_light_energy = 0.8
		env_res.fog_light_color = Color("c5d0e6")
		env_res.fog_density = 0.0075
		env_res.adjustment_saturation = 1.12
		sun.light_color = Color("ffd9a0")
		sun.light_energy = 1.05
	_capture_env_base()
	if sfx:
		sfx.set_map(map)

## Gece-gündüz ve hava: temel değerler _apply_env sonrası saklanır, _step_daynight her 0.2 sn'de ayarlar
var env_base := {}
var day_k := 1.0
var storm_k := 0.0
var rain_node: GPUParticles3D
var day_acc := 0.0

func _capture_env_base() -> void:
	env_base = {
		"top": sky_psm.sky_top_color, "hor": sky_psm.sky_horizon_color,
		"gh": sky_psm.ground_horizon_color, "gb": sky_psm.ground_bottom_color,
		"amb": env_res.ambient_light_color, "ambe": env_res.ambient_light_energy,
		"fog": env_res.fog_light_color, "fogd": env_res.fog_density,
		"sun": sun.light_energy,
	}

func _step_daynight(dt: float) -> void:
	if env_base.is_empty() or env_res == null:
		return
	day_acc += dt
	if day_acc < 0.2:
		return
	var step_dt := day_acc
	day_acc = 0.0
	if map == "mine" or map == "ash":
		return
	# 300 sn'lik tam gün; başlangıç sabah
	var ph := fmod(T / 300.0 + 0.25, 1.0)
	var sun_h := sin(ph * TAU)
	day_k = clampf(smoothstep(-0.18, 0.35, sun_h), 0.0, 1.0)
	# fırtına: kar haritasında kar fırtınası, bataklıkta yağmur; ~200 sn'de bir, 50 sn sürer
	var wph := fmod(T, 200.0)
	var want := 1.0 if wph > 140.0 and wph < 190.0 else 0.0
	storm_k = move_toward(storm_k, want, step_dt * 0.25)
	var night_sky := Color("0b1226")
	var night_amb := Color("2a3a66")
	var dusk := clampf(1.0 - absf(sun_h) * 3.0, 0.0, 1.0) * 0.5
	var grey := Color("8a93a0")
	var top: Color = env_base["top"].lerp(night_sky, 1.0 - day_k).lerp(grey * 0.7, storm_k * 0.5)
	var hor: Color = env_base["hor"].lerp(Color("1a2038"), 1.0 - day_k).lerp(Color("e08a50"), dusk).lerp(grey, storm_k * 0.55)
	sky_psm.sky_top_color = top
	sky_psm.sky_horizon_color = hor
	sky_psm.ground_horizon_color = hor
	sky_psm.ground_bottom_color = env_base["gb"].lerp(night_sky, 1.0 - day_k)
	env_res.ambient_light_color = env_base["amb"].lerp(night_amb, 1.0 - day_k)
	env_res.ambient_light_energy = lerpf(0.5, env_base["ambe"], day_k) * (1.0 - storm_k * 0.2)
	env_res.fog_light_color = env_base["fog"].lerp(Color("141a30"), 1.0 - day_k).lerp(grey, storm_k * 0.5)
	env_res.fog_density = env_base["fogd"] * (1.0 + storm_k * (3.5 if map == "snow" else 1.8)) * (1.0 + (1.0 - day_k) * 0.3)
	sun.light_energy = env_base["sun"] * day_k * (1.0 - storm_k * 0.55)
	sun.rotation_degrees = Vector3(-clampf(sun_h * 70.0 + 8.0, 6.0, 78.0), -35.0 + ph * 40.0, 0)
	if snow_node:
		snow_node.visible = map == "snow"
		snow_node.amount_ratio = lerpf(0.45, 1.0, storm_k)
		var pm: ParticleProcessMaterial = snow_node.process_material
		pm.gravity = Vector3(storm_k * 5.0, -0.3, storm_k * 1.5)
	if rain_node:
		rain_node.visible = map == "swamp"
		rain_node.emitting = map == "swamp" and storm_k > 0.05
		rain_node.amount_ratio = clampf(storm_k, 0.05, 1.0)
	if swamp_fx:
		swamp_fx.visible = (map == "swamp" and storm_k < 0.5) or map == "ash" or map == "mine"

func _setup_rain() -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(24, 0.5, 24)
	pm.direction = Vector3(0.1, -1, 0)
	pm.spread = 3.0
	pm.initial_velocity_min = 22.0
	pm.initial_velocity_max = 28.0
	pm.gravity = Vector3(0, -6, 0)
	var q := QuadMesh.new()
	q.size = Vector2(0.03, 0.7)
	var qm := StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	qm.albedo_color = Color(0.7, 0.8, 0.9, 0.45)
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = qm
	rain_node = GPUParticles3D.new()
	rain_node.amount = 1800
	rain_node.lifetime = 1.0
	rain_node.preprocess = 1.0
	rain_node.process_material = pm
	rain_node.draw_pass_1 = q
	rain_node.visibility_aabb = AABB(Vector3(-26, -22, -26), Vector3(52, 44, 52))
	rain_node.local_coords = false
	rain_node.emitting = false
	rain_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rain_node)

func _build_terrain() -> void:
	var seg := 160
	var size := 260.0
	var verts := PackedVector3Array()
	var cols := PackedColorArray()
	var uvs := PackedVector2Array()
	var norms := PackedVector3Array()
	var idx := PackedInt32Array()
	for j in range(seg + 1):
		for i in range(seg + 1):
			var x := (float(i) / seg - 0.5) * size
			var z := (float(j) / seg - 0.5) * size
			var y := height_at(x, z)
			verts.append(Vector3(x, y, z))
			uvs.append(Vector2(float(i) / seg, float(j) / seg) * 70.0)
			var e := 1.0
			norms.append(Vector3(height_at(x - e, z) - height_at(x + e, z), 2.0 * e, height_at(x, z - e) - height_at(x, z + e)).normalized())
			cols.append(_terrain_color(x, z, y))
	for j in range(seg):
		for i in range(seg):
			var a := j * (seg + 1) + i
			var b := a + 1
			var c := a + seg + 1
			var d := c + 1
			idx.append_array([a, b, c, b, d, c])
	var arr := []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_COLOR] = cols
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.vertex_color_is_srgb = true
	m.albedo_texture = Tex.detail()
	m.roughness = 0.95
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = m
	add_child(mi)

func _swamp_color(x: float, z: float, y: float) -> Color:
	var s := maxf(absf(height_at(x + 1.2, z) - y), absf(height_at(x, z + 1.2) - y)) / 1.2
	var n := vn(x * 0.09, z * 0.09)
	var n2 := vn(x * 0.31 + 5.0, z * 0.31 - 8.0)
	var c := Color("46562a").lerp(Color("66663a"), clampf(n * 1.3 - 0.2, 0.0, 1.0))
	c = c.lerp(Color("3f5a30"), clampf(n2 * 1.1 - 0.3, 0.0, 0.6))
	c = c.lerp(Color("3a3322"), clampf((-0.1 - y) * 1.4, 0.0, 0.9))
	c = c.lerp(Color("5a6a46"), clampf((y - 5.0) / 8.0, 0.0, 0.7))
	c = c.lerp(Color("5c5a4a"), clampf((s - 0.6) * 2.0, 0.0, 1.0))
	var d := sqrt(x * x + z * z)
	c = c.lerp(Color("8a7a52"), clampf((15.0 - d) / 6.0, 0.0, 1.0) * 0.85)
	return c

func _ash_color(x: float, z: float, y: float) -> Color:
	var s := maxf(absf(height_at(x + 1.2, z) - y), absf(height_at(x, z + 1.2) - y)) / 1.2
	var n := vn(x * 0.09, z * 0.09)
	var n2 := vn(x * 0.31 + 5.0, z * 0.31 - 8.0)
	var c := Color("46423f").lerp(Color("6e6862"), clampf(n * 1.3 - 0.2, 0.0, 1.0))
	c = c.lerp(Color("2c2826"), clampf(n2 * 1.1 - 0.3, 0.0, 0.6))
	c = c.lerp(Color("7a6a5e"), clampf((y - 4.0) / 6.0, 0.0, 0.5))
	c = c.lerp(Color("201a18"), clampf((s - 0.6) * 2.0, 0.0, 1.0))
	for p in ASH_POOLS:
		var pd := Vector2(x - p[0], z - p[1]).length()
		c = c.lerp(Color("c8501a"), clampf(1.0 - (pd - p[2]) / 3.0, 0.0, 1.0) * 0.8)
	var d := sqrt(x * x + z * z)
	return c.lerp(Color("7a6a54"), clampf((15.0 - d) / 6.0, 0.0, 1.0) * 0.85)

func _terrain_color(x: float, z: float, y: float) -> Color:
	if map == "mine":
		return _mine_color(x, z, y)
	if map == "ash":
		return _ash_color(x, z, y)
	if map == "swamp":
		return _swamp_color(x, z, y)
	var s := maxf(absf(height_at(x + 1.2, z) - y), absf(height_at(x, z + 1.2) - y)) / 1.2
	var n := vn(x * 0.11, z * 0.11)
	var n2 := vn(x * 0.37 + 9.0, z * 0.37 - 4.0)
	var d := sqrt(x * x + z * z)
	# kar: soğuk mavi-beyaz, gölgelerde mora çalan
	var c := Color("e8f0fb").lerp(Color("a9c0e4"), clampf(n * 1.3 - 0.15, 0.0, 1.0))
	c = c.lerp(Color("c9d6ee"), clampf(n2 * 0.5, 0.0, 0.4))
	# donmuş çimen ve kuru otlar (Dun Morogh)
	var gp := clampf((0.58 - n) * 3.0 + (3.0 - y) * 0.08, 0.0, 1.0) * clampf(1.3 - absf(y) / 9.0, 0.0, 1.0)
	var grass := Color("5f8f4a").lerp(Color("9a9a58"), clampf(n2 * 1.4 - 0.3, 0.0, 1.0))
	c = c.lerp(grass, gp * 0.85)
	# çıplak toprak lekeleri
	var dp := clampf((n2 - 0.62) * 4.0, 0.0, 1.0) * clampf(0.5 - n * 0.4, 0.0, 1.0)
	c = c.lerp(Color("7c6a52"), dp * 0.7)
	c = c.lerp(Color("6f7a88"), clampf((s - 0.55) * 2.2, 0.0, 1.0))
	c = c.lerp(Color("7a6a58"), clampf((11.0 - d) / 5.0, 0.0, 1.0))
	var rdx := absf(x - sin(z * 0.07) * 3.0)
	if z < 14.0 and z > CITY.z + 18.0:
		c = c.lerp(Color("9c8a74"), clampf(1.0 - (rdx - 1.8) / 1.2, 0.0, 1.0) * 0.9)
	return c

func _cone_mi(r: float, h: float, m: Material, pos: Vector3, shadow: bool = true, seg: int = 7) -> MeshInstance3D:
	var mi := Dwarf.cone(self, r, h, m, pos, seg)
	if not shadow:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mi

func _build_mountains() -> void:
	var mm := Dwarf.mat(Color.html("7d8aa8"), 0.0, 0.95)
	var mm2 := Dwarf.mat(Color.html("9aa6c4"), 0.0, 0.95)
	var cap := Dwarf.mat(Color.html("eef3fc"), 0.0, 0.9)
	for i in 34:
		var a := float(i) / 34.0 * TAU + hash2(i, 3) * 0.2
		var far := i % 2 == 1
		var r := (150.0 if far else 128.0) + hash2(i, 9) * 25.0
		var h := 40.0 + hash2(i, 5) * 48.0
		var w := 24.0 + hash2(i, 7) * 18.0
		var base := mm2 if far else mm
		var c := _cone_mi(w, h, base, Vector3(cos(a) * r, h / 2.0 - 8.0, sin(a) * r), false, 5)
		c.rotation.y = hash2(i, 1) * 3.0
		var t := _cone_mi(w * 0.5, h * 0.46, cap, Vector3(cos(a) * r, h * 0.77 - 8.0, sin(a) * r), false, 5)
		t.rotation.y = c.rotation.y

func _add_multimesh(mesh: Mesh, m: Material, xfs: Array, cols: Array = []) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = not cols.is_empty()
	mm.mesh = mesh
	mm.instance_count = xfs.size()
	for i in xfs.size():
		mm.set_instance_transform(i, xfs[i])
		if not cols.is_empty():
			mm.set_instance_color(i, cols[i])
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = m
	add_child(mmi)

func _add_obs(x: float, z: float, r: float) -> void:
	obs.append(Vector3(x, z, r))

func _build_forest() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 2026
	var tree_groups: Dictionary = {}
	var bush_groups: Dictionary = {}
	var rock_groups: Dictionary = {}
	var tries := 0
	while tries < 3000 and tree_groups.values().reduce(func(total, group): return total + group.size(), 0) < 260:
		tries += 1
		var a := rnd.randf() * TAU
		var r := 16.0 + sqrt(rnd.randf()) * 74.0
		var x := cos(a) * r
		var z := sin(a) * r
		if Vector2(x - CITY.x, z - CITY.z).length() <= 27.0:
			continue
		var scale_value := 2.6 + rnd.randf() * 1.25
		var model_name := "PineTree_Snow_%d.glb" % rnd.randi_range(1, 5)
		if rnd.randf() < 0.18:
			model_name = "BirchTree_Dead_Snow_%d.glb" % rnd.randi_range(1, 5)
		var transform := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * scale_value), Vector3(x, height_at(x, z), z))
		if not tree_groups.has(model_name):
			tree_groups[model_name] = []
		tree_groups[model_name].append(transform)
		_add_obs(x, z, 0.62 * scale_value)
	for model_name in tree_groups:
		_wow_mm("nature_pack/" + str(model_name), tree_groups[model_name])
	# Kar kaplı çalılar: iki ayrı varyantla doğal kümeler.
	for i in 150:
		var a2 := rnd.randf() * TAU
		var r2 := 8.0 + sqrt(rnd.randf()) * 82.0
		var x2 := cos(a2) * r2
		var z2 := sin(a2) * r2
		if Vector2(x2 - CITY.x, z2 - CITY.z).length() < 25.0 or Vector2(x2, z2).length() < 12.0:
			continue
		var bush_name := "Bush_Snow_%d.glb" % rnd.randi_range(1, 2)
		var bush_scale := 0.65 + rnd.randf() * 0.8
		var bush_xf := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * bush_scale), Vector3(x2, height_at(x2, z2), z2))
		if not bush_groups.has(bush_name):
			bush_groups[bush_name] = []
		bush_groups[bush_name].append(bush_xf)
	for model_name in bush_groups:
		_wow_mm("nature_pack/" + str(model_name), bush_groups[model_name])
	# Kayalık alanlar; gerçek Quaternius kar kayaları, her birine ayrı varyant.
	for i in 54:
		var a3 := rnd.randf() * TAU
		var r3 := 18.0 + rnd.randf() * 78.0
		var x3 := cos(a3) * r3
		var z3 := sin(a3) * r3
		if Vector2(x3 - CITY.x, z3 - CITY.z).length() < 25.0:
			continue
		var rock_name := "Rock_Snow_%d.glb" % rnd.randi_range(1, 7)
		var rock_scale := 1.0 + rnd.randf() * 2.0
		var rock_xf := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3(rock_scale * 1.2, rock_scale * 0.8, rock_scale)), Vector3(x3, height_at(x3, z3) - 0.1, z3))
		if not rock_groups.has(rock_name):
			rock_groups[rock_name] = []
		rock_groups[rock_name].append(rock_xf)
		_add_obs(x3, z3, 0.9 * rock_scale)
	for model_name in rock_groups:
		_wow_mm("nature_pack/" + str(model_name), rock_groups[model_name])

func _wow_spawn(relative_path: String, pos: Vector3, rot: float = 0.0, scale_value: float = 1.0) -> Node3D:
	var path := "res://assets/wotlk/third_party/quaternius/" + relative_path
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var instance := packed.instantiate() as Node3D
	if instance == null:
		return null
	instance.position = pos
	instance.rotation.y = rot
	instance.scale = Vector3.ONE * scale_value
	add_child(instance)
	return instance

func _wow_mm(relative_path: String, transforms: Array) -> void:
	if transforms.is_empty():
		return
	var path := "res://assets/wotlk/third_party/quaternius/" + relative_path
	if not ResourceLoader.exists(path):
		push_warning("Missing Quaternius environment model: " + path)
		return
	var packed := load(path) as PackedScene
	if packed == null:
		return
	var source := packed.instantiate()
	var candidates: Array = source.find_children("*", "MeshInstance3D", true, false)
	if source is MeshInstance3D:
		candidates.push_front(source)
	for candidate in candidates:
		var mesh_instance := candidate as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var local_transform := mesh_instance.transform
		var parent := mesh_instance.get_parent()
		while parent != null and parent != source:
			if parent is Node3D:
				local_transform = (parent as Node3D).transform * local_transform
			parent = parent.get_parent()
		var combined: Array = []
		for base_transform in transforms:
			combined.append(base_transform * local_transform)
		# Keep the GLB's own surface materials and texture atlas intact.
		_add_multimesh(mesh_instance.mesh, null, combined)
	source.free()

func _flame(parent: Node, pos: Vector3, size: float) -> void:
	var m := Dwarf.mat(Color.html("ffa030"), 0.0, 0.5, Color.html("ff8a1a"), 4.0)
	var f := Dwarf.cone(parent, 0.5 * size, 1.5 * size, m, pos, 7)
	f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	flame_nodes.append(f)

## Evin kapısı: evin köy meydanına bakan tarafında; içi ROOM_X civarında bir odadır.
func _register_house(x: float, z: float, kind: String, label: String) -> void:
	var idx := house_doors.size()
	var cx := ROOM_X + float(idx) * ROOM_STEP
	Interiors.build(self, kind, cx, 0.0)
	var dir := Vector2(-x, -z).normalized()
	house_doors.append({"x": x, "z": z, "name": label, "cx": cx, "out": Vector2(x, z) + dir * 6.2, "dir": dir})

func _room_idx() -> int:
	if P["x"] < ROOM_X - 30.0 or house_doors.is_empty():
		return -1
	return clampi(roundi((P["x"] - ROOM_X) / ROOM_STEP), 0, house_doors.size() - 1)

func near_house_door() -> int:
	if _room_idx() >= 0:
		return -1
	for i in house_doors.size():
		var hd: Dictionary = house_doors[i]
		if Vector2(hd["x"] - P["x"], hd["z"] - P["z"]).length() < 6.8:
			return i
	return -1

func near_room_exit() -> bool:
	var ri := _room_idx()
	if ri < 0:
		return false
	var hd: Dictionary = house_doors[ri]
	return Vector2(hd["cx"] + Interiors.EXIT_SPOT.x - P["x"], Interiors.EXIT_SPOT.y - P["z"]).length() < 2.8

func try_house_door() -> bool:
	if mode != "play" or P["dead"] or traveling:
		return false
	var ri := _room_idx()
	if ri >= 0:
		if not near_room_exit():
			return false
		var hd: Dictionary = house_doors[ri]
		var out: Vector2 = hd["out"]
		var dir: Vector2 = hd["dir"]
		_fade_move(out.x, out.y, atan2(dir.x, dir.y))
		return true
	var di := near_house_door()
	if di < 0:
		return false
	if T - float(P["combat_t"]) < 5.0:
		hud.say("Savaş sırasında içeri giremezsin.", Color("ff9a8a"))
		return true
	var h: Dictionary = house_doors[di]
	hud.banner(String(h["name"]).to_upper(), "İç mekân")
	_fade_move(float(h["cx"]) + Interiors.SPAWN.x, Interiors.SPAWN.y, PI)
	return true

## Aynı haritada kararma ile ışınlanma (iç mekân girişi/çıkışı).
func _fade_move(x: float, z: float, yaw: float) -> void:
	traveling = true
	mode = "travel"
	P["auto"] = false
	P["target"] = null
	var cl := CanvasLayer.new()
	cl.layer = 100
	var cr := ColorRect.new()
	cr.color = Color(0, 0, 0, 0)
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(cr)
	get_tree().root.add_child(cl)
	var tw := create_tween()
	tw.tween_property(cr, "color:a", 1.0, 0.3)
	await tw.finished
	P["x"] = x
	P["z"] = z
	P["y"] = height_at(x, z)
	P["yaw"] = yaw
	cam_yaw = yaw - PI
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(cr, "color:a", 0.0, 0.4)
	await tw2.finished
	cl.queue_free()
	mode = "play"
	traveling = false

func _house(x: float, z: float, rot: float, w: float, d: float, bog: bool = false) -> void:
	var house_index := 1 + (absi(roundi(x * 3.0 + z * 7.0)) % 4)
	if bog:
		house_index = 3 + (absi(roundi(x * 2.0 + z * 5.0)) % 2)
	var model_name := "House_%d.glb" % house_index
	var house_scale := clampf(minf(w, d) / 3.2, 1.45, 2.15)
	var house := _wow_spawn("medieval_village_pack/" + model_name, Vector3(x, height_at(x, z), z), rot, house_scale)
	if house == null:
		# Import fallback; this path keeps the map playable if the Quaternius house is missing.
		var fallback := Node3D.new()
		fallback.position = Vector3(x, height_at(x, z), z)
		fallback.rotation.y = rot
		add_child(fallback)
		var tw := maxi(2, roundi(w / 2.2))
		var td := maxi(2, roundi(d / 2.2))
		var fallback_house := Kit.house(fallback, tw, td, 2.2, Color(1.0, 0.93, 0.84), m_roof)
		fallback_house.scale = Vector3(1.0, 1.15, 1.0)
	if bog:
		for px in [-1.0, 1.0]:
			for pz in [-1.0, 1.0]:
				Dwarf.cyl(self, 0.2, 0.26, 1.6, m_wood, Vector3(x + px * w * 0.42, height_at(x, z) + 0.5, z + pz * d * 0.42), 6)
	_add_obs(x, z, maxf(w, d) * 0.55)

func _build_village() -> void:
	_house(-10, -4, 0.5, 6.0, 5.0)
	_house(10, -3, -0.6, 6.5, 5.0)
	_house(-8, 10, PI - 0.3, 5.5, 5.0)
	_house(11, 10, PI + 0.5, 5.0, 4.5)
	_register_house(-10.0, -4.0, "tavern", "Taverna")
	_register_house(10.0, -3.0, "bedroom", "Konak")
	_register_house(-8.0, 10.0, "library", "Kütüphane")
	_register_house(11.0, 10.0, "bedroom", "Misafirhane")
	_house(-18, -8, 1.1, 5.0, 4.5)
	_house(18, 8, -1.4, 5.0, 4.5)
	# kamp ateşi
	var fg := Node3D.new()
	fg.position = Vector3(0, height_at(0, 0), 0)
	add_child(fg)
	for i in 6:
		var lg := Dwarf.cyl(fg, 0.12, 0.12, 1.4, m_wood, Vector3(0, 0.3, 0), 6)
		lg.rotation = Vector3(0, i * PI / 3.0, 0)
		lg.rotation.z = PI / 2.6
	for j in 8:
		Dwarf.sph(fg, 0.28, m_stone, Vector3(cos(j * 0.785) * 1.1, 0.15, sin(j * 0.785) * 1.1), Vector3(1, 0.7, 1))
	_flame(fg, Vector3(0, 0.9, 0), 1.0)
	fire_light = OmniLight3D.new()
	fire_light.light_color = Color("ff9a40")
	fire_light.omni_range = 24.0
	fire_light.light_energy = 2.4
	fire_light.shadow_enabled = false
	fire_light.position = Vector3(0, 1.6, 0)
	fg.add_child(fire_light)
	_add_obs(0, 0, 1.3)
	# örs
	var an := Node3D.new()
	an.position = Vector3(5, height_at(5, 5), 5)
	an.rotation.y = 0.5
	add_child(an)
	var am := Dwarf.mat(Color.html("3a3f47"), 0.7, 0.45)
	Dwarf.box(an, Vector3(0.8, 0.5, 1.6), am, Vector3(0, 0.75, 0))
	Dwarf.box(an, Vector3(0.5, 0.3, 0.6), am, Vector3(0, 1.1, 0.9))
	Dwarf.box(an, Vector3(0.6, 0.6, 0.6), m_wood, Vector3(0, 0.3, 0))
	_add_obs(5, 5, 1.0)
	# örsün üstünde basit bir çatı (demirci kulübesi)
	var forge_roof := Node3D.new()
	forge_roof.position = Vector3(5, height_at(5, 5), 5)
	add_child(forge_roof)
	for px in [-1.0, 1.0]:
		for pz in [-1.0, 1.0]:
			Dwarf.cyl(forge_roof, 0.1, 0.1, 2.6, m_wood, Vector3(px * 1.3, 1.3, pz * 1.3), 6)
	var roof_slab := Dwarf.box(forge_roof, Vector3(3.2, 0.12, 3.2), m_roof, Vector3(0, 2.65, 0))
	roof_slab.rotation.y = 0.78
	# köy kuyusu
	var well := Node3D.new()
	well.position = Vector3(-3.0, height_at(-3.0, 1.0), 1.0)
	add_child(well)
	for j in 10:
		Dwarf.cyl(well, 0.16, 0.16, 0.7, m_stone, Vector3(cos(j * 0.628) * 0.9, 0.35, sin(j * 0.628) * 0.9), 6)
	for px in [-0.9, 0.9]:
		Dwarf.cyl(well, 0.07, 0.07, 1.6, m_wood, Vector3(px, 1.1, 0), 6)
	var well_roof := Dwarf.box(well, Vector3(2.2, 0.1, 1.6), m_roof, Vector3(0, 1.95, 0))
	well_roof.rotation.y = 0.5
	_add_obs(-3.0, 1.0, 1.1)
	# sancaklar
	var pts := [[-4, 12], [4, 13], [-3, -9], [3, -10]]
	for i in pts.size():
		var p = pts[i]
		var y0 := height_at(p[0], p[1])
		Dwarf.cyl(self, 0.07, 0.09, 5.0, m_wood, Vector3(p[0], y0 + 2.5, p[1]), 6)
		var fl := Dwarf.box(self, Vector3(1.2, 2.0, 0.04), m_blue, Vector3(p[0] + 0.65, y0 + 3.9, p[1]))
		fl.rotation.y = i * 0.4
		Dwarf.sph(self, 0.14, m_gold, Vector3(p[0], y0 + 5.05, p[1]))
	_village_props()
	WorldDressing.farm_plot(self, Vector2(-26.0, 2.0), 4, 6)
	WorldDressing.circling_birds(self, "res://assets/third_party/gobkit/birds/Eagle.glb", Vector3(0, 15.0, 0), 30.0, 3)

func _prop(kit: String, nm: String, x: float, z: float, rot: float, s: float, r := 0.0, tint: Color = Color(1.0, 0.93, 0.84)) -> void:
	# [model, ölçek çarpanı]: çağıranların verdiği ölçekler Kenney modellerine göre ayarlı;
	# Quaternius modelleri gerçek boyutta olduğu için çarpanla küçültülür.
	var replacements := {
		"survival|barrel": ["medieval_village_pack/Barrel.glb", 1.0],
		"survival|box-large": ["medieval_village_pack/Crate.glb", 1.0],
		"survival|chest": ["modular_dungeon_pack/Chest.glb", 0.3],
		"survival|campfire-pit": ["medieval_village_pack/Bonfire_Lit.glb", 0.5],
		"fantasy-town|cart": ["medieval_village_pack/Cart.glb", 1.0],
		"fantasy-town|stall-red": ["medieval_village_pack/MarketStand_1.glb", 0.7],
		"fantasy-town|lantern": ["modular_dungeon_pack/Torch_wall.glb", 0.3],
		"fantasy-town|fence": ["medieval_village_pack/Fence.glb", 1.15],
		"fantasy-town|stairs-wood": ["medieval_village_pack/Stairs.glb", 1.0],
	}
	var key := kit + "|" + nm
	var pos := Vector3(x, height_at(x, z), z)
	var spawned: Node3D = null
	if replacements.has(key):
		spawned = _wow_spawn(str(replacements[key][0]), pos, rot, s * float(replacements[key][1]))
	if spawned == null:
		Kit.spawn(self, kit, nm, pos, rot, s, tint)
	if r > 0.0:
		_add_obs(x, z, r)

func _village_props() -> void:
	_prop("survival", "tent", -4.5, -6.5, 0.4, 4.2, 1.5)
	_prop("survival", "tent", 4.0, -7.0, -0.5, 4.2, 1.5)
	_prop("survival", "barrel", -6.0, 3.0, 0.0, 3.6, 0.6)
	_prop("survival", "barrel", -6.7, 3.9, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", -5.2, 4.2, 0.4, 3.6, 0.7)
	_prop("survival", "chest", 7.5, 1.5, -1.2, 3.4, 0.6)
	_prop("survival", "signpost", 2.5, 8.5, 0.3, 3.8)
	_prop("fantasy-town", "cart", 6.5, 14.0, 0.7, 3.4, 1.3)
	_prop("fantasy-town", "stall-red", -13.5, 3.5, 1.2, 3.6, 1.5)
	_prop("fantasy-town", "lantern", -2.2, 4.6, 0.0, 3.2)
	_prop("fantasy-town", "stall-red", 13.0, 2.5, -1.0, 3.6, 1.5)
	_prop("fantasy-town", "cart", -14.5, -2.0, 0.9, 3.4, 1.3)
	_prop("survival", "barrel", 8.5, 2.5, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", 9.2, 3.2, 0.4, 3.6, 0.7)
	_prop("fantasy-town", "lantern", 2.6, 4.2, 0.0, 3.2)
	for i in 7:
		_prop("fantasy-town", "fence", -9.5 + i * 2.0, 16.0, PI / 2.0, 2.2)

func _build_city() -> void:
	var cx: float = CITY.x
	var cz: float = CITY.z
	var cy: float = CITY.y
	# plaza zemini
	var floor_mi := Dwarf.cyl(self, 21.0, 21.0, 0.12, m_cobble, Vector3(cx, cy + 0.0, cz), 48)
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# surlar
	var R := 21.5
	var N := 34
	var wall_xf: Array = []
	var mer_xf: Array = []
	for i in N:
		var a := float(i) / N * TAU
		var da := absf(atan2(sin(a - PI / 2.0), cos(a - PI / 2.0)))
		if da < 0.27 or da > PI - 0.95:
			continue
		var px := cx + cos(a) * R
		var pz := cz + sin(a) * R
		var rot := -a - PI / 2.0
		var b := Basis(Vector3.UP, rot)
		wall_xf.append(Transform3D(b, Vector3(px, cy + 3.1, pz)))
		var tx := -sin(a)
		var tz := cos(a)
		for o in [-1.3, 1.3]:
			mer_xf.append(Transform3D(b, Vector3(px + tx * o, cy + 6.8, pz + tz * o)))
		_add_obs(px, pz, 2.5)
	var wb := BoxMesh.new()
	wb.size = Vector3(4.9, 6.2, 2.2)
	var mb := BoxMesh.new()
	mb.size = Vector3(1.1, 1.2, 2.5)
	_add_multimesh(wb, m_stone, wall_xf)
	_add_multimesh(mb, m_stone, mer_xf)
	# kapı kuleleri
	for sd in [-1.0, 1.0]:
		var a: float = PI / 2.0 + sd * 0.34
		var px := cx + cos(a) * R
		var pz := cz + sin(a) * R
		Dwarf.cyl(self, 3.0, 3.4, 13.0, m_stone, Vector3(px, cy + 6.5, pz), 14)
		Dwarf.cyl(self, 3.25, 3.25, 0.5, m_gold, Vector3(px, cy + 11.5, pz), 14)
		Dwarf.cone(self, 3.9, 5.5, m_bronze, Vector3(px, cy + 16.0, pz), 14)
		Dwarf.sph(self, 0.4, m_gold, Vector3(px, cy + 19.0, pz))
		Dwarf.box(self, Vector3(1.8, 6.0, 0.05), m_blue, Vector3(px, cy + 8.0, pz + 3.45))
		Dwarf.box(self, Vector3(0.35, 5.6, 0.06), m_gold, Vector3(px, cy + 8.0, pz + 3.5))
		_add_obs(px, pz, 3.4)
	# sur üstü gözetleme kuleleri
	for sd2 in [-1.0, 1.0]:
		for off in [1.15, 2.0]:
			var a2: float = PI / 2.0 + sd2 * off
			var tx2 := cx + cos(a2) * R
			var tz2 := cz + sin(a2) * R
			Dwarf.cyl(self, 2.1, 2.4, 9.5, m_stone, Vector3(tx2, cy + 4.75, tz2), 12)
			Dwarf.cyl(self, 2.35, 2.35, 0.4, m_gold, Vector3(tx2, cy + 8.6, tz2), 12)
			Dwarf.cone(self, 2.8, 3.8, m_bronze, Vector3(tx2, cy + 11.4, tz2), 12)
			Dwarf.sph(self, 0.3, m_gold, Vector3(tx2, cy + 13.5, tz2))
			var tlight := OmniLight3D.new()
			tlight.light_color = Color("ffb060")
			tlight.omni_range = 7.0
			tlight.light_energy = 0.8
			tlight.position = Vector3(tx2, cy + 7.5, tz2)
			add_child(tlight)
			_add_obs(tx2, tz2, 2.6)
	var gz := cz + R
	Dwarf.box(self, Vector3(10.5, 2.6, 2.8), m_stone, Vector3(cx, cy + 9.6, gz))
	Dwarf.box(self, Vector3(11.0, 0.45, 3.1), m_gold, Vector3(cx, cy + 8.2, gz))
	Dwarf.box(self, Vector3(4.2, 2.0, 0.05), m_blue, Vector3(cx, cy + 9.6, gz + 1.45))
	for sd in [-1.0, 1.0]:
		var br := Node3D.new()
		br.position = Vector3(cx + sd * 4.6, cy, gz + 2.2)
		add_child(br)
		Dwarf.cyl(br, 0.5, 0.35, 1.2, m_bronze, Vector3(0, 1.4, 0), 10)
		Dwarf.cyl(br, 0.1, 0.1, 1.4, m_bronze, Vector3(0, 0.7, 0), 6)
		_flame(br, Vector3(0, 2.4, 0), 0.7)
	gate_light = OmniLight3D.new()
	gate_light.light_color = Color("ffa850")
	gate_light.omni_range = 28.0
	gate_light.light_energy = 2.0
	gate_light.position = Vector3(cx, cy + 4.0, gz + 3.0)
	add_child(gate_light)
	# büyük ocak
	var fx := cx
	var fz := cz - 6.0
	Dwarf.cyl(self, 5.2, 5.7, 1.3, m_stone, Vector3(fx, cy + 0.65, fz), 32)
	lava_mat = Dwarf.mat(Color.html("ff7a1f"), 0.0, 0.6, Color.html("ff6a10"), 3.5)
	var lava := Dwarf.cyl(self, 4.3, 4.3, 0.1, lava_mat, Vector3(fx, cy + 1.3, fz), 32)
	lava.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	forge_light = OmniLight3D.new()
	forge_light.light_color = Color("ff7a30")
	forge_light.omni_range = 34.0
	forge_light.light_energy = 3.0
	forge_light.position = Vector3(fx, cy + 3.5, fz)
	add_child(forge_light)
	for q in 6:
		var ca := float(q) / 6.0 * TAU
		var cpx := fx + cos(ca) * 5.6
		var cpz := fz + sin(ca) * 5.6
		Dwarf.box(self, Vector3(0.7, 2.6, 0.7), m_stone, Vector3(cpx, cy + 1.6, cpz))
		Dwarf.sph(self, 0.28, m_gold, Vector3(cpx, cy + 3.1, cpz))
	_add_obs(fx, fz, 5.9)
	# dev örs
	var an := Node3D.new()
	an.position = Vector3(cx + 9.0, cy + 0.05, cz - 6.0)
	an.rotation.y = -0.6
	an.scale = Vector3.ONE * 2.4
	add_child(an)
	var am := Dwarf.mat(Color.html("3a3f47"), 0.7, 0.45)
	Dwarf.box(an, Vector3(0.8, 0.5, 1.6), am, Vector3(0, 0.75, 0))
	Dwarf.box(an, Vector3(0.5, 0.3, 0.6), am, Vector3(0, 1.1, 0.9))
	Dwarf.box(an, Vector3(0.6, 0.6, 0.6), m_wood, Vector3(0, 0.3, 0))
	_add_obs(cx + 9.0, cz - 6.0, 2.2)
	# kral heykeli
	var statue := Dwarf.make_dwarf({"helm": true})
	var st_m := Dwarf.mat(Color.html("8a8782"), 0.0, 0.9)
	for n in _all_meshes(statue):
		n.material_override = st_m
	statue.scale *= 3.4
	statue.position = Vector3(cx, cy + 1.6, cz + 9.0)
	statue.rotation.y = PI
	add_child(statue)
	Dwarf.box(self, Vector3(5, 1.7, 5), m_stone, Vector3(cx, cy + 0.85, cz + 9.0))
	Dwarf.box(self, Vector3(5.3, 0.3, 5.3), m_gold, Vector3(cx, cy + 1.7, cz + 9.0))
	_add_obs(cx, cz + 9.0, 3.0)
	# dağ salonu girişi
	var hz := cz - 21.0
	for sd in [-1.0, 1.0]:
		Dwarf.box(self, Vector3(3.2, 17, 3.2), m_stone, Vector3(cx + sd * 5.8, cy + 8.5, hz))
		for yy in [3.0, 8.0, 13.0]:
			Dwarf.box(self, Vector3(3.5, 0.5, 3.5), m_gold, Vector3(cx + sd * 5.8, cy + yy, hz))
		_add_obs(cx + sd * 5.8, hz, 2.2)
	Dwarf.box(self, Vector3(15, 3.2, 3.4), m_stone, Vector3(cx, cy + 16.6, hz))
	Dwarf.box(self, Vector3(15.4, 0.5, 3.7), m_gold, Vector3(cx, cy + 14.8, hz))
	Dwarf.box(self, Vector3(9, 15, 1), Dwarf.mat(Color.html("14100e"), 0.0, 0.9), Vector3(cx, cy + 7.5, hz - 1.4))
	var glow := Dwarf.mat(Color.html("ff8a2a"), 0.0, 0.7, Color.html("ff7a1a"), 2.5)
	var hg := Dwarf.box(self, Vector3(7.6, 11, 0.1), glow, Vector3(cx, cy + 6.5, hz - 0.8))
	hg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var back := Dwarf.mat(Color.html("7d89ac"), 0.0, 0.95)
	for p in [[-26, -112], [0, -118], [28, -110]]:
		_cone_mi(30.0, 62.0, back, Vector3(p[0], 24, p[1]), false, 7)
		_cone_mi(12.0, 22.0, m_snow, Vector3(p[0], 48, p[1]), false, 7)
	_make_portal(cx + 16.0, cz + 10.0, Color("6aa0ff"), "swamp", 0.0, 17.0, PI, "Sisli Bataklık (Sv 8+)")
	_make_portal(cx - 16.0, cz + 10.0, Color("ff9a3a"), "mine", 0.0, 76.0, PI, "Kara Demir Madeni (Sv 12+)")
	_prop("castle", "siege-catapult", cx - 14.0, cz + 15.0, 0.6, 4.2, 2.0, Color(1.0, 0.95, 0.9))
	_prop("castle", "siege-ballista", cx + 14.0, cz + 15.0, -0.6, 4.2, 1.5, Color(1.0, 0.95, 0.9))
	_prop("survival", "barrel", cx - 8.0, cz + 17.0, 0.0, 3.6, 0.6)
	_prop("survival", "barrel", cx + 8.0, cz + 17.0, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", cx + 17.0, cz + 2.0, 0.3, 3.6, 0.7)
	_prop("fantasy-town", "cart", cx - 17.0, cz - 3.0, 1.2, 3.6, 1.4)
	# tezgâhlar
	_stall(cx - 10.0, cz + 4.0, 0.35, Color.html("b8302a"), Color.html("e6d3a0"))
	_stall(cx + 11.0, cz + 3.0, -0.35, Color.html("2a55b8"), Color.html("e6d3a0"))
	_stall(cx - 13.0, cz - 8.0, 1.2, Color.html("3a8a4a"), Color.html("e6d3a0"))
	# fener direkleri
	var lamp := Dwarf.mat(Color.html("ffc060"), 0.0, 0.5, Color.html("ffb040"), 4.0)
	for l in 7:
		var la := float(l) / 7.0 * TAU + 0.2
		var lx := cx + cos(la) * 14.5
		var lz := cz + sin(la) * 14.5
		if Vector2(lx - cx, lz - (cz + R)).length() < 6.0:
			continue
		Dwarf.cyl(self, 0.1, 0.14, 3.4, m_bronze, Vector3(lx, cy + 1.75, lz), 6)
		var lb := Dwarf.sph(self, 0.34, lamp, Vector3(lx, cy + 3.6, lz))
		lb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _all_meshes(n: Node) -> Array:
	var out: Array = []
	for c in n.get_children():
		if c is MeshInstance3D:
			out.append(c)
		out.append_array(_all_meshes(c))
	return out

func _stall(x: float, z: float, rot: float, c1: Color, c2: Color) -> void:
	var g := Node3D.new()
	g.position = Vector3(x, CITY.y + 0.05, z)
	g.rotation.y = rot
	add_child(g)
	Dwarf.box(g, Vector3(3.4, 1.0, 1.4), m_wood, Vector3(0, 0.5, 0))
	for px in [-1.6, 1.6]:
		Dwarf.cyl(g, 0.08, 0.08, 3.2, m_wood, Vector3(px, 1.6, -0.6), 6)
	for k in 6:
		var m := Dwarf.mat(c1 if k % 2 == 1 else c2, 0.0, 0.9)
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
		var st := Dwarf.box(g, Vector3(0.62, 0.04, 2.0), m, Vector3(-1.55 + k * 0.62, 3.0, -0.1))
		st.rotation.x = 0.55
	Dwarf.cyl(g, 0.4, 0.4, 0.8, m_wood, Vector3(2.4, 0.4, 0.8), 10)
	_add_obs(x, z, 1.9)

# ---------- oyuncu, NPC, canavarlar ----------
func _spawn_player() -> void:
	player = Dwarf.make_dwarf()
	add_child(player)
	rig = player.get_meta("rig")
	P = {"x": 0.0, "z": 7.0, "y": 0.0, "yaw": PI, "hp": 0.0, "rage": 0.0, "lvl": 1, "xp": 0.0,
		"atk_t": 0.0, "gcd": 0.0, "cd": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], "rk_t": 0.0, "bst_t": 0.0, "bst_tick": 0.0, "tal": {}, "prof": {}, "rep": {}, "stats": {}, "ach": {}, "skl": {}, "perks": {}, "lore": {}, "talked": {}, "walls": {}, "shout_sel": "force", "pity": 0, "disc": {}, "shout_cd": 0.0, "skin_t": 0.0, "skin_red": 0.0, "vy": 0.0, "jy": 0.0, "bs_t": 0.0, "sb_t": 0.0, "charge": null, "charge_t": 0.0, "spin": 0.0, "pot_cd": 0.0, "target": null, "auto": false,
		"dead": false, "dead_t": 0.0, "combat_t": -99.0, "spd": 0.0, "wep_b": 0.0, "wep_lvl": 0, "dot_t": 0.0, "dot_v": 0.0, "dot_k": 0.0, "slow_t": 0.0, "combo": 0, "combo_t": -99.0}
	inv = Inv.new()
	_mm_setup()
	G = Items.totals(inv.eq)
	WowAssets.refresh_equipment(player, inv.eq)
	P["hp"] = float(max_hp())

func base_str() -> int:
	return 12 + 2 * P["lvl"]

func base_agi() -> int:
	return 6 + P["lvl"] + roundi(Skills.perk_sum(P["perks"], "agi"))

func base_sta() -> int:
	return 10 + 2 * P["lvl"]

func max_hp() -> int:
	return roundi((110 + 28 * (P["lvl"] - 1) + 7 * G["sta"]) * (1.0 + 0.03 * trk("pro_hp") + Skills.perk_sum(P["perks"], "hp")))

func atk() -> float:
	var wd: float = (G["wmin"] + G["wmax"]) * 0.5 / G["wspd"] * 1.5
	return (wd + (base_str() + G["str"]) * 0.35 + P["lvl"] * 1.6 + P["wep_b"]) * (1.25 if P["bs_t"] > 0.0 else 1.0) * (1.5 if P["rk_t"] > 0.0 else 1.0) * (1.0 + 0.03 * trk("arm_dmg") + 0.004 * skl("onehand") + Skills.perk_sum(P["perks"], "dmg"))

func crit_chance() -> float:
	return 0.08 + (base_agi() + G["agi"]) * 0.003 + G["crit"] * 0.01 + 0.02 * trk("arm_crit") + Skills.perk_sum(P["perks"], "crit")

func armor_total() -> float:
	return (G["armor"] * 0.5 + P["lvl"] * 1.5) * (1.0 + 0.05 * trk("pro_armor") + 0.005 * skl("heavy") + Skills.perk_sum(P["perks"], "armor"))

func potion_count() -> int:
	return inv.count("pot_heal") + inv.count("pot_big")

## Eşya/seviye değişince istatistikleri ve pencereleri yenile.
## Takım bonusu aktifken karakterin ayağında dönen bir halka, ışık ve (3. kademede) kıvılcımlar.
const SET_AURA_COLORS := {"deep": "66aaff", "ash": "ff6a2a", "king": "ffd24a"}

func _update_set_aura() -> void:
	if player == null:
		return
	var best := ""
	var tier := 0
	for k in Items.SETS:
		var have := Items.set_count(k, inv.eq)
		var t := 0
		for b in Items.SETS[k]["bonus"]:
			if have >= int(b["n"]):
				t += 1
		if t > tier:
			tier = t
			best = k
	var key := "%s%d" % [best, tier]
	if key == set_aura_key and (tier == 0 or is_instance_valid(set_aura)):
		return
	set_aura_key = key
	if is_instance_valid(set_aura):
		set_aura.queue_free()
	set_aura = null
	if tier == 0:
		return
	var col := Color(SET_AURA_COLORS.get(best, "ffffff"))
	set_aura = Node3D.new()
	set_aura.name = "SetAura"
	player.add_child(set_aura)
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.78
	tm.outer_radius = 0.86
	ring.mesh = tm
	ring.position = Vector3(0, 0.06, 0)
	ring.material_override = Dwarf.mat(col, 0.0, 0.4, col, 1.4 + 0.5 * float(tier))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	set_aura.add_child(ring)
	var tw := set_aura.create_tween().set_loops()
	tw.tween_property(ring, "rotation:y", TAU, 6.0 - float(tier))
	if tier >= 2:
		var li := OmniLight3D.new()
		li.light_color = col
		li.light_energy = 0.5 + 0.2 * float(tier)
		li.omni_range = 4.0
		li.position = Vector3(0, 1.0, 0)
		li.shadow_enabled = false
		set_aura.add_child(li)
	if tier >= 3:
		var sp := CPUParticles3D.new()
		sp.amount = 20
		sp.lifetime = 1.6
		sp.direction = Vector3.UP
		sp.spread = 20.0
		sp.initial_velocity_min = 0.6
		sp.initial_velocity_max = 1.2
		sp.gravity = Vector3.ZERO
		sp.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		sp.emission_sphere_radius = 0.7
		var sm := SphereMesh.new()
		sm.radius = 0.035
		sm.height = 0.07
		sp.mesh = sm
		sp.material_override = Dwarf.mat(col, 0.0, 0.4, col, 3.0)
		sp.position = Vector3(0, 0.3, 0)
		set_aura.add_child(sp)

func inv_changed() -> void:
	G = Items.totals(inv.eq)
	if mm != null:
		mm.sync_inventory(inv.bag, inv.money)
	WowAssets.refresh_equipment(player, inv.eq)
	_update_set_aura()
	if P.has("hp"):
		P["hp"] = minf(P["hp"], float(max_hp()))
	if invui != null:
		invui.refresh()
	if talui != null:
		talui.refresh()
	if progui != null:
		progui.refresh()
	if hud != null and mode == "play" and P.has("ach"):
		ach_check()

func talent_def(id: String) -> Dictionary:
	for td in TALENTS:
		if td["id"] == id:
			return td
	return {}

func skl(id: String) -> int:
	return Skills.level_of(P["skl"], id)

## Beceriye kullanım tecrübesi ekler; seviye atlayınca haber verir.
func skill_xp(id: String, amt: float) -> void:
	if Skills.add_xp(P["skl"], id, amt) > 0:
		var nm: String = Skills.SKILLS[id]["name"]
		var lv := skl(id)
		hud.say("%s becerisi arttı: %d" % [nm, lv], Color("9be8a8"))
		sfx.play("quest", -8)
		if lv % 10 == 0 and Skills.points_free(P["lvl"], P["skl"], P["perks"]) > 0:
			hud.say("Yeni perk seçebilirsin! (K › Beceriler)", Color("f2c75c"))
		if progui != null:
			progui.refresh()

func take_perk(id: String) -> void:
	var why: String = Skills.can_take(P["lvl"], P["skl"], P["perks"], id)
	if why != "":
		hud.say(why, Color("ff9a8a"))
		return
	P["perks"][id] = true
	hud.say("Perk alındı: %s" % Skills.perk_def(id)["name"], Color("f2c75c"))
	sfx.play("quest")
	P["hp"] = minf(P["hp"], float(max_hp()))
	inv_changed()
	save_game()

func trk(id: String) -> int:
	return int(P["tal"].get(id, 0))

func tal_tree_pts(tree: int) -> int:
	var n := 0
	for td in TALENTS:
		if td["tree"] == tree:
			n += trk(td["id"])
	return n

func tal_spent() -> int:
	return tal_tree_pts(0) + tal_tree_pts(1) + tal_tree_pts(2)

func tal_points() -> int:
	return maxi(0, P["lvl"] - 9) - tal_spent()

func tal_can(id: String) -> bool:
	var td := talent_def(id)
	return tal_points() > 0 and trk(id) < td["max"] and tal_tree_pts(td["tree"]) >= td["row"] * 2

func tal_learn(id: String) -> void:
	if not tal_can(id):
		return
	P["tal"][id] = trk(id) + 1
	sfx.play("click", -4)
	inv_changed()
	save_game()

func tal_reset_cost() -> int:
	return P["lvl"] * 1500

func tal_reset() -> void:
	if tal_spent() == 0:
		return
	var cost := tal_reset_cost()
	if inv.money < cost:
		hud.say("Sıfırlamak için yeterli paran yok.", Color("ff6a5a"))
		return
	inv.money -= cost
	P["tal"] = {}
	sfx.play("coin")
	inv_changed()
	save_game()

func xp_need(l: int) -> float:
	if l >= 10:
		return 450.0 + (l - 9) * 180.0
	return 50.0 + 40.0 * l

const NPCDEF := [
	{"id": "ragna", "name": "Avcı Başı Ragna", "title": "Kurt Avı", "role": "quest", "qs": ["q_wolf", "q_trogg", "q_grik", "q_arc"], "x": -3.5, "z": 6.5, "face": 0.9,
		"o": {"beard": Color("8a5a2b"), "cloth": Color("2f6b3a"), "metal": Color("6f7d68"), "helm": false, "prop": "spear"}},
	{"id": "gundri", "name": "Bankacı Gundri", "title": "Banka", "role": "bank", "x": 10.5, "z": -49.0, "face": -0.9,
		"o": {"beard": Color("c9a24a"), "cloth": Color("2a4a6a"), "metal": Color("c9b068"), "helm": false, "prop": "none"}},
	{"id": "kelda", "name": "Han Sahibi Kelda", "title": "Han", "role": "inn", "x": -5.2, "z": 14.5, "face": 0.3,
		"o": {"beard": Color("e9e4d6"), "cloth": Color("7a5230"), "metal": Color("8d8472"), "helm": false, "prop": "none"}},
	{"id": "dorn", "name": "Muhafız Dorn", "title": "Kapı Muhafızı", "role": "quest", "qs": ["q_boar", "q_gnoll", "q_chok", "q_hogger"], "x": 5.2, "z": -40.5, "face": 0.0,
		"o": {"beard": Color("4a2b18"), "cloth": Color("1d3b86"), "metal": Color("9aa8c0"), "helm": true, "prop": "axe"}},
	{"id": "hilda", "name": "Tüccar Hilda", "title": "Tüccar", "role": "vendor", "x": -10.0, "z": -51.8, "face": 0.35,
		"o": {"beard": Color("dbb46a"), "cloth": Color("8e2f4a"), "metal": Color("b09060"), "helm": false, "prop": "none"}},
	{"id": "borga", "name": "Demirci Borga", "title": "Silah Ustası", "role": "smith", "x": 5.2, "z": -59.5, "face": -2.4,
		"o": {"beard": Color("2e2018"), "cloth": Color("5a3a22"), "metal": Color("6a6f78"), "helm": false, "prop": "hammer", "skin": Color("d69a74")}},
	{"id": "durin", "name": "Madenci Başı Durin", "title": "Kara Demir Madeni", "role": "quest", "qs": ["q_mine1", "q_mine2", "q_mine3", "q_dungeon1", "q_dungeon2"], "x": -10.5, "z": -46.0, "face": 0.8,
		"o": {"beard": Color("5a3a22"), "cloth": Color("6a4a22"), "metal": Color("8a8a90"), "helm": true, "prop": "hammer"}},
	{"id": "thrum", "name": "Komutan Thrum", "title": "Dağ Komutanı", "role": "quest", "qs": ["q_bear", "q_defias", "q_dark", "q_vc", "q_rag"], "x": -4.0, "z": -73.5, "face": 0.0,
		"o": {"beard": Color("aab0b8"), "cloth": Color("8a1f1f"), "metal": Color("c0c8d4"), "helm": true, "prop": "axe"}},
]

# ---------- günlük hayat: başıboş dolaşan süs köylüleri (etkileşimsiz) ----------
const AMB_NPCS := [
	{"id": "amb_tomas", "name": "Köylü Tomas", "title": "Demirkazan Sakini", "role": "amb", "x": 2.0, "z": 3.0, "face": 0.0, "wr": 5.5,
		"o": {"beard": Color("8a6a4a"), "cloth": Color("4a6a3a"), "metal": Color("8a8a8a"), "helm": false, "prop": "none"}},
	{"id": "amb_greta", "name": "Köylü Greta", "title": "Demirkazan Sakini", "role": "amb", "x": -6.0, "z": -2.0, "face": 1.2, "wr": 4.5,
		"o": {"beard": Color("c9b068"), "cloth": Color("7a3a4a"), "metal": Color("8a8a8a"), "helm": false, "prop": "none"}},
	{"id": "amb_borin", "name": "Köylü Borin", "title": "Demirkazan Sakini", "role": "amb", "x": 8.0, "z": 7.0, "face": 2.0, "wr": 5.0,
		"o": {"beard": Color("5a4a3a"), "cloth": Color("3a4a6a"), "metal": Color("8a8a8a"), "helm": false, "prop": "none"}},
]

func _update_amb_npcs(delta: float) -> void:
	if mode != "play" or map != "snow":
		return
	for n in npcs:
		if n["role"] != "amb":
			continue
		var ph: float = n.get("wander_t", randf() * TAU) + delta * 0.18
		n["wander_t"] = ph
		var cx: float = n.get("wander_cx", n["x"])
		var cz: float = n.get("wander_cz", n["z"])
		if not n.has("wander_cx"):
			n["wander_cx"] = cx
			n["wander_cz"] = cz
		var r: float = float(n.get("wr", 4.0))
		var nx := cx + cos(ph) * r
		var nz := cz + sin(ph * 0.7) * r
		var dx: float = nx - float(n["x"])
		var dz: float = nz - float(n["z"])
		if absf(dx) > 0.001 or absf(dz) > 0.001:
			n["node"].rotation.y = lerp_angle(n["node"].rotation.y, atan2(dx, dz), 0.08)
		n["x"] = nx
		n["z"] = nz
		n["y"] = height_at(nx, nz)
		n["node"].position = Vector3(nx, n["y"], nz)

# ---------- görev yön işaretleri (WoW tarzı waypoint) ----------
const MAP_LINKS := {"snow": ["swamp", "mine"], "swamp": ["snow", "ash"], "mine": ["snow"], "ash": ["swamp", "snow"]}

## from_map'ten to_map'e giderken ilk geçilecek harita (portal hedefi); bulunamazsa ""
func _next_hop(from_map: String, to_map: String) -> String:
	if from_map == to_map:
		return ""
	var prev := {from_map: ""}
	var queue: Array = [from_map]
	while not queue.is_empty():
		var cur: String = queue.pop_front()
		for nx in MAP_LINKS.get(cur, []):
			if prev.has(nx):
				continue
			prev[nx] = cur
			if nx == to_map:
				var hop: String = nx
				while prev[hop] != from_map:
					hop = prev[hop]
				return hop
			queue.append(nx)
	return ""

func _kill_map(nm: String) -> String:
	for id in BOSSES:
		if BOSSES[id]["name"] == nm:
			return BOSSES[id].get("map", "snow")
	for pair in [[MTYPES, "snow"], [SWAMP_MTYPES, "swamp"], [MINE_MTYPES, "mine"], [ASH_MTYPES, "ash"]]:
		for k in pair[0]:
			if pair[0][k]["name"] == nm:
				return pair[1]
	return "snow"

func _giver_info(qid: String) -> Dictionary:
	for pair in [[NPCDEF, "snow"], [SWAMP_NPCS, "swamp"], [ASH_NPCS, "ash"]]:
		for d in pair[0]:
			if d.get("qs", []).has(qid):
				return {"map": pair[1], "x": d["x"], "z": d["z"], "name": d["name"]}
	return {}

## Aranan düşmanın bu haritadaki en yakın yeri (canlı yoksa yeniden doğma noktası); yoksa Vector2(1e9, 0)
func _nearest_target(nm: String) -> Vector2:
	var best := Vector2(1e9, 0.0)
	var bd := 1e9
	var best_dead := Vector2(1e9, 0.0)
	var bdd := 1e9
	for m in mobs:
		if m.nm != nm or m.temp:
			continue
		if m.dead:
			var dd := Vector2(m.hx - P["x"], m.hz - P["z"]).length()
			if dd < bdd:
				bdd = dd
				best_dead = Vector2(m.hx, m.hz)
		else:
			var d2 := Vector2(m.x - P["x"], m.z - P["z"]).length()
			if d2 < bd:
				bd = d2
				best = Vector2(m.x, m.z)
	return best if best.x < 1e8 else best_dead

## Etkin görevler için işaret listesi: {p: Vector2 (dünya), label, kind: kill|turn, qid}
func _quest_waypoints() -> Array:
	var out: Array = []
	for qid in qs:
		var st: String = qs[qid]["st"]
		if (st != "active" and st != "ready") or not QUESTS.has(qid):
			continue
		var q: Dictionary = QUESTS[qid]
		var tmap := ""
		var pos := Vector2.ZERO
		var label := ""
		var kind := "kill"
		if st == "ready":
			var g := _giver_info(qid)
			if g.is_empty():
				continue
			tmap = g["map"]
			pos = Vector2(g["x"], g["z"])
			label = g["name"]
			kind = "turn"
		else:
			tmap = _kill_map(q["kill"])
			label = q["kill"]
			if tmap == map:
				pos = _nearest_target(q["kill"])
				if pos.x > 1e8:
					continue
		if tmap != map:
			var hop := _next_hop(map, tmap)
			var found := false
			for pt in portals:
				if pt["to"] == hop:
					pos = Vector2(pt["x"], pt["z"])
					label = "%s (portal)" % label
					found = true
					break
			if not found:
				continue
		out.append({"qid": qid, "p": pos, "label": label, "kind": kind})
	return out

## Dünya konumlarını ekran işaretlerine çevirir (ekranın dışındaysa kenara sıkıştırır)
func _waypoint_screen(wps: Array) -> Array:
	var vs := get_viewport().get_visible_rect().size
	var c := vs * 0.5
	var half := c - Vector2(34.0, 52.0)
	var res: Array = []
	for w in wps:
		var wx: float = w["p"].x
		var wz: float = w["p"].y
		var d := Vector2(wx - P["x"], wz - P["z"]).length()
		var wp3 := Vector3(wx, height_at(wx, wz) + 5.0, wz)
		var local := cam.global_transform.affine_inverse() * wp3
		var behind := cam.is_position_behind(wp3)
		var sp := cam.unproject_position(wp3)
		var inside := not behind and sp.x > 34.0 and sp.x < vs.x - 34.0 and sp.y > 52.0 and sp.y < vs.y - 52.0
		var rot := 0.0
		if not inside:
			var dir := Vector2(local.x, -local.y)
			if dir.length() < 0.001:
				dir = Vector2(0, 1)
			dir = dir.normalized()
			var k := minf(half.x / maxf(absf(dir.x), 0.0001), half.y / maxf(absf(dir.y), 0.0001))
			sp = c + dir * k
			rot = dir.angle() + PI / 2.0
		res.append({"pos": sp, "edge": not inside, "rot": rot, "dist": d, "label": w["label"], "kind": w["kind"]})
	return res

func _npc_defs() -> Array:
	match map:
		"mine": return []
		"swamp": return SWAMP_NPCS
		"ash": return ASH_NPCS
	return NPCDEF + AMB_NPCS

func _rep_key() -> String:
	return {"snow": "dem", "swamp": "kar", "mine": "mad", "ash": "kul"}.get(map, "dem")

func _spawn_npcs() -> void:
	for d in _npc_defs():
		var n: Dictionary = d.duplicate()
		var node := Dwarf.make_dwarf(d["o"])
		var inside_city: bool = map == "snow" and d["z"] < CITY.z + 22.0
		n["y"] = height_at(d["x"], d["z"]) + (0.05 if inside_city else 0.0)
		node.position = Vector3(d["x"], n["y"], d["z"])
		node.rotation.y = d["face"]
		add_child(node)
		n["node"] = node
		if d["role"] == "quest":
			var lb := Label3D.new()
			lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			lb.font_size = 220
			lb.pixel_size = 0.006
			lb.outline_size = 36
			lb.outline_modulate = Color("3a2a00")
			lb.modulate = Color("ffd23a")
			lb.no_depth_test = true
			lb.fixed_size = false
			lb.position = Vector3(0, 3.1, 0)
			lb.visible = false
			node.add_child(lb)
			n["mark3d"] = lb
		npcs.append(n)
		_add_obs(d["x"], d["z"], 0.7)

func _spawn_mobs() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 77
	if map == "mine" or map == "ash":
		return
	if map == "swamp":
		_spawn_swamp_mobs(rnd)
		return
	var kinds := ["wolf", "wolf", "boar", "wolf", "boar", "bear"]
	var n := 0
	var tries := 0
	while n < 30 and tries < 2000:
		tries += 1
		var a := rnd.randf() * TAU
		var r := 22.0 + rnd.randf() * 62.0
		var x := cos(a) * r
		var z := sin(a) * r
		var blocked := false
		for o in obs:
			if Vector2(o.x - x, o.y - z).length() < o.z + 1.5:
				blocked = true
				break
		if blocked or Vector2(x - CITY.x, z - CITY.z).length() < 30.0:
			continue
		var kind: String = kinds[rnd.randi() % kinds.size()]
		var ty: Dictionary = MTYPES[kind]
		var lvl := clampi(roundi(ty.lo + (r - 22.0) / 62.0 * (ty.hi - ty.lo + 1) - 0.3 + rnd.randf() * 0.8), ty.lo, ty.hi)
		var m := Mob.new()
		m.kind = kind
		m.nm = ty.name
		m.lvl = lvl
		m.x = x
		m.z = z
		m.hx = x
		m.hz = z
		m.wx = x
		m.wz = z
		m.yaw = rnd.randf() * 6.0
		m.maxhp = round(ty.hp * (1.0 + (lvl - 1) * 0.55))
		m.hp = m.maxhp
		m.dmg = ty.dmg * (1.0 + lvl * 0.55)
		m.spd = ty.spd
		m.aggro = ty.aggro
		m.rad = ty.rad
		m.sc = ty.sc
		m.w_t = rnd.randf() * 4.0
		m.ph = rnd.randf() * 6.0
		m.id = n
		match kind:
			"wolf": m.node = WowAssets.spawn_creature("wolf", func(): return Dwarf.make_wolf())
			"boar": m.node = WowAssets.spawn_creature("boar", func(): return Dwarf.make_boar())
			"bear": m.node = WowAssets.spawn_creature("bear", func(): return Dwarf.make_bear())
			_: m.node = Dwarf.make_bear()
		m.node.scale = Vector3.ONE * m.sc
		m.legs = m.node.get_meta("legs", [])
		add_child(m.node)
		mobs.append(m)
		n += 1

func _mtype(kind: String) -> Dictionary:
	if ASH_MTYPES.has(kind):
		return ASH_MTYPES[kind]
	if MINE_MTYPES.has(kind):
		return MINE_MTYPES[kind]
	return SWAMP_MTYPES[kind] if SWAMP_MTYPES.has(kind) else MTYPES[kind]

func _spawn_swamp_mobs(rnd: RandomNumberGenerator) -> void:
	var kinds := ["croc", "croc", "bog", "croc", "murloc", "bog"]
	var n := 0
	var tries := 0
	while n < 26 and tries < 2000:
		tries += 1
		var a := rnd.randf() * TAU
		var r := 24.0 + rnd.randf() * 58.0
		var x := cos(a) * r
		var z := sin(a) * r
		var blocked := false
		for o in obs:
			if Vector2(o.x - x, o.y - z).length() < o.z + 1.5:
				blocked = true
				break
		if blocked:
			continue
		var kind: String = kinds[rnd.randi() % kinds.size()]
		var ty: Dictionary = SWAMP_MTYPES[kind]
		var lvl := rnd.randi_range(ty["lo"], ty["hi"])
		var mb := Mob.new()
		mb.kind = kind
		mb.nm = ty["name"]
		mb.lvl = lvl
		mb.x = x
		mb.z = z
		mb.hx = x
		mb.hz = z
		mb.wx = x
		mb.wz = z
		mb.yaw = rnd.randf() * 6.0
		mb.maxhp = round(ty["hp"] * (1.0 + (lvl - 1) * 0.55))
		mb.hp = mb.maxhp
		mb.dmg = ty["dmg"] * (1.0 + lvl * 0.55)
		mb.spd = ty["spd"]
		mb.aggro = ty["aggro"]
		mb.rad = ty["rad"]
		mb.sc = ty["sc"]
		mb.ranged = ty.get("ranged", 0.0)
		mb.w_t = rnd.randf() * 4.0
		mb.ph = rnd.randf() * 6.0
		mb.id = n
		mb.node = _camp_model(kind)
		mb.node.scale = Vector3.ONE * mb.sc
		mb.legs = _humanoid_legs(mb.node)
		add_child(mb.node)
		mb.node.position = Vector3(mb.x, height_at(mb.x, mb.z), mb.z)
		mobs.append(mb)
		n += 1

func _free_spot(x: float, z: float) -> Vector2:
	for i in 60:
		var a := float(i) * 2.4
		var r := float(i) * 0.5
		var px := x + cos(a) * r
		var pz := z + sin(a) * r
		var ok := true
		for o in obs:
			if Vector2(o.x - px, o.y - pz).length() < o.z + 2.5:
				ok = false
				break
		if ok:
			return Vector2(px, pz)
	return Vector2(x, z)

func _make_boss_model(id: String) -> Node3D:
	match id:
		"arctikus": return WowAssets.spawn_creature("bear", func(): return Dwarf.make_bear({"fur": Color("e8eef4"), "dk": Color("9aa8b8"), "lt": Color("ffffff")}))
		"grik": return WowAssets.spawn_creature("trogg", func(): return Dwarf.make_trogg(true))
		"choksul": return WowAssets.spawn_creature("ashogre", func(): return Dwarf.make_ogre())
		"hogger": return WowAssets.spawn_creature("gnoll", func(): return Dwarf.make_gnoll(true))
		"vancleef": return WowAssets.spawn_creature("defias", func(): return Dwarf.make_dwarf({"skin": Color("e8c0a0"), "metal": Color("5a2a2a"), "cloth": Color("a32a2a"), "beard": Color("2a1a10"), "helm": false, "prop": "axe"}))
		"gruff": return WowAssets.spawn_creature("croc", func(): return Dwarf.make_croc(true))
		"gorduk": return WowAssets.spawn_creature("gorduk", func(): return Dwarf.make_golem(true))
		"thokk": return Dwarf.make_frost()
		"vurgan": return WowAssets.spawn_creature("vurgan", func(): return Dwarf.make_dwarf({"skin": Color("8a7060"), "metal": Color("2a2a30"), "cloth": Color("a32a1a"), "beard": Color("c8402a"), "helm": true, "prop": "hammer"}))
		"golemagg": return WowAssets.spawn_creature("golemagg", func(): return _tint_model(Dwarf.make_golem(true), Color("d4501a"), 0.45, 0.6))
		"geddon": return WowAssets.spawn_creature("geddon", func(): return Dwarf.make_ember())
		"sulfuron": return WowAssets.spawn_creature("sulfuron", func(): return _tint_model(Dwarf.make_ogre(), Color("8a2a1a"), 0.6, 0.3))
		"ragnaros": return WowAssets.spawn_creature("ragnaros", func(): return Dwarf.make_ragnaros())
		"kezan": return WowAssets.spawn_creature("kezan", func(): return Dwarf.make_dwarf({"skin": Color("6a5448"), "metal": Color("4a4a52"), "cloth": Color("2a3a4a"), "beard": Color("1a1410"), "helm": true, "prop": "axe"}))
		"modrek": return WowAssets.spawn_creature("modrek", func(): return _tint_model(Dwarf.make_golem(true), Color("c8a030"), 0.5, 0.4))
		_: return Dwarf.make_ragnaros()

## Modelin malzemelerini renge doğru kaydırır (kopya malzeme)
func _tint_model(node: Node3D, col: Color, amt: float, glow: float = 0.0) -> Node3D:
	var cache := {}
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var inst := mi as MeshInstance3D
		var mt: Material = inst.material_override
		if mt == null:
			mt = inst.get_active_material(0)
		if mt is StandardMaterial3D and not (mt as StandardMaterial3D).emission_enabled:
			if not cache.has(mt):
				var sm: StandardMaterial3D = mt.duplicate()
				sm.albedo_color = sm.albedo_color.lerp(col, amt)
				if glow > 0.0:
					sm.emission_enabled = true
					sm.emission = col
					sm.emission_energy_multiplier = glow
				cache[mt] = sm
			inst.material_override = cache[mt]
	return node

func _humanoid_legs(node: Node3D) -> Array:
	if node.has_meta("legs"):
		return node.get_meta("legs")
	var rig: Dictionary = node.get_meta("rig", {})
	if rig.has("legL") and rig.has("legR"):
		return [rig["legL"], rig["legR"], rig["legR"], rig["legL"]]
	# Imported Skeleton3D scenes animate themselves; they do not expose
	# the procedural limb metadata used by the old hand-built models.
	return []

func _spawn_bosses() -> void:
	var i := 0
	for id in BOSSES:
		var d: Dictionary = BOSSES[id]
		if d.get("map", "snow") != map:
			continue
		var m := Mob.new()
		var sp := Vector2(d["x"], d["z"]) if id == "ragnaros" else _free_spot(d["x"], d["z"])
		m.boss = id
		m.kind = d["kind"]
		m.nm = d["name"]
		m.title = d["title"]
		m.lvl = d["lvl"]
		m.x = sp.x
		m.z = sp.y
		m.hx = sp.x
		m.hz = sp.y
		m.wx = sp.x
		m.wz = sp.y
		m.yaw = 0.0 if id != "ragnaros" else 0.0
		m.maxhp = d["hp"]
		m.hp = m.maxhp
		m.dmg = d["dmg"]
		m.base_dmg = m.dmg
		m.spd = d["spd"]
		m.base_spd = m.spd
		m.aggro = d["aggro"]
		m.rad = d["rad"]
		m.sc = d["sc"]
		m.reach = d.get("reach", 1.3)
		m.yoff = d.get("yoff", 0.0)
		m.respawn = d["respawn"]
		m.atk_int = 2.4
		m.id = 900 + i
		m.node = _make_boss_model(id)
		m.node.scale = Vector3.ONE * m.sc
		m.legs = _humanoid_legs(m.node)
		add_child(m.node)
		m.node.position = Vector3(m.x, height_at(m.x, m.z) + m.yoff, m.z)
		mobs.append(m)
		i += 1

func _camp_model(kind: String) -> Node3D:
	match kind:
		"trogg": return WowAssets.spawn_creature("trogg", func(): return Dwarf.make_trogg(false))
		"gnoll": return WowAssets.spawn_creature("gnoll", func(): return Dwarf.make_gnoll(false))
		"murloc": return Dwarf.make_murloc(false)
		"shaman": return Dwarf.make_murloc(true)
		"croc": return Dwarf.make_croc(false)
		"bog": return WowAssets.spawn_creature("bog", func(): return Dwarf.make_bogbeast())
		"cinder":
			var em := WowAssets.spawn_creature("cinder", func(): return Dwarf.make_ember())
			for l in em.find_children("*", "OmniLight3D", true, false):
				l.get_parent().remove_child(l)
				l.free()
			return em
		"slag": return WowAssets.spawn_creature("slag", func(): return _tint_model(Dwarf.make_golem(false), Color("8a3a22"), 0.5))
		"ashogre": return WowAssets.spawn_creature("ashogre", func(): return _tint_model(Dwarf.make_ogre(), Color("5a3a34"), 0.55))
		"ashbone": return WowAssets.spawn_creature("ashbone", func(): return _tint_model(Dwarf.make_skeleton(), Color("3a3030"), 0.6))
		"miner": return WowAssets.spawn_creature("miner", func(): return Dwarf.make_dwarf({"skin": Color("6a5448"), "metal": Color("3a3238"), "cloth": Color("4a3a2a"), "beard": Color("1a1410"), "helm": true, "prop": "hammer"}))
		"golem": return WowAssets.spawn_creature("golem", func(): return Dwarf.make_golem(false))
		"spider": return WowAssets.spawn_creature("spider", func(): return Dwarf.make_spider())
		"frost": return _tint_model(WowAssets.spawn_creature("frost_wolf", func(): return Dwarf.make_frost()), Color("b9d9ff"), 0.42)
		"skeleton": return WowAssets.spawn_creature("skeleton", func(): return Dwarf.make_skeleton())
		"guard": return WowAssets.spawn_creature("guard", func(): return Dwarf.make_dwarf({"skin": Color("7a6a6a"), "metal": Color("2a2226"), "cloth": Color("5a1a1a"), "beard": Color("101010"), "helm": true, "prop": "axe"}))
		"ironclad": return WowAssets.spawn_creature("ironclad", func(): return Dwarf.make_dwarf({"skin": Color("6a5a56"), "metal": Color("343038"), "cloth": Color("1a2a38"), "beard": Color("201812"), "helm": true, "prop": "hammer"}))
		"defias": return WowAssets.spawn_creature("defias", func(): return Dwarf.make_dwarf({"skin": Color("e0b898"), "metal": Color("4a3030"), "cloth": Color("8a2020"), "beard": Color("2a1a10"), "helm": false, "prop": "axe"}))
		"darkiron": return WowAssets.spawn_creature("darkiron", func(): return Dwarf.make_dwarf({"skin": Color("7a6a6a"), "metal": Color("2a2226"), "cloth": Color("3a1a1a"), "beard": Color("101010"), "helm": true, "prop": "hammer"}))
		_: return Dwarf.make_dwarf({"skin": Color("7a6a6a"), "metal": Color("2a2226"), "cloth": Color("3a1a1a"), "beard": Color("101010"), "helm": true, "prop": "hammer"})

func _camp_props() -> void:
	var tints := {"trogg": Color(0.8, 0.75, 0.7), "gnoll": Color(0.9, 0.8, 0.65), "defias": Color(0.85, 0.5, 0.45), "darkiron": Color(0.55, 0.5, 0.6), "frost": Color(0.7, 0.85, 1.0), "skeleton": Color(0.85, 0.85, 0.8),
		"murloc": Color(0.6, 0.8, 0.8), "shaman": Color(0.7, 0.6, 0.85), "bog": Color(0.6, 0.7, 0.5)}
	for c in camps_now:
		var cx: float = c["x"]
		var cz: float = c["z"]
		var t: Color = tints.get(c["kind"], Color(0.9, 0.85, 0.8))
		_prop("survival", "campfire-pit", cx, cz, 0.0, 6.0, 1.0, t)
		_flame(self, Vector3(cx, height_at(cx, cz) + 0.5, cz), 0.5)
		for i in 3:
			var a := 0.6 + i * 2.1
			_prop("survival", "tent", cx + cos(a) * 11.0, cz + sin(a) * 11.0, -a + PI / 2.0, 4.6, 1.6, t)
		_prop("survival", "barrel", cx + 4.5, cz + 3.0, 0.0, 3.6, 0.6, t)
		_prop("survival", "barrel", cx + 5.2, cz + 2.2, 0.0, 3.6, 0.6, t)
		_prop("survival", "box-large", cx - 4.0, cz + 4.5, 0.5, 3.6, 0.7, t)
		_prop("survival", "chest", cx - 3.0, cz - 5.0, 2.0, 3.4, 0.6, t)
		_prop("survival", "signpost", cx - 14.0, cz, 0.0, 4.0, 0.0, t)
		if c["kind"] == "gnoll" or c["kind"] == "darkiron":
			for i in 6:
				var fa := float(i) / 6.0 * TAU
				_prop("survival", "fence-fortified", cx + cos(fa) * 16.0, cz + sin(fa) * 16.0, -fa, 3.2, 0.0, t)

func _spawn_camps() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 311
	var cid := 200
	if map != "mine" and map != "ash":
		_camp_props()
	for c in camps_now:
		var ty: Dictionary = _mtype(c["kind"])
		for i in c["n"]:
			var a := rnd.randf() * TAU
			var spr: float = c.get("sp", 9.0)
			var sp := _free_spot(c["x"] + cos(a) * (2.0 + rnd.randf() * (spr - 2.0)), c["z"] + sin(a) * (2.0 + rnd.randf() * (spr - 2.0)))
			var lvl: int = rnd.randi_range(ty["lo"], ty["hi"])
			var m := Mob.new()
			m.kind = c["kind"]
			m.nm = ty["name"]
			m.lvl = lvl
			m.x = sp.x
			m.z = sp.y
			m.hx = sp.x
			m.hz = sp.y
			m.wx = sp.x
			m.wz = sp.y
			m.yaw = rnd.randf() * 6.0
			m.maxhp = round(ty["hp"] * (1.0 + (lvl - 1) * 0.55))
			m.hp = m.maxhp
			m.dmg = ty["dmg"] * (1.0 + lvl * 0.55)
			m.spd = ty["spd"]
			m.aggro = ty["aggro"]
			m.rad = ty["rad"]
			m.sc = ty["sc"]
			m.ranged = ty.get("ranged", 0.0)
			m.w_t = rnd.randf() * 4.0
			m.ph = rnd.randf() * 6.0
			m.id = cid
			cid += 1
			if SpawnDirector.is_rare_spawn(rnd.randf() * 0.7, P["lvl"]):
				m.rare = true
				m.title = "Nadir"
				m.maxhp = round(m.maxhp * SpawnDirector.rare_hp_multiplier())
				m.hp = m.maxhp
				m.dmg *= SpawnDirector.rare_damage_multiplier()
				m.lvl += 1
				m.sc *= 1.3
				m.rad *= 1.25
				m.aggro += 3.0
			elif m.lvl >= 3 and rnd.randf() < 0.06:
				# Elit: üç kat can, 1,5 kat hasar, altın parıltılı; üç kat ödül verir
				m.elite = true
				m.title = "Elit"
				m.maxhp = round(m.maxhp * 3.0)
				m.hp = m.maxhp
				m.dmg *= 1.5
				m.sc *= 1.25
				m.rad *= 1.2
				m.aggro += 2.0
			m.node = _camp_model(c["kind"])
			if m.elite:
				_tint_model(m.node, Color("ffcc33"), 0.22, 0.3)
			m.node.scale = Vector3.ONE * m.sc
			m.legs = _humanoid_legs(m.node)
			add_child(m.node)
			m.node.position = Vector3(m.x, height_at(m.x, m.z), m.z)
			mobs.append(m)

func spawn_add(owner_m, nm: String, model: String, lvl: int, hp: float, dmg: float, spd: float, sc: float, off: Vector2) -> void:
	var m := Mob.new()
	m.kind = "skull"
	m.nm = nm
	m.lvl = lvl
	m.x = owner_m.x + off.x
	m.z = owner_m.z + off.y
	m.hx = m.x
	m.hz = m.z
	m.wx = m.x
	m.wz = m.z
	m.maxhp = hp
	m.hp = hp
	m.dmg = dmg
	m.spd = spd
	m.aggro = 30.0
	m.rad = 0.7 * sc
	m.sc = sc
	m.temp = true
	m.owner_m = owner_m
	m.state = "chase"
	m.id = next_id
	next_id += 1
	match model:
		"gnoll": m.node = WowAssets.spawn_creature("gnoll", func(): return Dwarf.make_gnoll(false))
		"ember": m.node = WowAssets.spawn_creature("cinder", func(): return Dwarf.make_ember())
		"croc": m.node = Dwarf.make_croc(false)
		"golem": m.node = WowAssets.spawn_creature("golem", func(): return Dwarf.make_golem(false))
		"guard": m.node = WowAssets.spawn_creature("guard", func(): return Dwarf.make_dwarf({"skin": Color("7a6a6a"), "metal": Color("2a2226"), "cloth": Color("5a1a1a"), "beard": Color("101010"), "helm": true, "prop": "axe"}))
		_: m.node = Dwarf.make_dwarf({"skin": Color("e0b898"), "metal": Color("4a3030"), "cloth": Color("8a2020"), "beard": Color("2a1a10"), "helm": false, "prop": "axe"})
	m.node.scale = Vector3.ONE * sc
	m.legs = _humanoid_legs(m.node)
	add_child(m.node)
	m.node.position = Vector3(m.x, height_at(m.x, m.z), m.z)
	mobs.append(m)
	ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.5, Color("ffb060") if model == "ember" else Color("c9b8a0"), 0.5)

func _kit_mm(kit: String, nm: String, xfs: Array, tint: Color) -> void:
	var path := "res://assets/kenney/%s/%s.glb" % [kit, nm]
	if not ResourceLoader.exists(path):
		return
	var root: Node3D = (load(path) as PackedScene).instantiate()
	for mi in root.find_children("*", "MeshInstance3D", true, false):
		var t: Transform3D = (mi as Node3D).transform
		var p = mi.get_parent()
		while p != null and p != root:
			t = (p as Node3D).transform * t
			p = p.get_parent()
		var lx: Array = []
		for x in xfs:
			lx.append((x as Transform3D) * t)
		var mat := (mi as MeshInstance3D).get_active_material(0)
		var m2: Material = mat
		if mat is StandardMaterial3D:
			var sm: StandardMaterial3D = mat.duplicate()
			sm.albedo_color = sm.albedo_color * tint
			sm.roughness = 0.95
			m2 = sm
		_add_multimesh((mi as MeshInstance3D).mesh, m2, lx)
	root.free()

## Kara Demir Madeni: meşaleler, destek kirişleri, sarkıtlar, lav havuzları
func _build_mine() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 909
	var rock := Dwarf.mat(Color.html("3c3640"), 0.0, 0.95)
	var wood := Dwarf.mat(Color.html("6a4a2c"), 0.0, 0.9)
	var iron := Dwarf.mat(Color.html("3a3a42"), 0.4, 0.6)
	for t in _mine_torches():
		var tp := Vector3(t.x, height_at(t.x, t.y), t.y)
		var torch := _wow_spawn("modular_dungeon_pack/Torch.glb", tp + Vector3(0, 0.25, 0), 0.0, 1.35)
		if torch == null:
			Dwarf.box(self, Vector3(0.14, 1.5, 0.14), wood, tp + Vector3(0, 0.75, 0))
			Dwarf.box(self, Vector3(0.3, 0.12, 0.3), iron, tp + Vector3(0, 1.5, 0))
		_flame(self, tp + Vector3(0, 1.75, 0), 0.22)
	for i in range(1, MINE_ROOMS.size()):
		var r: Array = MINE_ROOMS[i]
		var li := OmniLight3D.new()
		li.light_color = Color("ffb070")
		li.omni_range = float(r[2]) * 1.9
		li.light_energy = 1.1
		li.position = Vector3(r[0], 5.0, r[1])
		add_child(li)
	mine_lantern = OmniLight3D.new()
	mine_lantern.light_color = Color("ffd9a0")
	mine_lantern.omni_range = 15.0
	mine_lantern.light_energy = 1.7
	add_child(mine_lantern)
	# lav havuzları (son oda)
	lava_mat = Dwarf.mat(Color.html("ff7a1f"), 0.0, 0.6, Color.html("ff6a10"), 3.5)
	for lp in [Vector2(-13.0, -77.0), Vector2(13.0, -77.0)]:
		var ly := height_at(lp.x, lp.y)
		Dwarf.cyl(self, 4.1, 4.3, 0.2, rock, Vector3(lp.x, ly + 0.05, lp.y), 20)
		var disc := Dwarf.cyl(self, 3.6, 3.6, 0.12, lava_mat, Vector3(lp.x, ly + 0.14, lp.y), 20)
		disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_add_obs(lp.x, lp.y, 4.0)
		var ll := OmniLight3D.new()
		ll.light_color = Color("ff6a20")
		ll.omni_range = 14.0
		ll.light_energy = 1.6
		ll.position = Vector3(lp.x, 2.0, lp.y)
		add_child(ll)
	# Mağara duvarlarındaki sarkıt ve dikitler: Quaternius modüler zindan kayaları.
	var cave_rock_groups: Dictionary = {}
	for i in MINE_ROOMS.size():
		var room: Array = MINE_ROOMS[i]
		for k in 9:
			var ang := rnd.randf() * TAU
			var rr := float(room[2]) - 1.2 - rnd.randf() * 3.0
			var px := float(room[0]) + cos(ang) * rr
			var pz := float(room[1]) + sin(ang) * rr
			if _mine_sd(px + cos(ang) * 3.5, pz + sin(ang) * 3.5) < -0.3:
				continue
			var h := 1.2 + rnd.randf() * 2.6
			var w := 0.45 + rnd.randf() * 0.5
			var rock_name := "Rock%d.glb" % rnd.randi_range(1, 5)
			var rock_basis := Basis(Vector3.UP, ang).scaled(Vector3(w, h, w))
			var rock_xf := Transform3D(rock_basis, Vector3(px, height_at(px, pz) + h * 0.5 - 0.1, pz))
			if not cave_rock_groups.has(rock_name):
				cave_rock_groups[rock_name] = []
			cave_rock_groups[rock_name].append(rock_xf)
			_add_obs(px, pz, w * 0.8)
	for model_name in cave_rock_groups:
		_wow_mm("modular_dungeon_pack/" + str(model_name), cave_rock_groups[model_name])
	# koridor destek çerçeveleri
	for i in range(1, MINE_ROOMS.size()):
		var ra: Array = MINE_ROOMS[i - 1]
		var rb: Array = MINE_ROOMS[i]
		var pa := Vector2(ra[0], ra[1])
		var pb := Vector2(rb[0], rb[1])
		var dir := (pb - pa).normalized()
		for tt in [0.34, 0.5, 0.66]:
			var p := pa.lerp(pb, tt)
			if p.distance_to(pa) < float(ra[2]) + 1.8 or p.distance_to(pb) < float(rb[2]) + 1.8:
				continue
			var g := Node3D.new()
			g.position = Vector3(p.x, height_at(p.x, p.y), p.y)
			g.rotation.y = atan2(-dir.x, -dir.y)
			add_child(g)
			for sd in [-1.0, 1.0]:
				Dwarf.box(g, Vector3(0.5, 4.4, 0.5), wood, Vector3(sd * 3.0, 2.2, 0))
			Dwarf.box(g, Vector3(7.2, 0.55, 0.55), wood, Vector3(0, 4.3, 0))
	# eşyalar
	_prop("survival", "barrel", -6.0, 84.0, 0.0, 3.6, 0.6)
	_prop("survival", "barrel", -5.2, 84.8, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", 6.0, 84.0, 0.4, 3.6, 0.7)
	_prop("fantasy-town", "lantern", -3.0, 82.0, 0.0, 3.2)
	_prop("fantasy-town", "lantern", 3.0, 82.0, 0.0, 3.2)
	_prop("fantasy-town", "cart", -2.0, 52.0, 0.5, 3.4, 1.3)
	_prop("survival", "box-large", -14.0, 43.0, 0.2, 3.6, 0.7)
	_prop("survival", "barrel", -13.0, 53.0, 0.0, 3.6, 0.6)
	_prop("survival", "barrel", -12.3, 53.8, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", 16.0, 2.0, 0.6, 3.6, 0.7)
	_prop("survival", "barrel", 17.0, 18.0, 0.0, 3.6, 0.6)
	_prop("fantasy-town", "cart", -1.0, -20.0, -0.4, 3.4, 1.3)
	_prop("survival", "box-large", -15.0, -31.0, 0.3, 3.6, 0.7)
	_prop("survival", "barrel", -14.0, -21.0, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", -10.0, -52.0, 0.5, 3.6, 0.7)
	_prop("survival", "box-large", 10.0, -52.0, -0.5, 3.6, 0.7)
	for a in MINE_ALC:
		_prop("survival", "chest", float(a[0]), float(a[1]), 1.6, 3.4, 0.8)
	_make_portal(0.0, 85.0, Color("6aa0ff"), "snow", -16.0, -44.0, 0.0, "Demirkazan")

func _build_swamp() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 4242
	# su
	var wm := StandardMaterial3D.new()
	wm.albedo_color = Color(0.14, 0.26, 0.22, 0.8)
	wm.roughness = 0.12
	wm.metallic = 0.25
	wm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var pm := PlaneMesh.new()
	pm.size = Vector2(340, 340)
	var water := MeshInstance3D.new()
	water.mesh = pm
	water.material_override = wm
	water.position = Vector3(0, -0.75, 0)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(water)
	# uzak tepeler
	var hm := Dwarf.mat(Color.html("3a4a38"), 0.0, 0.95)
	var hm2 := Dwarf.mat(Color.html("4a5a46"), 0.0, 0.95)
	for i in 30:
		var a := float(i) / 30.0 * TAU + hash2(i, 3) * 0.2
		var far := i % 2 == 1
		var r := (160.0 if far else 130.0) + hash2(i, 9) * 20.0
		var h := 22.0 + hash2(i, 5) * 26.0
		var w := 30.0 + hash2(i, 7) * 18.0
		_cone_mi(w, h, hm2 if far else hm, Vector3(cos(a) * r, h / 2.0 - 8.0, sin(a) * r), false, 6)
	# Bataklıkta Quaternius söğütleri ve ölü söğütler.
	var willow_groups: Dictionary = {}
	var tries := 0
	while willow_groups.values().reduce(func(total, group): return total + group.size(), 0) < 190 and tries < 3000:
		tries += 1
		var a2 := rnd.randf() * TAU
		var r2 := 10.0 + rnd.randf() * 80.0
		var x := cos(a2) * r2
		var z := sin(a2) * r2
		if Vector2(x, z).length() < 18.0 or Vector2(x, z - 22.0).length() < 7.0:
			continue
		var y := height_at(x, z)
		var scale_value := 2.8 + rnd.randf() * 1.8
		var model_name := "Willow_%d.glb" % rnd.randi_range(1, 5)
		if rnd.randf() < 0.22:
			model_name = "Willow_Dead_%d.glb" % rnd.randi_range(1, 5)
		var xf := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * scale_value), Vector3(x, y - 0.1, z))
		if not willow_groups.has(model_name):
			willow_groups[model_name] = []
		willow_groups[model_name].append(xf)
		_add_obs(x, z, 0.85)
	for model_name in willow_groups:
		_wow_mm("nature_pack/" + str(model_name), willow_groups[model_name])
	# sazlar ve kayalar
	var reeds: Array = []
	tries = 0
	while reeds.size() < 320 and tries < 4000:
		tries += 1
		var x3 := rnd.randf_range(-88.0, 88.0)
		var z3 := rnd.randf_range(-88.0, 88.0)
		var y3 := height_at(x3, z3)
		if y3 < -1.0 or y3 > 0.9 or Vector2(x3, z3).length() < 15.0:
			continue
		reeds.append(Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * (2.4 + rnd.randf() * 1.6)), Vector3(x3, y3, z3)))
	_kit_mm("survival", "grass-large", reeds, Color(0.66, 0.72, 0.38))
	# rogoz: uzun sap + kahverengi başak
	var stalks: Array = []
	var heads: Array = []
	tries = 0
	while stalks.size() < 140 and tries < 3000:
		tries += 1
		var x5 := rnd.randf_range(-88.0, 88.0)
		var z5 := rnd.randf_range(-88.0, 88.0)
		var y5 := height_at(x5, z5)
		if y5 < -0.6 or y5 > 0.5 or Vector2(x5, z5).length() < 15.0:
			continue
		var hh := 1.6 + rnd.randf() * 0.9
		var bs := Basis(Vector3.UP, rnd.randf() * TAU) * Basis(Vector3(1, 0, 0), rnd.randf_range(-0.12, 0.12))
		stalks.append(Transform3D(bs.scaled(Vector3(1, hh, 1)), Vector3(x5, y5 + hh * 0.5, z5)))
		heads.append(Transform3D(bs, Vector3(x5, y5 + hh + 0.15, z5)))
	var catstalk := CylinderMesh.new()
	catstalk.top_radius = 0.025
	catstalk.bottom_radius = 0.035
	catstalk.height = 1.0
	catstalk.radial_segments = 4
	_add_multimesh(catstalk, Dwarf.mat(Color.html("6a7a3a"), 0.0, 0.9), stalks)
	var cathead := CylinderMesh.new()
	cathead.top_radius = 0.07
	cathead.bottom_radius = 0.07
	cathead.height = 0.38
	cathead.radial_segments = 6
	_add_multimesh(cathead, Dwarf.mat(Color.html("5a3a22"), 0.0, 0.9), heads)
	# Yosunlu kayalar ve nilüferler.
	var moss_groups: Dictionary = {}
	for rock_i in 36:
		var x4 := rnd.randf_range(-85.0, 85.0)
		var z4 := rnd.randf_range(-85.0, 85.0)
		if Vector2(x4, z4).length() < 18.0:
			continue
		var rock_name := "Rock_Moss_%d.glb" % rnd.randi_range(1, 7)
		var rock_scale := 1.4 + rnd.randf() * 2.2
		var rock_xf := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * rock_scale), Vector3(x4, height_at(x4, z4) - 0.1, z4))
		if not moss_groups.has(rock_name):
			moss_groups[rock_name] = []
		moss_groups[rock_name].append(rock_xf)
		_add_obs(x4, z4, 1.0)
	for model_name in moss_groups:
		_wow_mm("nature_pack/" + str(model_name), moss_groups[model_name])
	var lily_groups: Array = []
	for lily_i in 34:
		var lx := rnd.randf_range(-82.0, 82.0)
		var lz := rnd.randf_range(-82.0, 82.0)
		if Vector2(lx, lz).length() < 18.0:
			continue
		lily_groups.append(Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * (0.7 + rnd.randf() * 0.7)), Vector3(lx, -0.68, lz)))
	_wow_mm("nature_pack/Lilypad.glb", lily_groups)
	# karakol
	_house(-13.0, -4.0, 0.5, 6.6, 4.4, true)
	_house(13.0, -5.0, -0.5, 6.6, 4.4, true)
	_house(-12.0, 11.0, PI - 0.3, 6.6, 4.4, true)
	_house(12.0, 10.0, PI + 0.4, 6.6, 4.4, true)
	var fy := height_at(0, 0)
	_prop("survival", "campfire-pit", 0.0, 0.0, 0.0, 6.0, 1.2)
	_flame(self, Vector3(0, fy + 0.5, 0), 0.6)
	fire_light = OmniLight3D.new()
	fire_light.light_color = Color("ffb060")
	fire_light.omni_range = 22.0
	fire_light.light_energy = 2.2
	fire_light.position = Vector3(0, fy + 1.6, 0)
	add_child(fire_light)
	_prop("survival", "tent", -6.0, -9.0, 0.4, 4.2, 1.5)
	_prop("survival", "tent", 6.5, -10.0, -0.5, 4.2, 1.5)
	_prop("survival", "barrel", 3.5, -3.0, 0.0, 3.6, 0.6)
	_prop("survival", "barrel", 4.3, -2.2, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", -3.0, -4.0, 0.4, 3.6, 0.7)
	_prop("survival", "chest", 8.5, 1.0, -1.2, 3.4, 0.6)
	_prop("survival", "signpost", 3.0, 15.0, 0.3, 3.8)
	_prop("fantasy-town", "lantern", -3.0, 3.0, 0.0, 3.2)
	_prop("fantasy-town", "lantern", 3.0, 8.5, 0.0, 3.2)
	_prop("fantasy-town", "cart", -7.0, 15.0, 0.7, 3.4, 1.3)
	for i in 6:
		_prop("fantasy-town", "fence", -8.0 + i * 2.0, 17.5, PI / 2.0, 2.2)
	_make_portal(0.0, 22.0, Color("ffa040"), "snow", 16.0, -44.0, 0.0, "Demirkazan")
	_make_portal(14.0, 21.0, Color("ff5a2a"), "ash", 0.0, 17.0, PI, "Kül Diyarı (Sv 14+)")
	WorldDressing.shallows_birds(self, "res://assets/third_party/gobkit/birds/Flamingo.glb", 7, 77, -0.9, -0.25, 22.0, 75.0)

func _ash_near_pool(x: float, z: float, pad: float) -> bool:
	for p in ASH_POOLS:
		if Vector2(x - p[0], z - p[1]).length() < p[2] + pad:
			return true
	return false

## Kül Diyarı: lav havuzları, obsidyen kayalıklar, ölü ağaçlar ve Kül Nöbetçileri Kampı
func _build_ash() -> void:
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 5151
	var off := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# uzak dağlar ve yanardağ
	var hm := Dwarf.mat(Color.html("2e2826"), 0.0, 0.95)
	var hm2 := Dwarf.mat(Color.html("403432"), 0.0, 0.95)
	for i in 28:
		var a := float(i) / 28.0 * TAU + hash2(i, 3) * 0.2
		var far := i % 2 == 1
		var r := (160.0 if far else 130.0) + hash2(i, 9) * 20.0
		var h := 26.0 + hash2(i, 5) * 34.0
		var w := 30.0 + hash2(i, 7) * 18.0
		_cone_mi(w, h, hm2 if far else hm, Vector3(cos(a) * r, h / 2.0 - 8.0, sin(a) * r), false, 6)
	var vg := Dwarf.mat(Color.html("ff7a1f"), 0.0, 0.6, Color.html("ff5a10"), 3.0)
	_cone_mi(46.0, 80.0, hm, Vector3(-120.0, 32.0, -130.0), false, 8)
	Dwarf.sph(self, 9.0, vg, Vector3(-120.0, 72.0, -130.0), Vector3(1, 0.5, 1)).cast_shadow = off
	# lav havuzları
	lava_mat = Dwarf.mat(Color.html("b02a06"), 0.0, 0.6, Color.html("e83a05"), 3.5)
	for i in ASH_POOLS.size():
		var p: Array = ASH_POOLS[i]
		Dwarf.cyl(self, p[2], p[2], 0.1, lava_mat, Vector3(p[0], -0.18, p[1]), 28).cast_shadow = off
		_add_obs(p[0], p[1], p[2] + 0.6)
		if i % 3 == 0:
			var li := OmniLight3D.new()
			li.light_color = Color("ff7a30")
			li.omni_range = 26.0
			li.light_energy = 1.6
			li.position = Vector3(p[0], 2.5, p[1])
			add_child(li)
	# obsidyen kayalıklar
	var spire := Dwarf.mat(Color.html("1a1620"), 0.4, 0.25)
	var n := 0
	var tries := 0
	while n < 34 and tries < 600:
		tries += 1
		var a2 := rnd.randf() * TAU
		var r2 := 18.0 + rnd.randf() * 66.0
		var x := cos(a2) * r2
		var z := sin(a2) * r2
		if _ash_near_pool(x, z, 4.0):
			continue
		var h2 := 4.0 + rnd.randf() * 6.0
		var w2 := 0.9 + rnd.randf() * 1.0
		_cone_mi(w2, h2, spire, Vector3(x, height_at(x, z) + h2 / 2.0 - 0.2, z), true, 5)
		_add_obs(x, z, w2 + 0.4)
		n += 1
	# Kül bölgesinde yanmış Quaternius huş ağaçları ve koyu kayalar.
	var dead_groups: Dictionary = {}
	tries = 0
	while dead_groups.values().reduce(func(total, group): return total + group.size(), 0) < 70 and tries < 1500:
		tries += 1
		var a3 := rnd.randf() * TAU
		var r3 := 20.0 + rnd.randf() * 64.0
		var x3 := cos(a3) * r3
		var z3 := sin(a3) * r3
		if _ash_near_pool(x3, z3, 5.0) or Vector2(x3, z3 - 22.0).length() < 8.0:
			continue
		var sc := 2.8 + rnd.randf() * 1.5
		var dead_name := "BirchTree_Dead_%d.glb" % rnd.randi_range(1, 5)
		var xf := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3.ONE * sc), Vector3(x3, height_at(x3, z3) - 0.1, z3))
		if not dead_groups.has(dead_name):
			dead_groups[dead_name] = []
		dead_groups[dead_name].append(xf)
		_add_obs(x3, z3, 0.8)
	for model_name in dead_groups:
		_wow_mm("nature_pack/" + str(model_name), dead_groups[model_name])
	var ash_rocks: Dictionary = {}
	for rock_i in 34:
		var x4 := rnd.randf_range(-85.0, 85.0)
		var z4 := rnd.randf_range(-85.0, 85.0)
		if Vector2(x4, z4).length() < 18.0 or _ash_near_pool(x4, z4, 3.0):
			continue
		var rock_name := "Rock_%d.glb" % rnd.randi_range(1, 7)
		var rock_scale := 1.5 + rnd.randf() * 2.5
		var rock_xf := Transform3D(Basis(Vector3.UP, rnd.randf() * TAU).scaled(Vector3(rock_scale * 1.2, rock_scale, rock_scale)), Vector3(x4, height_at(x4, z4) - 0.1, z4))
		if not ash_rocks.has(rock_name):
			ash_rocks[rock_name] = []
		ash_rocks[rock_name].append(rock_xf)
		_add_obs(x4, z4, 1.4)
	for model_name in ash_rocks:
		_wow_mm("nature_pack/" + str(model_name), ash_rocks[model_name])
	# Kül Nöbetçileri Kampı
	_house(-13.0, -4.0, 0.5, 6.6, 4.4)
	_house(13.0, -5.0, -0.5, 6.6, 4.4)
	_house(-12.0, 11.0, PI - 0.3, 6.6, 4.4)
	_house(12.0, 10.0, PI + 0.4, 6.6, 4.4)
	var fy := height_at(0, 0)
	_prop("survival", "campfire-pit", 0.0, 0.0, 0.0, 6.0, 1.2)
	_flame(self, Vector3(0, fy + 0.5, 0), 0.6)
	fire_light = OmniLight3D.new()
	fire_light.light_color = Color("ffa050")
	fire_light.omni_range = 22.0
	fire_light.light_energy = 2.2
	fire_light.position = Vector3(0, fy + 1.6, 0)
	add_child(fire_light)
	_prop("survival", "tent", -6.0, -9.0, 0.4, 4.2, 1.5)
	_prop("survival", "tent", 6.5, -10.0, -0.5, 4.2, 1.5)
	_prop("survival", "barrel", 3.5, -3.0, 0.0, 3.6, 0.6)
	_prop("survival", "barrel", 4.3, -2.2, 0.0, 3.6, 0.6)
	_prop("survival", "box-large", -3.0, -4.0, 0.4, 3.6, 0.7)
	_prop("survival", "chest", 8.5, 1.0, -1.2, 3.4, 0.6)
	_prop("survival", "signpost", 3.0, 15.0, 0.3, 3.8)
	_prop("fantasy-town", "lantern", -3.0, 3.0, 0.0, 3.2)
	_prop("fantasy-town", "lantern", 3.0, 8.5, 0.0, 3.2)
	_make_portal(-9.0, 22.0, Color("6aa0ff"), "swamp", 14.0, 15.0, PI, "Sisli Bataklık")
	_make_portal(9.0, 22.0, Color("ffa040"), "snow", 16.0, -44.0, 0.0, "Demirkazan")

func _setup_ash_fx() -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(34, 3.0, 34)
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 40.0
	pm.initial_velocity_min = 0.6
	pm.initial_velocity_max = 1.6
	pm.gravity = Vector3(0.3, 0.05, 0.1)
	pm.scale_min = 0.5
	pm.scale_max = 1.3
	var q := QuadMesh.new()
	q.size = Vector2(0.13, 0.13)
	var qm := StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.albedo_color = Color(1.0, 0.6, 0.25, 0.9)
	qm.emission_enabled = true
	qm.emission = Color(1.0, 0.5, 0.15)
	qm.emission_energy_multiplier = 2.2
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = qm
	swamp_fx = GPUParticles3D.new()
	swamp_fx.amount = 200
	swamp_fx.lifetime = 8.0
	swamp_fx.preprocess = 8.0
	swamp_fx.process_material = pm
	swamp_fx.draw_pass_1 = q
	swamp_fx.visibility_aabb = AABB(Vector3(-36, -4, -36), Vector3(72, 20, 72))
	swamp_fx.local_coords = false
	swamp_fx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(swamp_fx)

func _setup_swamp_fx() -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(30, 3.0, 30)
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 180.0
	pm.initial_velocity_min = 0.1
	pm.initial_velocity_max = 0.5
	pm.gravity = Vector3.ZERO
	pm.scale_min = 0.6
	pm.scale_max = 1.4
	var q := QuadMesh.new()
	q.size = Vector2(0.16, 0.16)
	var qm := StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.albedo_color = Color(0.8, 1.0, 0.4, 0.9)
	qm.emission_enabled = true
	qm.emission = Color(0.7, 1.0, 0.3)
	qm.emission_energy_multiplier = 2.0
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = qm
	swamp_fx = GPUParticles3D.new()
	swamp_fx.amount = 160
	swamp_fx.lifetime = 7.0
	swamp_fx.preprocess = 7.0
	swamp_fx.process_material = pm
	swamp_fx.draw_pass_1 = q
	swamp_fx.visibility_aabb = AABB(Vector3(-34, -8, -34), Vector3(68, 16, 68))
	swamp_fx.local_coords = false
	swamp_fx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(swamp_fx)

## Maden: yavaş süzülen toz zerrecikleri.
func _setup_mine_fx() -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(14, 3.0, 14)
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 180.0
	pm.initial_velocity_min = 0.05
	pm.initial_velocity_max = 0.25
	pm.gravity = Vector3(0.02, -0.02, 0.0)
	pm.scale_min = 0.5
	pm.scale_max = 1.2
	var q := QuadMesh.new()
	q.size = Vector2(0.06, 0.06)
	var qm := StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.albedo_color = Color(0.85, 0.78, 0.65, 0.5)
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = qm
	swamp_fx = GPUParticles3D.new()
	swamp_fx.amount = 90
	swamp_fx.lifetime = 9.0
	swamp_fx.preprocess = 9.0
	swamp_fx.process_material = pm
	swamp_fx.draw_pass_1 = q
	swamp_fx.visibility_aabb = AABB(Vector3(-16, -4, -16), Vector3(32, 10, 32))
	swamp_fx.local_coords = false
	swamp_fx.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(swamp_fx)

## Keşif noktaları: yaklaşınca bir kez deneyim ve başlık verir. Konumlar kamp bölgelerine yakın, ulaşılabilir yerlerdir.
const DISCOVERIES := {
	"snow": [
		{"id": "d_snow1", "name": "Gözcü Taşı", "x": 50.0, "z": 9.0},
		{"id": "d_snow2", "name": "Fısıldayan Kayalık", "x": -22.0, "z": 45.0},
		{"id": "d_snow3", "name": "Eski Cüce Anıtı", "x": -56.0, "z": 6.0},
		{"id": "d_snow4", "name": "Don Çeşmesi", "x": 45.0, "z": 37.0},
	],
	"swamp": [
		{"id": "d_sw1", "name": "Çürük Köprü", "x": -40.0, "z": 19.0},
		{"id": "d_sw2", "name": "Batık Çan Kulesi", "x": 37.0, "z": -22.0},
		{"id": "d_sw3", "name": "Ateşböceği Çayırı", "x": 30.0, "z": 40.0},
		{"id": "d_sw4", "name": "Solucan Yuvası", "x": -33.0, "z": -32.0},
	],
	"ash": [
		{"id": "d_ash1", "name": "Kül Sunağı", "x": -36.0, "z": 22.0},
		{"id": "d_ash2", "name": "Kırık Dev Kaburgası", "x": 36.0, "z": -25.0},
		{"id": "d_ash3", "name": "Kor Kaynağı", "x": 29.0, "z": 37.0},
		{"id": "d_ash4", "name": "Dumanlı Geçit", "x": 3.0, "z": 48.0},
	],
}

func _spawn_discoveries() -> void:
	for dd in DISCOVERIES.get(map, []):
		var gy := height_at(dd["x"], dd["z"])
		var col := Color("66d8ff") if not P["disc"].has(dd["id"]) else Color("6a7a88")
		var pil := Dwarf.cyl(self, 0.12, 0.12, 2.6, Dwarf.mat(col, 0.0, 0.4, col, 1.6 if not P["disc"].has(dd["id"]) else 0.2), Vector3(dd["x"], gy + 1.3, dd["z"]), 6)
		pil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _check_discoveries() -> void:
	for dd in DISCOVERIES.get(map, []):
		if P["disc"].has(dd["id"]):
			continue
		if Vector2(dd["x"] - P["x"], dd["z"] - P["z"]).length() < 6.0:
			P["disc"][dd["id"]] = true
			hud.banner("KEŞİF", dd["name"])
			hud.say("Yeni yer keşfettin: %s (+%d deneyim)" % [dd["name"], 80 + 20 * int(P["lvl"])], Color("66d8ff"))
			sfx.play("quest")
			gain_xp(80.0 + 20.0 * float(P["lvl"]))
			save_game()

func _setup_snow() -> void:
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(32, 0.5, 32)
	pm.direction = Vector3(0.12, -1, 0.05)
	pm.spread = 14.0
	pm.initial_velocity_min = 1.4
	pm.initial_velocity_max = 2.6
	pm.gravity = Vector3(0, -0.3, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.3
	var q := QuadMesh.new()
	q.size = Vector2(0.12, 0.12)
	var qm := StandardMaterial3D.new()
	qm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	qm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	qm.albedo_color = Color(1, 1, 1, 0.9)
	qm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	q.material = qm
	snow_node = GPUParticles3D.new()
	snow_node.amount = 2400
	snow_node.lifetime = 9.0
	snow_node.preprocess = 9.0
	snow_node.process_material = pm
	snow_node.draw_pass_1 = q
	snow_node.visibility_aabb = AABB(Vector3(-36, -22, -36), Vector3(72, 44, 72))
	snow_node.local_coords = false
	snow_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(snow_node)

# ---------- girdi ----------
func _on_start(cont: bool) -> void:
	mode = "play"
	sfx.start_ambient()
	sfx.play("click")
	if cont and load_game():
		hud.say("Kayıtlı oyun yüklendi.", Color("f2c75c"))
		return
	SaveManager.delete_path(SAVE_PATH)
	npc_mem = {}
	hud.banner("KAR DAĞI KÖYÜ", "Kamp ateşi")
	hud.say("Kurtlar ve domuzlar vadide dolaşıyor. İyi avlar!", Color("f2c75c"))

func toggle_win(name: String) -> void:
	if mode != "play":
		return
	var w: Control = invui.char_win
	match name:
		"tal": w = talui.win
		"prog": w = progui.win
		"bag": w = invui.bag_win
	w.visible = not w.visible
	if w.visible and name == "char" and vendor_npc != null:
		close_vendor()
	if not w.visible:
		held = null
		invui.hide_tip()
	sfx.play("click", -6)
	inv_changed()

func ui_close(name: String) -> void:
	held = null
	invui.hide_tip()
	match name:
		"bag": invui.bag_win.visible = false
		"char": invui.char_win.visible = false
		"tal": talui.win.visible = false
		"prog": progui.win.visible = false
		"vendor": close_vendor()
		"loot": close_loot()
	invui.refresh()

func ui_vendor_action(i: int) -> void:
	if vendor_npc == null:
		return
	if vendor_npc["role"] == "bank":
		match i:
			0:
				var cost: int = inv.bank_expand_cost()
				var err: String = inv.bank_expand()
				if err != "":
					hud.say(err, Color("ff6a5a"))
				else:
					hud.say("Banka genişledi: %d yuva (-%s)" % [inv.bank_size, Items.money_plain(cost)], Color("f2c75c"))
					sfx.play("coin", -6)
			1:
				inv.sort_bank()
				sfx.play("click", -4)
			2:
				var moved: int = inv.bank_put_materials()
				hud.say("%d malzeme yığını bankaya taşındı." % moved if moved > 0 else "Taşınacak malzeme yok ya da banka dolu.", Color("f2c75c"))
				sfx.play("click", -4)
	elif i == 0:
		var res: Array = inv.sell_junk()
		if res[1] == 0:
			hud.say("Satılacak çerçöp yok.", Color("9aa7b4"))
		else:
			hud.say("%d çerçöp yığını satıldı (+%s)" % [res[1], Items.money_plain(res[0])], Color("f2c75c"))
			sfx.play("coin", -6)
			skill_xp("speech", 1.0)
	inv_changed()

func ui_vendor_tab(i: int) -> void:
	vendor_tab = i
	invui.refresh()

func ui_vendor_click(idx: int, _button: int) -> void:
	if vendor_npc == null:
		return
	var err: String = ""
	if vendor_npc["role"] == "bank":
		err = inv.bank_take(idx) if vendor_tab == 0 else inv.bank_put(idx)
		if err != "":
			hud.say(err, Color("ff6a5a"))
		else:
			sfx.play("click", -4)
		inv_changed()
		return
	if vendor_tab == 0:
		if idx < 0 or idx >= VENDORS[vendor_npc["id"]].size():
			return
		var id: String = VENDORS[vendor_npc["id"]][idx]
		err = inv.buy(id, 1, Items.buy_price(Items.get_item(id)))
	else:
		err = inv.rebuy(idx)
	if err != "":
		hud.say(err, Color("ff6a5a"))
	else:
		sfx.play("coin", -6)
		skill_xp("speech", 1.5)
	inv_changed()

func ui_loot_click(idx: int) -> void:
	take_loot(idx)

func ui_slot_click(kind: String, key, button: int) -> void:
	sfx.play("click", -6)
	var lvl: int = P["lvl"]
	var err: String = ""
	if button == MOUSE_BUTTON_RIGHT:
		if held != null:
			held = null
		elif kind == "bag":
			var e = inv.bag[key]
			if e == null:
				return
			var it := Items.get_item(e["id"])
			if disenchant_mode and vendor_npc == null:
				if not can_craft_here():
					hud.say("Parçalamak için Demirkazan'ın ocağına yakın olmalısın.", Color("ff6a5a"))
				else:
					var dr: Dictionary = inv.disenchant(key, dis_rng)
					if dr["err"] != "":
						hud.say(dr["err"], Color("ff6a5a"))
					else:
						hud.say("Parçalandı: %s → %d Büyülü Toz%s" % [dr["name"], dr["dust"], (", %d Parlak Öz" % dr["ess"]) if dr["ess"] > 0 else ""], Color("c8a2ff"))
						ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.4, Color("c8a2ff"), 0.5)
						sfx.play("block", -4)
						if P["prof"].has("smith"):
							prof_gain("smith")
			elif vendor_npc != null and invui.vend_win.visible and vendor_npc["role"] == "bank":
				err = inv.bank_put(key)
			elif vendor_npc != null and invui.vend_win.visible:
				var gain: int = inv.sell(key)
				hud.say("Sattın: %s (+%s)" % [it["name"], Items.money_plain(gain)], Color("f2c75c"))
				sfx.play("coin", -6)
				skill_xp("speech", 1.0)
			elif Items.is_equip(it):
				err = inv.equip_from_bag(key, lvl)
			elif it.get("heal", 0.0) > 0.0:
				use_potion(e["id"])
		else:
			err = inv.unequip(key)
	elif held == null:
		if kind == "bag" and inv.bag[key] != null:
			held = {"from": "bag", "i": key}
		elif kind == "eq" and inv.eq[key] != "":
			held = {"from": "eq", "slot": key}
	else:
		var h: Dictionary = held
		held = null
		if h["from"] == "bag":
			if kind == "bag":
				inv.swap_bag(h["i"], key)
			else:
				err = inv.equip_from_bag(h["i"], lvl, key)
		else:
			var sl: String = h["slot"]
			if kind == "bag":
				var e2 = inv.bag[key]
				if e2 == null:
					inv.bag[key] = {"id": inv.eq[sl], "n": 1}
					inv.eq[sl] = ""
				else:
					var it2 := Items.get_item(e2["id"])
					if Items.slot_fits(it2, sl) and lvl >= it2["req"]:
						var old: String = inv.eq[sl]
						inv.eq[sl] = e2["id"]
						inv.bag[key] = {"id": old, "n": 1}
					else:
						err = "Bu eşya o yuvaya uymuyor."
			elif key != sl:
				var a: String = inv.eq[sl]
				var b: String = inv.eq[key]
				if Items.slot_fits(Items.get_item(a), key) and (b == "" or Items.slot_fits(Items.get_item(b), sl)):
					inv.eq[sl] = b
					inv.eq[key] = a
				else:
					err = "Bu eşya o yuvaya uymuyor."
	if err != "":
		hud.say(err, Color("ff6a5a"))
	inv_changed()

const SETTINGS_PATH := "user://ayarlar.cfg"

## Tuş atama: işlem -> tuş. Boş bırakılan her işlem varsayılan tuşunda çalışır.
const BIND_NAMES := {"fwd": "İleri", "back": "Geri", "left": "Sola", "right": "Sağa", "turnl": "Sola dön", "turnr": "Sağa dön",
	"jump": "Zıpla", "interact": "Konuş / topla", "potion": "İksir", "auto": "Otomatik saldırı", "target": "Hedef seç",
	"bag": "Çanta", "char": "Karakter", "tal": "Yetenekler", "prog": "Meslek / başarım", "map": "Dünya haritası", "help": "Yardım",
	"shout": "Savaş çığlığı", "shoutsel": "Çığlık değiştir"}
const BIND_DEFAULTS := {"fwd": KEY_W, "back": KEY_S, "left": KEY_A, "right": KEY_D, "turnl": KEY_Q, "turnr": KEY_E,
	"jump": KEY_SPACE, "interact": KEY_G, "potion": KEY_F, "auto": KEY_R, "target": KEY_TAB,
	"bag": KEY_B, "char": KEY_C, "tal": KEY_N, "prog": KEY_K, "map": KEY_M, "help": KEY_H, "shout": KEY_Z, "shoutsel": KEY_X}
var binds: Dictionary = BIND_DEFAULTS.duplicate()

func reset_binds() -> void:
	binds = BIND_DEFAULTS.duplicate()
	save_settings()

func set_bind(act: String, code: int) -> void:
	# aynı tuş başka işlemdeyse yer değiştir
	for a in binds:
		if a != act and binds[a] == code:
			binds[a] = binds[act]
	binds[act] = code
	save_settings()

func kp(act: String) -> bool:
	return Input.is_key_pressed(binds[act])

## Basılan tuşu, işlemin varsayılan tuşuna çevirir; başka işleme atanmış varsayılan tuşlar devre dışı kalır (-1)
func _xlate(kc: int) -> int:
	for a in binds:
		if binds[a] == kc:
			return BIND_DEFAULTS[a]
	for a in binds:
		if BIND_DEFAULTS[a] == kc:
			return -1
	return kc

## Grafik kalitesi: 0 düşük (gölge/SSAO kapalı, %75 çözünürlük), 1 orta (gölge açık), 2 yüksek
func apply_quality(q: int) -> void:
	if sun:
		sun.shadow_enabled = q >= 1
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS if q == 1 else DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	if env_res:
		env_res.ssao_enabled = q >= 2
	var vp := get_viewport()
	vp.scaling_3d_scale = 0.75 if q == 0 else 1.0
	vp.msaa_3d = Viewport.MSAA_DISABLED if q == 0 else Viewport.MSAA_2X
	hud.set_quality(q)

func save_settings() -> void:
	var cf := ConfigFile.new()
	cf.set_value("ayar", "kalite", hud.q_level)
	cf.set_value("ayar", "ses", hud.vol_slider.value)
	cf.set_value("ayar", "hassasiyet", mouse_sens)
	for a in binds:
		cf.set_value("tus", a, binds[a])
	cf.set_value("cubuk", "sira", hud.bar_order())
	cf.save(SETTINGS_PATH)

func load_settings() -> void:
	var cf := ConfigFile.new()
	if cf.load(SETTINGS_PATH) != OK:
		return
	for a in binds:
		binds[a] = int(cf.get_value("tus", a, BIND_DEFAULTS[a]))
	var ord = cf.get_value("cubuk", "sira", [])
	if typeof(ord) == TYPE_ARRAY:
		hud.set_bar_order(ord)
	apply_quality(int(cf.get_value("ayar", "kalite", 2)))
	var v: float = float(cf.get_value("ayar", "ses", 0.8))
	hud.set_volume_ui(v)
	sfx.set_volume(v)
	mouse_sens = float(cf.get_value("ayar", "hassasiyet", 1.0))
	hud.set_sens_ui(mouse_sens)

func abil_at(p: int) -> void:
	ability(hud.slots[p].idx)

func toggle_worldmap() -> void:
	if mode != "play":
		return
	worldmap.visible = not worldmap.visible
	if worldmap.visible:
		var vs := get_viewport().get_visible_rect().size
		worldmap.position = ((vs - worldmap.size) * 0.5).round()
		_refresh_worldmap()

func _refresh_worldmap() -> void:
	var w := worldmap
	w.map_name = map
	w.title = {"snow": "Kar Dağı Vadisi", "swamp": "Sisli Bataklık", "mine": "Kara Demir Madeni", "ash": "Kül Diyarı"}[map]
	w.mine_rooms = MINE_ROOMS
	w.mine_alc = MINE_ALC
	var cs: Array = []
	for c in camps_now:
		cs.append({"x": c["x"], "z": c["z"], "name": _mtype(c["kind"])["name"]})
	w.camps = cs
	var bs: Array = []
	for mb in mobs:
		if mb.boss != "" and not mb.temp:
			bs.append({"x": mb.x, "z": mb.z, "name": mb.nm, "dead": mb.dead})
	w.bosses = bs
	w.portals = portals.map(func(p): return {"x": p["x"], "z": p["z"], "label": p["label"]})
	var np: Array = []
	for n in npcs:
		np.append({"p": Vector2(n["x"], n["z"]), "mark": npc_mark(n)})
	w.npcs = np
	w.qt = _quest_waypoints()
	w.px = P["x"]
	w.pz = P["z"]
	w.pyaw = P["yaw"]
	w.queue_redraw()

func toggle_fullscreen() -> void:
	var w := get_window()
	w.mode = Window.MODE_WINDOWED if w.mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN

func toggle_pause() -> void:
	if mode != "play":
		return
	paused = not paused
	hud.set_paused(paused)
	if paused:
		rmb = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		save_game()

func save_game() -> void:
	if mode != "play" or P["dead"]:
		return
	var d := {"x": P["x"], "z": P["z"], "yaw": P["yaw"], "hp": P["hp"], "lvl": P["lvl"], "xp": P["xp"],
		"wep_b": P["wep_b"], "wep_lvl": P["wep_lvl"], "tal": P["tal"], "prof": P["prof"], "rep": P["rep"], "stats": P["stats"], "ach": P["ach"], "skl": P["skl"], "perks": P["perks"], "lore": P["lore"], "talked": P["talked"], "walls": P["walls"], "shout_sel": P["shout_sel"], "pity": P["pity"], "disc": P["disc"], "qs": qs, "inv": inv.to_dict(), "map": map}
	d["npc_mem"] = npc_mem
	SaveManager.write(SAVE_PATH, d)

func load_game() -> bool:
	var res: Dictionary = SaveManager.read(SAVE_PATH)
	if not res.ok:
		return false
	var d: Dictionary = res.data
	if res.get("used_backup", false):
		hud.say("Ana kayıt bozuktu; yedekten yüklendi.", Color("ffd23a"))
	if typeof(d.get("npc_mem")) == TYPE_DICTIONARY:
		npc_mem = d["npc_mem"]
	for k in ["x", "z", "yaw", "lvl", "xp", "wep_b", "wep_lvl", "hp"]:
		if not d.has(k) or typeof(d[k]) != TYPE_FLOAT:
			return false
	var want_map: String = str(d.get("map", "snow"))
	if not ["snow", "swamp", "mine", "ash"].has(want_map):
		want_map = "snow"
	if want_map != map:
		_enter_map(want_map)
	P["x"] = clampf(d["x"], -WORLD_R, WORLD_R)
	P["z"] = clampf(d["z"], -WORLD_R, WORLD_R)
	P["yaw"] = d["yaw"]
	P["lvl"] = clampi(int(d["lvl"]), 1, MAX_LVL)
	P["tal"] = {}
	if typeof(d.get("tal")) == TYPE_DICTIONARY:
		for k in d["tal"]:
			var td := talent_def(str(k))
			if not td.is_empty():
				P["tal"][str(k)] = clampi(int(d["tal"][k]), 0, td["max"])
	if tal_points() < 0:
		P["tal"] = {}
	P["prof"] = {}
	P["rep"] = {}
	P["stats"] = {}
	P["ach"] = {}
	if typeof(d.get("prof")) == TYPE_DICTIONARY:
		for k in d["prof"]:
			if Prog.PROFS.has(str(k)):
				P["prof"][str(k)] = clampi(int(d["prof"][k]), 1, Prog.SKILL_MAX)
	if typeof(d.get("rep")) == TYPE_DICTIONARY:
		for k in d["rep"]:
			if Prog.FACTIONS.has(str(k)):
				P["rep"][str(k)] = clampi(int(d["rep"][k]), 0, 10000)
	if typeof(d.get("stats")) == TYPE_DICTIONARY:
		for k in d["stats"]:
			if str(k).length() < 40:
				P["stats"][str(k)] = maxi(0, int(d["stats"][k]))
	if typeof(d.get("ach")) == TYPE_DICTIONARY:
		for a in Prog.ACHS:
			if d["ach"].has(a["id"]):
				P["ach"][a["id"]] = true
	P["skl"] = {}
	P["perks"] = {}
	if typeof(d.get("skl")) == TYPE_DICTIONARY:
		for k in Skills.ORDER:
			if d["skl"].has(k) and typeof(d["skl"][k]) == TYPE_DICTIONARY:
				P["skl"][k] = {"lv": clampi(int(d["skl"][k].get("lv", 1)), 1, Skills.MAX), "xp": maxf(0.0, float(d["skl"][k].get("xp", 0.0)))}
	if typeof(d.get("perks")) == TYPE_DICTIONARY:
		for k in d["perks"]:
			if not Skills.perk_def(str(k)).is_empty():
				P["perks"][str(k)] = true
	if Skills.points_free(P["lvl"], P["skl"], P["perks"]) < 0:
		P["perks"] = {}
	P["lore"] = {}
	P["talked"] = {}
	P["walls"] = Shouts.sanitize(d.get("walls"))
	P["pity"] = clampi(int(d.get("pity", 0)), 0, 10)
	P["disc"] = {}
	if typeof(d.get("disc")) == TYPE_DICTIONARY:
		for dk in d["disc"]:
			P["disc"][str(dk)] = true
	P["shout_sel"] = str(d.get("shout_sel", "force")) if Shouts.SHOUTS.has(str(d.get("shout_sel", ""))) else "force"
	P["shout_cd"] = 0.0
	P["skin_t"] = 0.0
	if typeof(d.get("lore")) == TYPE_DICTIONARY:
		for k in d["lore"]:
			if Journal.LORE.has(str(k)):
				P["lore"][str(k)] = true
	if typeof(d.get("talked")) == TYPE_DICTIONARY:
		for k in d["talked"]:
			if str(k).length() < 40:
				P["talked"][str(k)] = true
	P["xp"] = maxf(0.0, d["xp"])
	if typeof(d.get("inv")) == TYPE_DICTIONARY and inv.from_dict(d["inv"]):
		pass
	else:
		# eski kayıt: altın ve iksirleri çantaya çevir
		inv.reset()
		inv.money = maxi(0, int(d.get("gold", 0))) * 10
		inv.remove("pot_heal", inv.count("pot_heal"))
		inv.add("pot_heal", clampi(int(d.get("pot", 3)), 0, 20))
	held = null
	P["wep_b"] = d["wep_b"]
	P["wep_lvl"] = clampi(int(d["wep_lvl"]), 0, 6)
	G = Items.totals(inv.eq)
	P["hp"] = clampf(d["hp"], 1.0, float(max_hp()))
	qs = {}
	if typeof(d.get("qs")) == TYPE_DICTIONARY:
		for id in d["qs"]:
			if QUESTS.has(id) and typeof(d["qs"][id]) == TYPE_DICTIONARY:
				var e: Dictionary = d["qs"][id]
				qs[id] = {"st": str(e.get("st", "active")), "n": int(e.get("n", 0))}
	P["y"] = height_at(P["x"], P["z"])
	if mm != null:
		mm.sync_quests(qs, P["lvl"])
	render_quests()
	inv_changed()
	return true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()

func _unhandled_input(ev: InputEvent) -> void:
	if paused:
		if ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode == KEY_ESCAPE:
			toggle_pause()
		return
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_RIGHT:
			rmb = ev.pressed
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if ev.pressed else Input.MOUSE_MODE_VISIBLE
		elif ev.button_index == MOUSE_BUTTON_LEFT and ev.pressed and mode == "play":
			_select_at(ev.position)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_dist_t = clampf(cam_dist_t - 0.9, 3.0, 18.0)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_dist_t = clampf(cam_dist_t + 0.9, 3.0, 18.0)
	elif ev is InputEventMouseMotion and rmb:
		cam_yaw -= ev.relative.x * 0.005 * mouse_sens
		cam_pitch = clampf(cam_pitch + ev.relative.y * 0.004 * mouse_sens, 0.05, 1.25)
	elif ev is InputEventKey and ev.pressed and not ev.echo:
		match _xlate(ev.keycode):
			KEY_SPACE: jump()
			KEY_R: toggle_auto()
			KEY_1: abil_at(9 if ev.shift_pressed else 0)
			KEY_2: abil_at(10 if ev.shift_pressed else 1)
			KEY_3: abil_at(11 if ev.shift_pressed else 2)
			KEY_4: abil_at(12 if ev.shift_pressed else 3)
			KEY_5: abil_at(13 if ev.shift_pressed else 4)
			KEY_6: abil_at(14 if ev.shift_pressed else 5)
			KEY_7: abil_at(15 if ev.shift_pressed else 6)
			KEY_8: abil_at(7)
			KEY_9: abil_at(8)
			KEY_0: use_potion()
			KEY_F: use_potion()
			KEY_Z: use_shout()
			KEY_X: cycle_shout()
			KEY_H: hud.toggle_help()
			KEY_B: toggle_win("bag")
			KEY_C: toggle_win("char")
			KEY_N: toggle_win("tal")
			KEY_K: toggle_win("prog")
			KEY_M: toggle_worldmap()
			KEY_G:
				if loot_mob != null:
					while loot_mob != null and not loot_mob.loot.is_empty():
						var before: int = loot_mob.loot.size()
						take_loot(0)
						if loot_mob != null and loot_mob.loot.size() >= before:
							break
				elif dlg_open:
					close_dialog()
				elif near_npc() != null:
					open_talk()
				else:
					var looted := false
					for m in mobs:
						if m.dead and (not m.loot.is_empty() or m.loot_money > 0) and Vector2(m.x - P["x"], m.z - P["z"]).length() < 4.0 + (m.rad if m.boss != "" else 0.0):
							open_loot(m)
							looted = true
							break
					if not looted and not try_house_door() and not try_read_wall():
						try_gather()
			KEY_TAB:
				var m = nearest_mob(14.0)
				if m:
					P["target"] = m
			KEY_ESCAPE:
				if held != null:
					held = null
					invui.refresh()
				elif loot_mob != null:
					close_loot()
				elif vendor_npc != null:
					close_vendor()
				elif invui.bag_win.visible or invui.char_win.visible or talui.win.visible or progui.win.visible:
					invui.bag_win.visible = false
					invui.char_win.visible = false
					talui.win.visible = false
					progui.win.visible = false
					invui.hide_tip()
				elif dlg_open:
					close_dialog()
				elif hud.help_box.visible:
					hud.toggle_help()
				elif P["target"] != null or P["auto"]:
					P["target"] = null
					P["auto"] = false
				else:
					toggle_pause()
			KEY_F11:
				toggle_fullscreen()

func _select_at(pos: Vector2) -> void:
	if held != null:
		held = null
		invui.refresh()
		return
	for m in mobs:
		if m.dead and (not m.loot.is_empty() or m.loot_money > 0):
			var lp := Vector3(m.x, m.node.position.y + 0.5, m.z)
			if not cam.is_position_behind(lp) and cam.unproject_position(lp).distance_to(pos) < 50.0:
				open_loot(m)
				return
	var best = null
	var bd := 60.0
	for m in mobs:
		if m.dead:
			continue
		var wp := Vector3(m.x, m.node.position.y + 1.0 * m.sc, m.z)
		if cam.is_position_behind(wp):
			continue
		var d := cam.unproject_position(wp).distance_to(pos)
		if d < bd:
			bd = d
			best = m
	if best:
		P["target"] = best

# ---------- savaş ----------
func in_combat() -> bool:
	return T - P["combat_t"] < 5.0

func add_rage(n: float) -> void:
	P["rage"] = minf(100.0, P["rage"] + n * (1.0 + 0.1 * trk("fur_rage")))

func roll(base: float) -> Dictionary:
	var crit := randf() < crit_chance()
	P["combo"] = (P["combo"] + 1) if T - P["combo_t"] < 3.0 else 1
	P["combo_t"] = T
	var v := CombatRules.outgoing_damage(base * CombatRules.combo_multiplier(P["combo"]), G["dmg"], 0.85 + randf() * 0.3, crit)
	return {"v": v, "crit": crit}

func dist_to(m) -> float:
	return Vector2(m.x - P["x"], m.z - P["z"]).length() - m.rad

func nearest_mob(max_d: float):
	var best = null
	var bd := 1e9
	for m in mobs:
		if m.dead:
			continue
		var d := Vector2(m.x - P["x"], m.z - P["z"]).length()
		if d < max_d and d < bd:
			bd = d
			best = m
	return best

func hit_mob(m, r: Dictionary, col: Color = Color.WHITE) -> void:
	if m.dead:
		return
	m.hp -= r["v"]
	skill_xp("onehand", 1.2 if r["crit"] else 1.0)
	hud.clog("%s%s hedefine %d hasar verdin." % ["KRİTİK! " if r["crit"] else "", m.nm, r["v"]], Color("ffd23a") if r["crit"] else Color("e9eef2"))
	sfx.play("crit" if r["crit"] else "hit", -4)
	float_text(Vector3(m.x, 1.9 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), str(r["v"]), Color("ffd23a") if r["crit"] else col, r["crit"])
	P["combat_t"] = T
	add_rage((9.0 if r["crit"] else 6.0) + G["rage"])
	if m.state == "idle":
		m.state = "chase"
		# aynı türden yakındaki sürü üyeleri yardıma gelir
		if m.boss == "" and not m.temp:
			for o in mobs:
				if o != m and not o.dead and o.boss == "" and o.kind == m.kind and o.state == "idle" and Vector2(o.x - m.x, o.z - m.z).length() < 9.0:
					o.state = "chase"
	if m.hp <= 0.0:
		kill_mob(m)

func kill_mob(m) -> void:
	m.dead = true
	m.bleed_t = 0.0
	m.died_at = T
	m.state = "idle"
	WowAssets.play_death(m.node)
	if P["target"] == m:
		P["target"] = null
		P["auto"] = false
	var xp := roundi((14.0 + m.lvl * 9.0) * clampf(1.0 + (m.lvl - P["lvl"]) * 0.15, 0.2, 1.6))
	if m.boss != "":
		xp = BOSSES[m.boss]["xp"]
		_boss_reset(m)
		hud.banner("BOSS ÖLDÜ", m.nm)
		sfx.play("quest")
	if m.elite:
		xp *= 3
	if m.rare:
		xp = roundi(xp * SpawnDirector.rare_reward_multiplier())
	hud.say("%s öldü. +%d tecrübe" % [m.nm, xp], Color("c9a8ff"))
	hud.clog("%s öldü. +%d tecrübe" % [m.nm, xp], Color("c9a8ff"))
	roll_loot(m)
	if m.rare:
		m.loot_money = roundi(m.loot_money * SpawnDirector.rare_reward_multiplier()) + 20
		hud.say("Nadir düşman düştü!", Color("ffd23a"))
	if mm != null:
		mm.on_kill(m.nm)
	quest_kill(m)
	if not m.temp:
		stat_add("kills")
		rep_add(_rep_key(), 120 if m.boss != "" else 4)
	if m.boss != "":
		stat_add("boss_" + m.boss)
		stat_add("bosses")
	gain_xp(xp)

func _normal_loot(m) -> void:
	m.loot_money = 4 + m.lvl * 5 + randi() % 6
	var junk := {"Kurt": "j_wolf", "Yaban Domuzu": "j_boar", "Dağ Ayısı": "j_bear", "Trogg": "j_trogg", "Gnoll": "j_gnoll",
		"Defias Haydudu": "j_defias", "Kara Demir Büyücüsü": "j_dark", "Murloc": "j_murloc", "Murloc Şamanı": "j_murloc", "Timsah": "j_croc", "Bataklık Canavarı": "j_bog",
		"Kara Demir Madencisi": "j_miner", "Taş Golem": "j_golem", "Mağara Örümceği": "j_spider", "Kara Demir Muhafızı": "j_dark"}
	if randf() < 0.55 and junk.has(m.nm):
		m.loot.append({"id": junk[m.nm], "n": 1})
	if P["prof"].has("skin") and BEASTS.has(m.nm) and randf() < 0.7:
		m.loot.append({"id": "hide_raw", "n": 1})
	if randf() < 0.2:
		m.loot.append({"id": "pot_big" if (m.lvl >= 4 and randf() < 0.4) else "pot_heal", "n": 1})
	var r := randf()
	var rar := 0
	if m.nm == "Dağ Ayısı" and r < 0.04:
		rar = 4
	elif r < 0.07:
		rar = 3
	elif r < 0.30:
		rar = 2
	elif r < 0.42:
		rar = 1
	if rar > 0:
		var pl: Array = Items.pool(rar, 1 if rar == 4 else maxi(1, m.lvl - 2), 10 if rar == 4 else m.lvl + 2)
		if not pl.is_empty():
			m.loot.append({"id": pl[randi() % pl.size()], "n": 1})

func roll_loot(m) -> void:
	m.loot = []
	if m.boss != "":
		_boss_loot(m)
	elif m.temp:
		m.loot_money = 6 + m.lvl * 4
		if randf() < 0.3:
			m.loot.append({"id": "pot_heal", "n": 1})
	else:
		_normal_loot(m)
		if m.elite:
			_elite_loot(m)
	m.fade_t = T + (90.0 if m.boss != "" else 25.0)
	var sp := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.13
	sm.height = 0.26
	sp.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color("ffd45a")
	sp.material_override = mat
	sp.position = Vector3(m.x, height_at(m.x, m.z) + 0.8, m.z)
	add_child(sp)
	m.sparkle = sp

## Elit: üç kat para, en az bir yeşil/mavi eşya ve büyülü toz.
func _elite_loot(m) -> void:
	m.loot_money *= 3
	var rar := 3 if randf() < 0.25 else 2
	var pl: Array = Items.pool(rar, maxi(1, m.lvl - 2), m.lvl + 3)
	if not pl.is_empty():
		m.loot.append({"id": pl[randi() % pl.size()], "n": 1})
	m.loot.append({"id": "dust_arc", "n": 1 + randi() % 3})

## Boss başına nadir eşya: taban şans %6, her şanssız boss öldürmede +%2 (en fazla 10 kez); düşünce sayaç sıfırlanır.
const BOSS_RARE := {"gorduk": ["tr_gorduk_rare"], "vurgan": ["bk_vurgan_rare"], "geddon": ["hammer_ember"], "golemagg": ["tr_golem_heart"], "modrek": ["tr_modrek_rare"]}

func _boss_loot(m) -> void:
	var d: Dictionary = BOSSES[m.boss]
	m.loot_money = 300 + m.lvl * 120 + randi() % 200
	var drops: Array = d["drops"]
	var main_id: String = drops[randi() % drops.size()]
	m.loot.append({"id": main_id, "n": 1})
	for id in drops:
		if id != main_id and randf() < 0.3:
			m.loot.append({"id": id, "n": 1})
	if m.boss == "ragnaros" and randf() < 0.15:
		m.loot.append({"id": "hammer_sulf", "n": 1})
	m.loot.append({"id": "pot_big", "n": 2})
	if BOSS_RARE.has(m.boss):
		if randf() < 0.06 + 0.02 * float(P["pity"]):
			var rid: String = BOSS_RARE[m.boss][0]
			m.loot.append({"id": rid, "n": 1})
			P["pity"] = 0
			hud.banner("NADİR EŞYA", Items.get_item(rid)["name"])
		else:
			P["pity"] = mini(10, int(P["pity"]) + 1)

func open_loot(m) -> void:
	if m.loot.is_empty() and m.loot_money <= 0:
		return
	if Vector2(m.x - P["x"], m.z - P["z"]).length() > 5.0 + (m.rad if m.boss != "" else 0.0):
		hud.say("Çok uzaktasın.", Color("ff6a5a"))
		return
	loot_mob = m
	if m.loot_money > 0:
		inv.money += m.loot_money
		hud.say("+%s" % Items.money_plain(m.loot_money), Color("f2c75c"))
		sfx.play("coin", -8)
		m.loot_money = 0
	invui.loot_win.visible = true
	inv_changed()
	if m.loot.is_empty():
		close_loot()

func close_loot() -> void:
	var m = loot_mob
	loot_mob = null
	invui.loot_win.visible = false
	if m != null and m.loot.is_empty() and m.fade_t > T:
		m.fade_t = T
	if m != null and m.sparkle != null and m.loot.is_empty():
		m.sparkle.queue_free()
		m.sparkle = null

## Ganimet penceresindeki tüm eşyaları sırayla alır; çanta dolarsa durur.
func take_all_loot() -> void:
	var m = loot_mob
	if m == null:
		return
	if m.loot_money > 0:
		inv.money += m.loot_money
		hud.say("+%s" % Items.money_plain(m.loot_money), Color("f2c75c"))
		m.loot_money = 0
	var guard: int = m.loot.size()
	while guard > 0 and loot_mob == m and not m.loot.is_empty():
		guard -= 1
		var before: int = m.loot.size()
		take_loot(0)
		if loot_mob != m or m.loot.size() >= before and m.loot.size() > 0 and inv.free_slots() == 0:
			break
	inv_changed()

func take_loot(i: int) -> void:
	var m = loot_mob
	if m == null or i < 0 or i >= m.loot.size():
		return
	var e: Dictionary = m.loot[i]
	var left: int = inv.add(e["id"], e["n"])
	if left > 0:
		e["n"] = left
		hud.say("Çantan dolu.", Color("ff6a5a"))
		return
	var it := Items.get_item(e["id"])
	hud.say("Ganimet: " + it["name"], Items.RARITY_COL[it["rar"]])
	if e["id"] == "hide_raw":
		stat_add("skinned")
		if P["prof"].get("skin", 0) < 50:
			prof_gain("skin")
	sfx.play("click", -4)
	m.loot.remove_at(i)
	inv_changed()
	if m.loot.is_empty():
		close_loot()

func gain_xp(n: float) -> void:
	if P["lvl"] >= MAX_LVL:
		return
	P["xp"] += n
	while P["lvl"] < MAX_LVL and P["xp"] >= xp_need(P["lvl"]):
		P["xp"] -= xp_need(P["lvl"])
		P["lvl"] += 1
		P["hp"] = float(max_hp())
		inv_changed()
		ring_fx(Vector3(P["x"], P["y"], P["z"]), 3.0, Color("f2c75c"), 0.9)
		sfx.play("level")
		hud.banner("SEVİYE %d" % P["lvl"], "Can doldu")
		hud.say("Seviye atladın! Sv %d" % P["lvl"], Color("f2c75c"))
		if P["lvl"] >= 10:
			hud.say("Yetenek puanı kazandın! (N)", Color("9be8a8"))
		for a in HudScript.ABIL:
			if a["lvl"] == P["lvl"]:
				hud.say("Yeni yetenek: %s" % a["name"], Color("7fb8ff"))
				hud.banner("SEVİYE %d" % P["lvl"], "Yeni yetenek: " + a["name"])

func swing() -> void:
	swing_t = 0.001
	swing_style = Items.weapon_style(inv.eq["mainhand"])
	sfx.play("swing", -10)

func auto_attack() -> void:
	var m = P["target"]
	if m == null or m.dead:
		return
	if dist_to(m) > 2.0:
		return
	P["atk_t"] = 1.5 * (1.0 - 0.04 * trk("fur_speed"))
	swing()
	P["yaw"] = atan2(m.x - P["x"], m.z - P["z"])
	hit_mob(m, roll(atk()))

func jump() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	if P["jy"] <= 0.001 and P["vy"] <= 0.0 and P["charge"] == null:
		P["vy"] = 8.6

func _face(m) -> void:
	P["yaw"] = atan2(m.x - P["x"], m.z - P["z"])

func ability(i: int) -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	if i == HudScript.POT:
		use_potion()
		return
	var a: Dictionary = HudScript.ABIL[i]
	if P["lvl"] < a["lvl"]:
		hud.say("%s: Seviye %d'de öğrenilir." % [a["name"], a["lvl"]], Color("ff9a8a"))
		return
	if P["gcd"] > 0.0 or P["cd"][i] > 0.0:
		return
	var cost: float = a["cost"]
	if P["rage"] < cost:
		hud.say("Yeterli öfke yok.", Color("ff9a8a"))
		return
	var kind: String = a["kind"]
	var m = P["target"] if (P["target"] != null and not P["target"].dead) else null
	var pp := Vector3(P["x"], P["y"], P["z"])
	var melee := kind in ["strike", "rend", "execute", "mortal", "slam", "pummel"]
	if melee or kind == "charge" or kind == "throw":
		if m == null:
			m = nearest_mob(25.0 if kind == "charge" else (30.0 if kind == "throw" else 6.0))
		if m == null:
			hud.say("Hedef yok.", Color("ff9a8a"))
			return
		P["target"] = m
		var dd := dist_to(m)
		if melee and dd > 2.6:
			hud.say("Hedef çok uzak.", Color("ff9a8a"))
			return
		if kind == "charge":
			if dd < 6.0:
				hud.say("Hedef çok yakın.", Color("ff9a8a"))
				return
			if dd > 25.0:
				hud.say("Hedef çok uzak.", Color("ff9a8a"))
				return
		if kind == "throw":
			if dd < 4.0:
				hud.say("Hedef çok yakın; yakın dövüş yeteneklerini kullan.", Color("ff9a8a"))
				return
			if dd > 30.0:
				hud.say("Hedef çok uzak.", Color("ff9a8a"))
				return
		if kind == "execute" and m.hp > m.maxhp * 0.2:
			hud.say("Hedef henüz yeterince yaralı değil.", Color("ff9a8a"))
			return
		_face(m)
	P["rage"] -= cost
	P["gcd"] = 1.0
	P["cd"][i] = a["cd"] - (10.0 * trk("fur_reck") if kind == "reck" else 0.0)
	P["combat_t"] = T
	combo_mult = 1.0
	var cb := Combos.bonus(last_ab, T - last_ab_t, kind, m != null and m.bleed_t > 0.0)
	if cb["mult"] > 1.0 and m != null:
		combo_mult = cb["mult"]
		float_text(Vector3(m.x, 3.0 * m.sc + m.node.position.y, m.z), cb["text"], Color("ffb347"), true)
	last_ab = kind
	last_ab_t = T
	match kind:
		"strike":
			swing()
			hit_mob(m, roll(atk() * 2.3 * combo_mult), Color("ffd8a0"))
		"throw":
			swing()
			sfx.play("whirl", -2)
			var tp := Vector3(m.x, height_at(m.x, m.z), m.z)
			ring_fx(tp, 1.5, Color("ffd890"), 0.4)
			hit_mob(m, roll(atk() * 1.9), Color("ffe0a8"))
			float_text(tp + Vector3(0, 2.7 * m.sc, 0), "Fırlatma!", Color("ffd890"), false)
		"pummel":
			swing()
			sfx.play("thunder", -4)
			ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.4, Color("ffe45c"), 0.4)
			hit_mob(m, roll(atk() * 1.2), Color("fff0b0"))
			m.stun = 1.0 if m.boss != "" else 3.0
			var cut: bool = m.ranged > 0.0
			if cut:
				m.atk_t = maxf(m.atk_t, 0.0) + 3.5
			float_text(Vector3(m.x, 2.6 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), "Yarıda kesildi!" if cut else "Sersem!", Color("ffe45c"), false)
		"slam":
			swing()
			sfx.play("thunder", -4)
			ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.6, Color("bfc8e0"), 0.45)
			hit_mob(m, roll(atk() * 2.8), Color("dfe6ff"))
			m.stun = 2.0
			float_text(Vector3(m.x, 2.6 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), "Sersem!", Color("ffe45c"), false)
		"fear":
			sfx.play("shout")
			ring_fx(pp, 8.0, Color("b07aff"), 0.6)
			var feared := 0
			for o in mobs:
				if not o.dead and o.boss == "" and dist_to(o) <= 8.0:
					o.stun = 4.0
					feared += 1
			float_text(pp + Vector3(0, 2.6, 0), "Yıldırtıcı Nara!", Color("d0a8ff"), true)
			if feared == 0:
				hud.say("Yakında düşman yok.", Color("ff9a8a"))
		"reck":
			sfx.play("shout")
			P["rk_t"] = 12.0
			ring_fx(pp, 3.4, Color("ff7a2a"), 0.6)
			float_text(pp + Vector3(0, 2.6, 0), "Delice Öfke!", Color("ff9a4a"), true)
		"laststand":
			sfx.play("level", -4)
			var heal := float(max_hp()) * 0.35
			P["hp"] = minf(float(max_hp()), P["hp"] + heal)
			add_rage(30.0)
			ring_fx(pp, 2.4, Color("5ae07a"), 0.7)
			float_text(pp + Vector3(0, 2.6, 0), "+%d" % roundi(heal), Color("5ae07a"), true)
		"bstorm":
			sfx.play("whirl")
			P["bst_t"] = 6.0
			P["bst_tick"] = 0.0
			ring_fx(pp, 5.0, Color("d0d8e8"), 0.6)
			float_text(pp + Vector3(0, 2.6, 0), "Kılıç Fırtınası!", Color("e8eeff"), true)
		"mortal":
			swing()
			ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.6, Color("ff5040"), 0.45)
			hit_mob(m, roll(atk() * 3.4 * combo_mult), Color("ff9a8a"))
		"execute":
			swing()
			ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 1.8, Color("ffe45c"), 0.5)
			hit_mob(m, roll(atk() * 5.0 * combo_mult * (1.0 + 0.2 * trk("arm_exec"))), Color("ffe08a"))
		"rend":
			swing()
			m.bleed_t = 8.0
			m.bleed_tick = 2.0
			m.bleed_v = atk() * 0.55 * (1.0 + 0.25 * trk("arm_rend"))
			float_text(Vector3(m.x, 2.4 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), "Kanama", Color("ff6a5a"), false)
			hit_mob(m, roll(atk() * 0.5), Color("ffb0a0"))
		"charge":
			sfx.play("charge")
			P["charge"] = m
			P["charge_t"] = 0.0
			P["auto"] = false
			ring_fx(pp, 1.8, Color("ffd890"), 0.4)
		"shout":
			sfx.play("shout")
			P["bs_t"] = 60.0
			ring_fx(pp, 3.4, Color("ffd23a"), 0.6)
			float_text(pp + Vector3(0, 2.6, 0), "Savaş Narası!", Color("ffe08a"), true)
		"shield":
			sfx.play("block")
			P["sb_t"] = 5.0 + trk("pro_shield") + Skills.perk_sum(P["perks"], "blk")
			ring_fx(pp, 1.8, Color("59a9ff"), 0.5)
			float_text(pp + Vector3(0, 2.6, 0), "Kalkan Bloğu", Color("8ec9ff"), false)
		"clap":
			sfx.play("thunder")
			swing()
			ring_fx(pp, 6.0, Color("6aa8ff"), 0.55)
			var any := false
			for o in mobs:
				if not o.dead and dist_to(o) <= 6.0:
					any = true
					o.slow = 8.0
					hit_mob(o, roll(atk() * 1.0 * (1.0 + 0.1 * trk("fur_cleave"))), Color("bfe0ff"))
			if not any:
				hud.say("Yakında düşman yok.", Color("ff9a8a"))
		"whirl":
			sfx.play("whirl")
			P["spin"] = 0.6
			swing()
			ring_fx(pp, 5.0, Color("c8f0f8"), 0.55)
			for o in mobs:
				if not o.dead and dist_to(o) <= 5.0:
					hit_mob(o, roll(atk() * 1.7 * combo_mult * (1.0 + 0.1 * trk("fur_cleave"))), Color("d8f4ff"))
	if melee and not P["auto"] and P["target"] != null:
		P["auto"] = true

func use_potion(want: String = "") -> void:
	if mode != "play" or P["dead"]:
		return
	if potion_count() <= 0:
		hud.say("İksirin kalmadı.")
		return
	if P["pot_cd"] > 0.0:
		return
	if P["hp"] >= max_hp():
		hud.say("Canın zaten dolu.")
		return
	var id := want
	if id == "":
		var big: bool = inv.count("pot_big") > 0 and (max_hp() - P["hp"] > max_hp() * 0.45 or inv.count("pot_heal") == 0)
		id = "pot_big" if big else ("pot_heal" if inv.count("pot_heal") > 0 else "pot_big")
	inv.remove(id, 1)
	sfx.play("potion")
	P["pot_cd"] = 20.0
	var frac: float = Items.get_item(id)["heal"]
	var hv := mini(max_hp() - roundi(P["hp"]), roundi(max_hp() * frac))
	P["hp"] += hv
	float_text(Vector3(P["x"], P["y"] + 2.3, P["z"]), "+%d" % hv, Color("43d17f"), false)
	ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.4, Color("43d17f"), 0.5)
	inv_changed()

func toggle_auto() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	if P["auto"]:
		P["auto"] = false
		return
	if P["target"] == null or P["target"].dead:
		var m = nearest_mob(12.0)
		if m == null:
			hud.say("Yakında düşman yok.")
			return
		P["target"] = m
	P["auto"] = true

func hurt_player(raw: float, m) -> void:
	var arm: float = armor_total()
	if CombatRules.should_evade(randf(), base_agi() + G["agi"], m.lvl - P["lvl"]):
		float_text(Vector3(P["x"], P["y"] + 2.9, P["z"]), "Kaçındın", Color("b8f0ff"), false)
		return
	var blocked: bool = P["sb_t"] > 0.0
	var d := CombatRules.incoming_damage(raw, arm, m.lvl, (1.2 if P["rk_t"] > 0.0 else 1.0) * (1.0 - 0.02 * trk("pro_dr") - Skills.perk_sum(P["perks"], "dr")), blocked)
	if T < P["skin_t"]:
		d = roundi(d * (1.0 - P["skin_red"]))
	skill_xp("heavy", 1.0)
	if blocked:
		skill_xp("block", 1.5)
		add_rage(Skills.perk_sum(P["perks"], "rage") + 0.2 * skl("block"))
		float_text(Vector3(P["x"], P["y"] + 2.9, P["z"]), "Bloklandı", Color("8ec9ff"), false)
		sfx.play("block", -6)
		add_rage(5.0)
	player_hp_loss(d)

func player_hp_loss(d: int) -> void:
	if P["dead"]:
		return
	P["hp"] -= d
	P["combat_t"] = T
	hud.clog("Sen %d hasar aldın." % d, Color("ff6a5a"))
	sfx.play("hurt", -4)
	add_rage(4.0)
	float_text(Vector3(P["x"], P["y"] + 2.2, P["z"]), "-%d" % d, Color("ff6a5a"), false)
	if P["hp"] <= 0.0 and not P["dead"]:
		P["dead"] = true
		stat_add("deaths")
		P["dot_t"] = 0.0
		P["slow_t"] = 0.0
		sfx.play("die")
		P["dead_t"] = T
		P["auto"] = false
		P["target"] = null
		hud.show_dead(true)
		hud.say("Öldün.", Color("ff6a5a"))

func float_text(pos: Vector3, text: String, color: Color, big: bool) -> void:
	var l := Label3D.new()
	l.text = text
	l.modulate = color
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.fixed_size = true
	l.pixel_size = 0.0011
	l.font_size = 64 if big else 44
	l.outline_size = 14
	l.position = pos
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", pos.y + 1.6, 1.0)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 1.0)
	tw.tween_callback(l.queue_free)

func ring_fx(pos: Vector3, radius: float, color: Color, dur: float) -> void:
	var t := TorusMesh.new()
	t.inner_radius = 0.9
	t.outer_radius = 1.0
	t.rings = 32
	t.ring_segments = 4
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(color.r, color.g, color.b, 0.9)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var mi := MeshInstance3D.new()
	mi.mesh = t
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.position = pos + Vector3(0, 0.15, 0)
	mi.scale = Vector3(0.4, 0.3, 0.4)
	add_child(mi)
	var tw := create_tween()
	tw.tween_property(mi, "scale", Vector3(radius, 0.3, radius), dur)
	tw.parallel().tween_property(m, "albedo_color:a", 0.0, dur)
	tw.tween_callback(mi.queue_free)

# ---------- görevler ve diyalog ----------
func q_avail(id: String) -> bool:
	return not qs.has(id) and P["lvl"] >= QUESTS[id]["lvl"]

func render_quests() -> void:
	var lines: Array = []
	for id in qs:
		var s: Dictionary = qs[id]
		if s["st"] == "done":
			continue
		lines.append("%s  %d/%d%s" % [QUESTS[id]["title"], s["n"], QUESTS[id]["n"], " — Teslim et" if s["st"] == "ready" else ""])
	hud.set_quests(lines)

func _mm_setup() -> void:
	mm = MMBridge.new()
	mm.build(Items.db(), QUESTS, [MTYPES, SWAMP_MTYPES, MINE_MTYPES, ASH_MTYPES], HudScript.ABIL)
	for e in mm.errors:
		push_warning("mmorpg: " + e)

func quest_kill(m) -> void:
	for id in qs:
		var s: Dictionary = qs[id]
		var d: Dictionary = QUESTS[id]
		if s["st"] == "active" and d["kill"] == m.nm:
			s["n"] += 1
			if s["n"] >= d["n"]:
				s["n"] = d["n"]
				s["st"] = "ready"
				hud.say("Görev tamam: %s (teslim et)" % d["title"], Color("7fe08a"))
				hud.banner("GÖREV HAZIR", d["title"])
				sfx.play("quest")
				save_game()
			else:
				hud.say("%s: %d/%d" % [d["title"], s["n"], d["n"]], Color("f2c75c"))
	render_quests()

## NPC'nin şu anki görevi: zincirde bitmemiş ilk görev ("" = hepsi bitti).
func npc_quest(n: Dictionary) -> String:
	for id in n["qs"]:
		if not qs.has(id) or qs[id]["st"] != "done":
			return id
	return ""

func npc_mark(n: Dictionary) -> String:
	if n["role"] != "quest":
		return ""
	var id := npc_quest(n)
	if id == "":
		return ""
	if qs.has(id) and qs[id]["st"] == "ready":
		return "?"
	return "!" if q_avail(id) else ""

# ---------- meslekler, itibar, başarımlar ----------
func stat_add(k: String, n: int = 1) -> void:
	P["stats"][k] = int(P["stats"].get(k, 0)) + n
	ach_check()

func quests_done() -> int:
	var c := 0
	for id in qs:
		if qs[id]["st"] == "done":
			c += 1
	return c

func ach_value(a: Dictionary) -> int:
	match a["stat"]:
		"level": return P["lvl"]
		"money": return inv.money
		"quests_all": return 1 if quests_done() >= QUESTS.size() else 0
		"profs": return P["prof"].size()
		"skill_max":
			var mx := 0
			for k in P["prof"]:
				mx = maxi(mx, int(P["prof"][k]))
			return mx
		"rep_friend":
			var c := 0
			for f in Prog.FACTIONS:
				if Prog.rank_of(P["rep"].get(f, 0)) >= 2:
					c += 1
			return c
		"rep_exalted":
			var c2 := 0
			for f in Prog.FACTIONS:
				if Prog.rank_of(P["rep"].get(f, 0)) >= 5:
					c2 += 1
			return c2
		"quests": return quests_done()
		_: return int(P["stats"].get(a["stat"], 0))

func ach_check() -> void:
	for a in Prog.ACHS:
		if P["ach"].has(a["id"]):
			continue
		if ach_value(a) >= int(a["goal"]):
			P["ach"][a["id"]] = true
			hud.banner("BAŞARIM", a["name"])
			hud.say("Başarım: %s (+%d puan)" % [a["name"], a["pts"]], Color("ffe45c"))
			sfx.play("quest")
			if progui != null:
				progui.refresh()

func rep_add(fid: String, n: int) -> void:
	var old: int = P["rep"].get(fid, 0)
	var nv := mini(10000, old + n)
	if nv == old:
		return
	P["rep"][fid] = nv
	var r0 := Prog.rank_of(old)
	var r1 := Prog.rank_of(nv)
	if r1 > r0:
		hud.banner("İTİBAR", "%s: %s" % [Prog.FACTIONS[fid]["name"], Prog.RANKS[r1][0]])
		hud.say("%s itibarın yükseldi: %s" % [Prog.FACTIONS[fid]["name"], Prog.RANKS[r1][0]], Prog.FACTIONS[fid]["col"])
		sfx.play("level")
		ach_check()
	if progui != null:
		progui.refresh()

func vendor_discount(vid: String) -> float:
	var f: String = Prog.VENDOR_FACTION.get(vid, "")
	var base: float = 0.0 if f == "" else Prog.DISCOUNT[Prog.rank_of(P["rep"].get(f, 0))]
	return minf(0.4, base + 0.003 * skl("speech") + Skills.perk_sum(P["perks"], "disc"))

func learn_prof(pid: String) -> void:
	if P["prof"].has(pid):
		return
	P["prof"][pid] = 1
	hud.say("Yeni meslek: %s" % Prog.PROFS[pid]["name"], Color("7fb8ff"))
	hud.banner("MESLEK", Prog.PROFS[pid]["name"])
	sfx.play("quest")
	ach_check()
	inv_changed()
	save_game()

func prof_gain(pid: String, n: int = 1) -> void:
	var old: int = P["prof"].get(pid, 0)
	if old <= 0 or old >= Prog.SKILL_MAX:
		return
	var nv := mini(Prog.SKILL_MAX, old + n)
	P["prof"][pid] = nv
	if Prog.skill_rank(nv) != Prog.skill_rank(old):
		hud.say("%s: %s oldun!" % [Prog.PROFS[pid]["name"], Prog.skill_rank(nv)], Color("ffe45c"))
	ach_check()
	if progui != null:
		progui.refresh()

func can_craft_here() -> bool:
	return map == "snow" and Vector2(P["x"] - CITY.x, P["z"] - CITY.z).length() < 27.0

func craft_error(rid: String) -> String:
	var r := Prog.recipe(rid)
	if r.is_empty():
		return "Bilinmeyen tarif."
	if not P["prof"].has(r["prof"]):
		return "Bu mesleği bilmiyorsun."
	if P["prof"][r["prof"]] < r["skill"]:
		return "Beceri yetersiz."
	if not can_craft_here():
		return "Üretmek için Demirkazan'a gelmelisin."
	for mid in r["mats"]:
		if inv.count(mid) < r["mats"][mid]:
			return "Malzeme eksik."
	if inv.free_slots() < 1:
		return "Çantan dolu."
	return ""

func craft(rid: String) -> void:
	var err := craft_error(rid)
	if err != "":
		hud.say(err, Color("ff6a5a"))
		return
	var r := Prog.recipe(rid)
	for mid in r["mats"]:
		inv.remove(mid, r["mats"][mid])
	inv.add(r["out"], r["n"])
	var it := Items.get_item(r["out"])
	if P["prof"][r["prof"]] < r["skill"] + 20:
		prof_gain(r["prof"])
	stat_add("crafts")
	sfx.play("block")
	ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.6, Color("ffb040"), 0.5)
	hud.say("Üretildi: " + it["name"], Items.RARITY_COL[it["rar"]])
	inv_changed()

# ---------- Savaş Çığlıkları ----------
func _spawn_walls() -> void:
	for w in Shouts.WALLS:
		if w["map"] != map:
			continue
		var sp := _free_spot(w["x"], w["z"])
		for k in 12:
			if height_at(sp.x, sp.y) > -0.3:
				break
			sp = _free_spot(w["x"] + 5.0 * float(k + 1), w["z"] - 4.0 * float(k + 1))
		var y := height_at(sp.x, sp.y)
		var stone := Dwarf.mat(Color.html("5a5a62"), 0.0, 0.9)
		var rune := Dwarf.mat(Color.html("66d8ff"), 0.0, 0.4, Color.html("40c8ff"), 2.0)
		var root := Node3D.new()
		root.position = Vector3(sp.x, y, sp.y)
		root.rotation.y = atan2(-sp.x, -sp.y)
		add_child(root)
		Dwarf.box(root, Vector3(2.2, 4.6, 0.8), stone, Vector3(0, 2.3, 0))
		Dwarf.box(root, Vector3(2.7, 0.5, 1.1), stone, Vector3(0, 0.25, 0))
		var bars: Array = []
		for i in 4:
			var bm := Dwarf.box(root, Vector3(1.4 - 0.2 * float(i % 2), 0.12, 0.05), rune, Vector3(0, 1.4 + 0.75 * float(i), 0.43))
			bm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			bars.append(bm)
		_add_obs(sp.x, sp.y, 1.6)
		var li := OmniLight3D.new()
		li.light_color = Color("66d8ff")
		li.omni_range = 7.0
		li.light_energy = 0.9
		li.position = Vector3(0, 3.0, 1.2)
		root.add_child(li)
		wall_list.append({"id": w["id"], "x": sp.x, "z": sp.y, "light": li, "bars": bars, "rune": rune})
	_refresh_walls()

func _refresh_walls() -> void:
	for wl in wall_list:
		var done: bool = P["walls"].has(wl["id"])
		(wl["light"] as OmniLight3D).light_energy = 0.25 if done else 0.9
		(wl["rune"] as StandardMaterial3D).emission_energy_multiplier = 0.6 if done else 2.0

func near_wall() -> Dictionary:
	for wl in wall_list:
		if Vector2(wl["x"] - P["x"], wl["z"] - P["z"]).length() < 4.0:
			return Shouts.wall_def(wl["id"])
	return {}

func try_read_wall() -> bool:
	var w := near_wall()
	if w.is_empty():
		return false
	if P["walls"].has(w["id"]):
		hud.say("Bu duvardaki kelimeyi zaten biliyorsun: %s" % Shouts.word_text(w), Color("66d8ff"))
		return true
	P["walls"][w["id"]] = true
	var n := Shouts.known(P["walls"], w["shout"])
	var sd: Dictionary = Shouts.SHOUTS[w["shout"]]
	hud.banner("YENİ ÇIĞLIK KELİMESİ", Shouts.word_text(w))
	hud.say("%s: %d/3 kelime. %s" % [sd["name"], n, "Çığlığı kullanmak için Z, değiştirmek için X." if n == 1 else "Çığlık güçlendi."], Color("66d8ff"))
	if n == 1:
		P["shout_sel"] = w["shout"]
	sfx.play("quest")
	gain_xp(120.0 + 40.0 * float(P["lvl"]))
	_refresh_walls()
	save_game()
	return true

func cycle_shout() -> void:
	if mode != "play" or P["dead"]:
		return
	var start: int = Shouts.ORDER.find(P["shout_sel"])
	for i in range(1, Shouts.ORDER.size() + 1):
		var id: String = Shouts.ORDER[(start + i) % Shouts.ORDER.size()]
		if Shouts.known(P["walls"], id) > 0:
			P["shout_sel"] = id
			hud.say("Çığlık: %s (%d/3)" % [Shouts.SHOUTS[id]["name"], Shouts.known(P["walls"], id)], Color("66d8ff"))
			return
	hud.say("Henüz hiç çığlık kelimesi bilmiyorsun. Kelime duvarlarını ara.", Color("ff9a8a"))

func shout_status() -> String:
	var id: String = P["shout_sel"]
	var n := Shouts.known(P["walls"], id)
	if n == 0:
		return ""
	var sd: Dictionary = Shouts.SHOUTS[id]
	var cd: float = P["shout_cd"]
	return "Z — %s %d/3  %s" % [sd["name"], n, "hazır" if cd <= 0.0 else "%d sn" % ceili(cd)]

func use_shout() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	var id: String = P["shout_sel"]
	var n := Shouts.known(P["walls"], id)
	if n == 0:
		hud.say("Bu çığlığın kelimesini henüz bilmiyorsun. Kelime duvarlarını ara.", Color("ff9a8a"))
		return
	if P["shout_cd"] > 0.0:
		hud.say("Çığlık hazır değil (%d sn)." % ceili(P["shout_cd"]), Color("ff9a8a"))
		return
	P["shout_cd"] = Shouts.cooldown(id, n)
	P["combat_t"] = T
	var sd: Dictionary = Shouts.SHOUTS[id]
	var pos := Vector3(P["x"], height_at(P["x"], P["z"]), P["z"])
	var fwd := Vector2(sin(P["yaw"]), cos(P["yaw"]))
	hud.banner(sd["name"].to_upper(), Shouts.SHOUTS[id]["words"][n - 1][0])
	match id:
		"force", "flame":
			var rng: float = sd["range"]
			var col := Color("9ad8ff") if id == "force" else Color("ff8a3a")
			sfx.play("thunder" if id == "force" else "whirl", -2)
			ring_fx(pos, rng * 0.8, col, 0.6)
			for m in mobs.duplicate():
				if m.dead:
					continue
				var off := Vector2(m.x - P["x"], m.z - P["z"])
				var d := off.length()
				if d > rng or (d > 1.5 and off.normalized().dot(fwd) < 0.2):
					continue
				hit_mob(m, roll(atk() * Shouts.power(id, "mult", n)), col)
				if id == "force" and not m.dead:
					knockback(m, Shouts.power(id, "knock", n) * (0.4 if m.boss != "" else 1.0))
		"skin":
			P["skin_t"] = T + Shouts.power(id, "dur", n)
			P["skin_red"] = Shouts.power(id, "red", n)
			sfx.play("block", -2)
			ring_fx(pos, 2.6, Color("c8d8e8"), 0.8)
			float_text(pos + Vector3(0, 3.0, 0), "Demir Deri!", Color("c8d8e8"), false)

func near_node() -> Dictionary:
	for n in res_nodes:
		if n["on"] and Vector2(n["x"] - P["x"], n["z"] - P["z"]).length() < 3.2:
			return n
	return {}

func try_gather() -> void:
	var n: Dictionary = near_node()
	if n.is_empty():
		return
	var nd: Dictionary = Prog.NODES[n["kind"]]
	if not P["prof"].has("mine"):
		hud.say("Madencilik öğrenmen gerek (Madenci Başı Durin).", Color("ff6a5a"))
		return
	var sk: int = P["prof"]["mine"]
	if sk < nd["skill"]:
		hud.say("Bu damar için Madencilik %d gerekli." % nd["skill"], Color("ff6a5a"))
		return
	var cnt := randi_range(1, 2)
	var left: int = inv.add(nd["item"], cnt)
	if left >= cnt:
		hud.say("Çantan dolu.", Color("ff6a5a"))
		return
	n["on"] = false
	n["t"] = T + 150.0
	n["node"].visible = false
	var got := cnt - left
	hud.say("Topladın: %d %s" % [got, Items.get_item(nd["item"])["name"]], Color("e0e0e0"))
	float_text(Vector3(n["x"], P["y"] + 1.8, n["z"]), "+%d %s" % [got, Items.get_item(nd["item"])["name"]], nd["glow"], false)
	ring_fx(Vector3(n["x"], height_at(n["x"], n["z"]), n["z"]), 1.4, nd["glow"], 0.4)
	sfx.play("block")
	stat_add("ore", got)
	if sk < nd["cap"]:
		prof_gain("mine")
	inv_changed()

func _make_node(kind: String, x: float, z: float) -> void:
	var nd: Dictionary = Prog.NODES[kind]
	var g := Node3D.new()
	g.position = Vector3(x, height_at(x, z), z)
	add_child(g)
	var rock := Dwarf.mat(nd["col"], 0.2, 0.8)
	var glow := Dwarf.mat(nd["glow"], 0.0, 0.4, nd["glow"], 1.8)
	for k in 3:
		var a := float(k) / 3.0 * TAU
		var h := 0.9 + hash2(x + k, z) * 0.7
		var c := Dwarf.cone(g, 0.5, h, rock, Vector3(cos(a) * 0.35, h / 2.0 - 0.05, sin(a) * 0.35), 5)
		c.rotation.y = a
	for k in 5:
		var a2 := float(k) / 5.0 * TAU + 0.4
		var cr := Dwarf.box(g, Vector3(0.14, 0.4, 0.14), glow, Vector3(cos(a2) * 0.5, 0.55, sin(a2) * 0.5))
		cr.rotation = Vector3(cos(a2) * 0.5, a2, sin(a2) * 0.5)
	_add_obs(x, z, 0.9)
	res_nodes.append({"kind": kind, "x": x, "z": z, "node": g, "t": 0.0, "on": true})

func _spawn_nodes() -> void:
	res_nodes.clear()
	var rnd := RandomNumberGenerator.new()
	rnd.seed = 555
	if map == "snow":
		var n := 0
		var tries := 0
		while n < 9 and tries < 500:
			tries += 1
			var a := rnd.randf() * TAU
			var r := 28.0 + rnd.randf() * 52.0
			var x := cos(a) * r
			var z := sin(a) * r
			if Vector2(x - CITY.x, z - CITY.z).length() < CITY.r + 8.0:
				continue
			var blocked := false
			for o in obs:
				if Vector2(o.x - x, o.y - z).length() < o.z + 2.5:
					blocked = true
					break
			if blocked:
				continue
			_make_node("iron", x, z)
			n += 1
	elif map == "mine":
		var kinds := [["iron", "iron"], ["iron", "dark"], ["dark", "dark"], ["dark", "dark"]]
		for i in kinds.size():
			var rm: Array = MINE_ROOMS[i + 1]
			for k in 2:
				for tr in 40:
					var ang := rnd.randf() * TAU
					var rr := float(rm[2]) - 2.0
					var px := float(rm[0]) + cos(ang) * rr
					var pz := float(rm[1]) + sin(ang) * rr
					if _mine_sd(px + cos(ang) * 3.5, pz + sin(ang) * 3.5) < -0.3:
						continue
					var bl := false
					for o in obs:
						if Vector2(o.x - px, o.y - pz).length() < o.z + 2.0:
							bl = true
							break
					if bl:
						continue
					_make_node(kinds[i][k], px, pz)
					break
		for a2 in MINE_ALC:
			var al: Array = a2
			_make_node("dark", float(al[0]) + 2.2, float(al[1]) + 1.6)

func near_npc():
	var best = null
	var bd := 4.2
	for n in npcs:
		if n["role"] == "amb":
			continue
		var d := Vector2(n["x"] - P["x"], n["z"] - P["z"]).length()
		if d < bd:
			bd = d
			best = n
	return best

func open_talk() -> void:
	if mode != "play" or P["dead"] or dlg_open:
		return
	var n = near_npc()
	if n == null:
		return
	dlg_open = true
	cur_npc = n
	P["auto"] = false
	npc_mem = NPCDialogue.record_interaction(npc_mem, n["id"], T)
	var rk: String = _rep_key()
	dlg_extra = NPCDialogue.greeting(n["name"], int(NPCDialogue.memory_entry(npc_mem, n["id"]).get("interactions", 1)), int(P["rep"].get(rk, 0)))
	render_dialog()

func close_dialog() -> void:
	dlg_open = false
	cur_npc = null
	dlg_extra = ""
	hud.hide_dialog()

func item_brief(it: Dictionary) -> String:
	if it["slot"] == "mainhand":
		return "%d-%d hasar" % [it["dmin"], it["dmax"]]
	if it["armor"] > 0:
		return "%d zırh" % it["armor"]
	return "+%d güç" % it["str"] if it["str"] > 0 else "+%d çeviklik" % it["agi"]

func reward_pick(qid: String) -> void:
	var q: Dictionary = QUESTS[qid]
	var buttons: Array = []
	for id in q["rew"]:
		var it := Items.get_item(id)
		buttons.append({"label": "%s  (%s)" % [it["name"], item_brief(it)], "disabled": inv.free_slots() < 1, "cb": func():
			qs[qid]["st"] = "done"
			if mm != null:
				mm.on_turn_in(qid)
			stat_add("quests")
			rep_add(Prog.faction_of_quest(qid, SWAMP_QS), (300 + q["lvl"] * 20) * (2 if q["n"] == 1 else 1))
			inv.add(id, 1)
			inv.money += q["money"]
			sfx.play("coin")
			hud.say("Ödül: %d XP, %s, %s" % [q["xp"], Items.money_plain(q["money"]), it["name"]], Color("f2c75c"))
			render_quests()
			close_dialog()
			gain_xp(q["xp"] * (1.0 + Skills.perk_sum(P["perks"], "qxp")))
			inv_changed()
			save_game()})
	buttons.append({"label": "Geri", "cb": render_dialog})
	var body := "Bir ödül seç." if inv.free_slots() > 0 else "Çantan dolu, önce yer aç."
	hud.show_dialog(cur_npc["name"], cur_npc["title"], body, buttons)

func open_vendor(n: Dictionary) -> void:
	close_dialog()
	vendor_npc = n
	vendor_tab = 0
	Items.disc = vendor_discount(n["id"])
	if Items.disc > 0.0:
		hud.say("İtibar indirimi: %%%d" % roundi(Items.disc * 100.0), Color("9be8a8"))
	invui.char_win.visible = false
	invui.vend_win.visible = true
	invui.bag_win.visible = true
	inv_changed()

func close_vendor() -> void:
	vendor_npc = null
	Items.disc = 0.0
	invui.vend_win.visible = false
	invui.hide_tip()

## Dallanan sohbet düğümünü gösterir; etkileri (bilgi, itibar, para...) ilk seferde uygular.
func talk_node(npc_id: String, node_id: String) -> void:
	var node: Dictionary = DialogueTrees.node(npc_id, node_id)
	if node.is_empty() or cur_npc == null:
		render_dialog()
		return
	var key := "%s:%s" % [npc_id, node_id]
	var first: bool = not P["talked"].has(key)
	if first or not node.get("once", false):
		_talk_effects(node, first)
	P["talked"][key] = true
	var buttons: Array = []
	for o in node.get("opts", []):
		var why := _talk_block(o.get("need", {}))
		var opt: Dictionary = o
		buttons.append({"label": o["label"] + ("  [%s]" % why if why != "" else ""), "disabled": why != "", "cb": func(): _talk_choose(npc_id, opt)})
	buttons.append({"label": "Sohbeti bitir", "cb": render_dialog})
	hud.show_dialog(cur_npc["name"], cur_npc["title"], node["text"], buttons)

func _talk_block(need: Dictionary) -> String:
	if need.has("speech") and skl("speech") < int(need["speech"]):
		return "Hitabet %d" % need["speech"]
	if need.has("lvl") and P["lvl"] < int(need["lvl"]):
		return "Seviye %d" % need["lvl"]
	if need.has("q") and not (qs.has(need["q"]) and qs[need["q"]]["st"] == "done"):
		return "Görev: %s" % QUESTS[need["q"]]["title"]
	return ""

func _talk_effects(node: Dictionary, first: bool) -> void:
	if node.has("lore") and Journal.unlock(P["lore"], node["lore"]):
		hud.say("Günlüğe eklendi: %s" % Journal.LORE[node["lore"]]["title"], Color("c9a8ff"))
		sfx.play("quest", -8)
		skill_xp("speech", 2.0)
		if progui != null:
			progui.refresh()
	if not first and node.get("once", false):
		return
	if node.has("rep"):
		rep_add(str(node["rep"][0]), int(node["rep"][1]))
	if node.has("money"):
		inv.money += int(node["money"])
		sfx.play("coin")
		hud.say("+%s" % Items.money_plain(int(node["money"])), Color("f2c75c"))
	if node.has("xp"):
		gain_xp(float(node["xp"]))
	inv_changed()
	save_game()

func _talk_choose(npc_id: String, o: Dictionary) -> void:
	if o.has("check"):
		var ck: Dictionary = o["check"]
		var key := "%s:%s" % [npc_id, ck["ok"]]
		if P["talked"].has(key):
			hud.say("Bunu zaten konuştunuz.", Color("c8c8c8"))
			talk_node(npc_id, "start")
			return
		var rk: String = _rep_key()
		var bonus := skl("speech") / 2 + Prog.rank_of(P["rep"].get(rk, 0))
		var rl := randi_range(1, 20)
		var ok: bool = rl + bonus >= int(ck["dc"])
		skill_xp("speech", 3.0)
		hud.say("İkna %s  (zar %d + %d ≥ %d)" % ["başarılı" if ok else "başarısız", rl, bonus, ck["dc"]], Color("7fe08a") if ok else Color("ff9a8a"))
		talk_node(npc_id, ck["ok"] if ok else ck["fail"])
		return
	var nx: String = o.get("next", "")
	if nx == "":
		render_dialog()
	else:
		talk_node(npc_id, nx)

func render_dialog() -> void:
	var n = cur_npc
	var body := ""
	var buttons: Array = []
	if n["role"] == "quest":
		var qid := npc_quest(n)
		if qid == "":
			body = "Yardımın için sağ ol, kahraman. Şimdilik başka işim yok."
		else:
			var q: Dictionary = QUESTS[qid]
			if not qs.has(qid):
				if P["lvl"] < q["lvl"]:
					body = "Biraz daha güçlenince gel. (Seviye %d gerekli)" % q["lvl"]
				else:
					body = "%s\n\nGörev: %d %s öldür.\nÖdül: %d tecrübe, %s ve bir eşya seçimi." % [q["text"], q["n"], q["kill"], q["xp"], Items.money_plain(q["money"])]
					buttons.append({"label": "Görevi kabul et", "cb": func():
						qs[qid] = {"st": "active", "n": 0}
						if mm != null:
							mm.on_accept(qid, P["lvl"])
						sfx.play("quest")
						hud.say("Görev alındı: " + q["title"], Color("f2c75c"))
						save_game()
						render_quests()
						close_dialog()})
			else:
				var st: Dictionary = qs[qid]
				if st["st"] == "active":
					body = "%s: %d/%d %s. Devam et!" % [q["title"], st["n"], q["n"], q["kill"]]
				else:
					body = q["done"]
					buttons.append({"label": "Ödülü al", "cb": func(): reward_pick(qid)})
	elif n["role"] == "vendor":
		body = "Taze iksirler, sıcak çorba, sağlam zırhlar! Ne lazım?"
		buttons.append({"label": "Alışveriş", "cb": func(): open_vendor(n)})
	elif n["role"] == "bank":
		body = "Eşyaların bende güvende, savaşçı. Banka %d yuvalık, şu an %d dolu. Yuva eklemek istersen bana söyle." % [inv.bank_size, inv.bank.size()]
		buttons.append({"label": "Bankayı aç", "cb": func(): open_vendor(n)})
	elif n["role"] == "smith":
		var cost: int = 300 + 250 * P["wep_lvl"]
		buttons.append({"label": "Alışveriş", "cb": func(): open_vendor(n)})
		if P["wep_lvl"] >= 6:
			body = "Baltan bundan fazla bilenmez, usta. Yeni silah bakacak mısın?"
		else:
			body = "Baltanı bileyleyeyim mi? Her bileme +3 saldırı. Şu anki bileme: %d/6." % P["wep_lvl"]
			buttons.append({"label": "Bileyle (%s)" % Items.money_plain(cost), "disabled": inv.money < cost, "cb": func():
				if inv.money >= cost:
					inv.money -= cost
					P["wep_lvl"] += 1
					P["wep_b"] += 3.0
					sfx.play("block")
					hud.say("Silah bilendi: +3 saldırı", Color("f2c75c"))
					ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.6, Color("ffb040"), 0.5)
					inv_changed()
				render_dialog()})
	elif n["role"] == "inn":
		var wait := ceili(60.0 - (T - last_rest))
		if wait > 0:
			body = "Az önce dinlendin, biraz bekle (%d sn)." % wait
		else:
			body = "Sıcak çorba ve yumuşak yatak. Biraz dinlen, savaşçı."
			buttons.append({"label": "Dinlen (canı doldur)", "cb": func():
				P["hp"] = float(max_hp())
				P["rage"] = 0.0
				last_rest = T
				hud.say("Dinlendin, canın doldu.", Color("43d17f"))
				render_dialog()})
	if dlg_extra != "":
		body = "<%s>\n\n%s" % [dlg_extra, body]
	if DialogueTrees.has_tree(n["id"]):
		buttons.append({"label": "Sohbet et", "cb": func(): talk_node(n["id"], "start")})
	for tpc in [["rumors", "Söylentiler"], ["danger", "Bölge tehlikeleri"]]:
		buttons.append({"label": tpc[1], "cb": func():
			var rc := NPCDialogue.topic_count(npc_mem, n["id"], tpc[0])
			npc_mem = NPCDialogue.remember_topic(npc_mem, n["id"], tpc[0], T)
			dlg_extra = NPCDialogue.topic_response(n["name"], tpc[0], map, rc)
			render_dialog()})
	var tp: String = {"durin": "mine", "ragna": "skin", "borga": "smith"}.get(n["id"], "")
	if tp != "":
		var pdn: String = Prog.PROFS[tp]["name"]
		if P["prof"].has(tp):
			body += "\n\n%s: %s %d/%d (K)" % [pdn, Prog.skill_rank(P["prof"][tp]), P["prof"][tp], Prog.SKILL_MAX]
		else:
			buttons.append({"label": "Mesleği öğren: " + pdn + " (ücretsiz)", "cb": func():
				learn_prof(tp)
				render_dialog()})
	buttons.append({"label": "Kapat", "cb": close_dialog})
	hud.show_dialog(n["name"], n["title"], body, buttons)

# ---------- güncelleme ----------
func _process(delta: float) -> void:
	if paused:
		return
	step(minf(delta, 0.05))

func collide(x: float, z: float, r: float) -> Vector2:
	for o in obs:
		var dx: float = x - o.x
		var dz: float = z - o.y
		var rr: float = r + o.z
		var d2 := dx * dx + dz * dz
		if d2 < rr * rr and d2 > 0.000001:
			var d := sqrt(d2)
			x = o.x + dx / d * rr
			z = o.y + dz / d * rr
	if map == "mine":
		for _it in 3:
			var sd := _mine_sd(x, z)
			if sd <= -r:
				break
			var gx := _mine_sd(x + 0.1, z) - sd
			var gz := _mine_sd(x, z + 0.1) - sd
			var gl := sqrt(gx * gx + gz * gz)
			if gl < 0.0001:
				break
			var push := sd + r
			x -= gx / gl * push
			z -= gz / gl * push
	return Vector2(x, z)

func step(dt: float) -> void:
	T += dt
	_check_windows()
	_update_amb_npcs(dt)
	if mode == "play" and not P["dead"]:
		save_t += dt
		if save_t >= 20.0:
			save_t = 0.0
			save_game()
	var ix := 0.0
	var iy := 0.0
	if mode == "play" and not P["dead"]:
		if kp("left") or Input.is_key_pressed(KEY_LEFT):
			ix -= 1.0
		if kp("right") or Input.is_key_pressed(KEY_RIGHT):
			ix += 1.0
		if kp("fwd") or Input.is_key_pressed(KEY_UP):
			iy += 1.0
		if kp("back") or Input.is_key_pressed(KEY_DOWN):
			iy -= 1.0
		if kp("turnl"):
			cam_yaw += dt * 1.8
		if kp("turnr"):
			cam_yaw -= dt * 1.8
	if mode == "title":
		cam_yaw += dt * 0.12
	if dlg_open:
		ix = 0.0
		iy = 0.0
	_step_player(dt, ix, iy)
	if P["slow_t"] > 0.0:
		P["slow_t"] -= dt
	if P["dot_t"] > 0.0 and not P["dead"]:
		P["dot_t"] -= dt
		P["dot_k"] -= dt
		if P["dot_k"] <= 0.0:
			P["dot_k"] += 1.0
			player_hp_loss(maxi(1, roundi(P["dot_v"])))
	for m in mobs:
		if not m.dead and SpawnDirector.should_throttle(Vector2(m.x - P["x"], m.z - P["z"]).length(), m.boss != "", m.temp):
			m.thr += dt
			if m.thr < SpawnDirector.FAR_AI_INTERVAL:
				continue
			_step_mob(m, m.thr)
			m.thr = 0.0
			continue
		_step_mob(m, dt)
	for i in range(mobs.size() - 1, -1, -1):
		if mobs[i].gc:
			mobs.remove_at(i)
	_step_npcs(dt)
	_step_portals(dt)
	_animate_player(dt)
	_update_camera(dt)
	_step_effects(dt)
	_update_hud()

func _check_windows() -> void:
	if vendor_npc != null and Vector2(vendor_npc["x"] - P["x"], vendor_npc["z"] - P["z"]).length() > 7.0:
		close_vendor()
	if loot_mob != null and Vector2(loot_mob.x - P["x"], loot_mob.z - P["z"]).length() > 6.5 + (loot_mob.rad if loot_mob.boss != "" else 0.0):
		close_loot()

func _step_player(dt: float, ix: float, iy: float) -> void:
	var il := minf(1.0, Vector2(ix, iy).length())
	var moving: bool = il > 0.12 and mode == "play" and not P["dead"]
	if not P["dead"] and mode == "play":
		var fx := -sin(cam_yaw)
		var fz := -cos(cam_yaw)
		var rx := -fz
		var rz := fx
		var sp := 5.0 * (0.5 if P["slow_t"] > 0.0 else 1.0) * (1.0 + 0.003 * skl("athletics") + Skills.perk_sum(P["perks"], "spd"))
		var chm = P["charge"]
		if chm != null and (chm.dead or P["charge_t"] > 2.0):
			P["charge"] = null
			chm = null
		if chm != null:
			P["charge_t"] += dt
			var cdist := dist_to(chm)
			P["yaw"] = atan2(chm.x - P["x"], chm.z - P["z"])
			if cdist <= 1.7:
				P["charge"] = null
				add_rage(15.0)
				chm.stun = 1.5
				if chm.state == "idle":
					chm.state = "chase"
				ring_fx(Vector3(chm.x, height_at(chm.x, chm.z), chm.z), 2.2, Color("ffd890"), 0.4)
				float_text(Vector3(chm.x, 2.4 * chm.sc, chm.z) + Vector3(0, chm.node.position.y, 0), "Sersem", Color("8ec9ff"), false)
				P["combat_t"] = T
				P["auto"] = true
				P["spd"] = 0.0
			else:
				var cl: float = cdist + chm.rad
				var cc := collide(P["x"] + (chm.x - P["x"]) / cl * 24.0 * dt, P["z"] + (chm.z - P["z"]) / cl * 24.0 * dt, 0.5)
				P["x"] = cc.x
				P["z"] = cc.y
				P["spd"] = 1.8
		elif moving:
			skill_xp("athletics", 0.4 * dt)
			var dx := fx * iy + rx * ix
			var dz := fz * iy + rz * ix
			var dl := maxf(0.0001, Vector2(dx, dz).length())
			dx /= dl
			dz /= dl
			var c := collide(P["x"] + dx * sp * il * dt, P["z"] + dz * sp * il * dt, 0.5)
			var rr := c.length()
			if rr > WORLD_R:
				c *= WORLD_R / rr
			P["x"] = c.x
			P["z"] = c.y
			if not (P["target"] != null and not P["target"].dead):
				P["auto"] = false
			var ty := atan2(dx, dz)
			var df := fposmod(ty - P["yaw"] + PI, TAU) - PI
			P["yaw"] += df * minf(1.0, dt * 14.0)
			P["spd"] = il
		elif P["auto"] and P["target"] != null and not P["target"].dead:
			var m = P["target"]
			var d0 := dist_to(m)
			if d0 > 1.8:
				var vx: float = (m.x - P["x"]) / (d0 + m.rad)
				var vz: float = (m.z - P["z"]) / (d0 + m.rad)
				var c2 := collide(P["x"] + vx * sp * dt, P["z"] + vz * sp * dt, 0.5)
				P["x"] = c2.x
				P["z"] = c2.y
				P["spd"] = 1.0
			else:
				P["spd"] = 0.0
			P["yaw"] = atan2(m.x - P["x"], m.z - P["z"])
		else:
			P["spd"] = 0.0
		P["atk_t"] = maxf(0.0, P["atk_t"] - dt)
		P["gcd"] = maxf(0.0, P["gcd"] - dt)
		P["pot_cd"] = maxf(0.0, P["pot_cd"] - dt)
		P["shout_cd"] = maxf(0.0, P["shout_cd"] - dt)
		for i in P["cd"].size():
			P["cd"][i] = maxf(0.0, P["cd"][i] - dt)
		P["rk_t"] = maxf(0.0, P["rk_t"] - dt)
		if P["bst_t"] > 0.0:
			P["bst_t"] -= dt
			P["bst_tick"] -= dt
			P["spin"] = 0.3
			if P["bst_tick"] <= 0.0:
				P["bst_tick"] = 0.8
				var ppb := Vector3(P["x"], P["y"], P["z"])
				ring_fx(ppb, 5.0, Color("c8d4e8"), 0.35)
				for o in mobs:
					if not o.dead and dist_to(o) <= 5.0:
						hit_mob(o, roll(atk() * 1.3 * (1.0 + 0.1 * trk("fur_cleave"))), Color("d8e4ff"))
		P["bs_t"] = maxf(0.0, P["bs_t"] - dt)
		P["sb_t"] = maxf(0.0, P["sb_t"] - dt)
		P["spin"] = maxf(0.0, P["spin"] - dt)
		P["vy"] -= 24.0 * dt
		P["jy"] += P["vy"] * dt
		if P["jy"] <= 0.0:
			P["jy"] = 0.0
			P["vy"] = maxf(P["vy"], 0.0) if P["vy"] > 0.0 else 0.0
		if P["auto"] and P["target"] != null and not P["target"].dead and P["atk_t"] <= 0.0:
			auto_attack()
		var ooc := not in_combat()
		P["hp"] = minf(float(max_hp()), P["hp"] + (max_hp() * 0.015 if ooc else 0.3) * dt)
		if ooc:
			P["rage"] = maxf(0.0, P["rage"] - 4.0 * dt)
		if P["target"] != null and (P["target"].dead or Vector2(P["target"].x - P["x"], P["target"].z - P["z"]).length() > 30.0):
			P["target"] = null
			P["auto"] = false
	elif P["dead"]:
		P["spd"] = 0.0
		if T - P["dead_t"] > 3.2:
			P["dead"] = false
			P["hp"] = max_hp() * 0.6
			P["rage"] = 0.0
			P["x"] = 0.0
			P["z"] = 76.0 if map == "mine" else 7.0
			P["combat_t"] = -99.0
			P["dot_t"] = 0.0
			P["slow_t"] = 0.0
			hud.show_dead(false)
			for m in mobs:
				if m.state == "chase":
					m.state = "return"
			hud.say("Madenin girişinde canlandın." if map == "mine" else "Kamp ateşinde canlandın.", Color("6aa8ff"))
	P["y"] = height_at(P["x"], P["z"]) + P["jy"]

# ---------- boss yetenekleri ----------
func _bpos(m) -> Vector3:
	return Vector3(m.x, m.node.position.y + (7.0 if m.boss == "ragnaros" else 2.6 * m.sc), m.z)

func _bready(m, key: String) -> bool:
	return m.cd.get(key, 0.0) <= 0.0

func _bset(m, key: String, t: float) -> void:
	m.cd[key] = t

func boss_say(m, text: String) -> void:
	hud.say(text, Color("ffb050"))

func boss_hit(m, mult: float, label: String) -> void:
	hurt_player(m.dmg * mult * (0.9 + randf() * 0.2), m)
	float_text(_bpos(m), label, Color("ffd060"), true)
	m.lunge = 0.25
	m.atk_t = maxf(m.atk_t, 1.2)

## Büyü hasarı: zırh sayılmaz, bloklanmaz.
func boss_spell(m, mult: float, label: String, col: Color) -> void:
	var dmg := maxi(1, roundi(m.dmg * mult * (0.9 + randf() * 0.2) * 0.75))
	player_hp_loss(dmg)
	float_text(_bpos(m), label, col, true)
	ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.8, col, 0.5)
	m.atk_t = maxf(m.atk_t, 1.0)

func knockback(m, dist: float) -> void:
	var dx: float = P["x"] - m.x
	var dz: float = P["z"] - m.z
	var l := maxf(0.01, sqrt(dx * dx + dz * dz))
	var c := collide(P["x"] + dx / l * dist, P["z"] + dz / l * dist, 0.5)
	var rr := c.length()
	if rr > WORLD_R:
		c *= WORLD_R / rr
	P["x"] = c.x
	P["z"] = c.y

func apply_dot(total_t: float, per_tick: float, label: String, col: Color) -> void:
	P["dot_t"] = total_t
	P["dot_v"] = per_tick
	P["dot_k"] = 1.0
	float_text(Vector3(P["x"], P["y"] + 2.9, P["z"]), label, col, false)

func _boss_engage(m) -> void:
	m.engaged = true
	boss_say(m, BOSSES[m.boss]["say"])
	hud.banner(m.nm.to_upper(), m.title)
	sfx.play("shout")
	match m.boss:
		"hogger":
			_bset(m, "sum", 0.0)
		"ragnaros":
			_bset(m, "wrath", 8.0)
			_bset(m, "lava", 5.0)
		"vancleef":
			_bset(m, "stab", 5.0)
			_bset(m, "poison", 6.0)
		"choksul":
			_bset(m, "slam", 5.0)
		"grik":
			_bset(m, "nova", 5.0)
			_bset(m, "bolt", 2.0)
		"thokk":
			_bset(m, "nova", 5.0)
			_bset(m, "smash", 3.0)
			_bset(m, "spike", 2.0)
		"arctikus":
			_bset(m, "maul", 5.0)
			_bset(m, "rend", 8.0)
		"gorduk":
			_bset(m, "stomp", 4.0)
			_bset(m, "quake", 8.0)
			_bset(m, "rocks", 3.0)
		"vurgan":
			_bset(m, "cleave", 4.0)
			_bset(m, "bolt", 3.0)
			_bset(m, "flame", 8.0)
		"golemagg":
			_bset(m, "stomp", 4.0)
			_bset(m, "quake", 8.0)
			_bset(m, "rocks", 3.0)
		"geddon":
			_bset(m, "cleave", 4.0)
			_bset(m, "bolt", 3.0)
			_bset(m, "inferno", 9.0)
			_bset(m, "bomb", 6.0)
		"sulfuron":
			_bset(m, "hammer", 4.0)
			_bset(m, "bolt", 3.0)
			_bset(m, "flame", 8.0)
		"gruff":
			_bset(m, "roll", 6.0)
			_bset(m, "snap", 3.0)
			_bset(m, "mud", 4.0)

func _boss_reset(m) -> void:
	m.engaged = false
	m.cd = {}
	m.flags = {}
	m.eat_t = 0.0
	m.dmg = m.base_dmg
	m.spd = m.base_spd
	m.atk_int = 2.4
	for a in mobs:
		if a.owner_m == m and not a.dead:
			a.dead = true
			a.died_at = T
			a.fade_t = T
			a.loot = []
			a.loot_money = 0
	if m.dead:
		return
	m.hp = minf(m.maxhp, m.hp)

func _boss_summon(m, nm: String, model: String, n: int, hp: float, dmg: float, spd: float, sc: float, ring: float) -> void:
	for i in n:
		if not SpawnDirector.can_spawn_add(mobs, m):
			break
		var a := float(i) / n * TAU + randf()
		spawn_add(m, nm, model, m.lvl - 1, hp, dmg, spd, sc, Vector2(cos(a), sin(a)) * ring)

## true: bu tur sıradan saldırı yapma.
func _boss_ai(m, dt: float, d: float) -> bool:
	for k in m.cd.keys():
		m.cd[k] = maxf(0.0, m.cd[k] - dt)
	var hpf: float = m.hp / m.maxhp
	if m.eat_t > 0.0:
		m.eat_t -= dt
		m.hp = minf(m.maxhp, m.hp + m.maxhp * 0.06 * dt)
		return true
	var melee: bool = d <= m.rad + m.reach + 0.6
	match m.boss:
		"gorduk":
			if hpf < 0.25 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.2
				boss_say(m, "Gorduk'un çatlakları kızıl parlıyor!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if hpf < 0.6 and not m.flags.has("shards"):
				m.flags["shards"] = true
				boss_say(m, "Gorduk'un gövdesinden taş parçaları koptu!")
				_boss_summon(m, "Taş Parçası", "golem", 3, 260.0, 14.0, 3.2, 0.8, 3.5)
			if d <= 8.0 and _bready(m, "quake"):
				_bset(m, "quake", 10.0)
				boss_spell(m, 1.4, "Deprem", Color("d8b070"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 8.0, Color("d8b070"), 0.6)
				knockback(m, 6.0)
				sfx.play("thunder", -4)
				return true
			if melee and _bready(m, "stomp"):
				_bset(m, "stomp", 6.0)
				boss_hit(m, 2.0, "Taş Yumruk")
				return true
			if d > m.rad + m.reach + 1.5 and d < 22.0 and _bready(m, "rocks"):
				_bset(m, "rocks", 7.0)
				boss_spell(m, 0.9, "Kaya Fırlatma", Color("8a8070"))
				return true
		"arctikus":
			if hpf < 0.5 and not m.flags.has("pack"):
				m.flags["pack"] = true
				boss_say(m, "Arctikus uludu; kar kurtları çağrıya geldi!")
				_boss_summon(m, "Kar Kurdu", "wolf", 2, 180.0, 9.0, 5.0, 1.0, 3.0)
			if d <= 8.0 and _bready(m, "roar"):
				_bset(m, "roar", 12.0)
				boss_spell(m, 1.0, "Donduran Kükreme", Color("8ad0ff"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 8.0, Color("8ad0ff"), 0.6)
				P["slow_t"] = 4.0
				return true
			if melee and _bready(m, "claw"):
				_bset(m, "claw", 6.0)
				boss_hit(m, 1.8, "Pençe Darbesi")
				return true
		"grik":
			if hpf < 0.4 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.15
				boss_say(m, "Grik'nir: Donmuş baltam seni bulacak!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if melee and _bready(m, "axe"):
				_bset(m, "axe", 7.0)
				boss_hit(m, 2.0, "Buz Baltası")
				return true
			if d > m.rad + m.reach + 1.5 and d < 20.0 and _bready(m, "spear"):
				_bset(m, "spear", 9.0)
				boss_spell(m, 0.9, "Buz Mızrağı", Color("a8e0ff"))
				return true
		"choksul":
			if hpf < 0.5 and not m.flags.has("aides"):
				m.flags["aides"] = true
				boss_say(m, "Chok'sul: Çıraklar, ezin onları!")
				_boss_summon(m, "Ogre Çırağı", "trogg", 2, 300.0, 14.0, 3.6, 1.1, 3.0)
			if d <= 7.0 and _bready(m, "quake"):
				_bset(m, "quake", 10.0)
				boss_spell(m, 1.3, "Yer Sarsıntısı", Color("c8a070"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 7.0, Color("c8a070"), 0.6)
				knockback(m, 4.0)
				return true
		"hogger":
			for t in [0.66, 0.33]:
				var hk := "h%d" % roundi(t * 100.0)
				if hpf < t and not m.flags.has(hk):
					m.flags[hk] = true
					boss_say(m, "Hogger: Gnoll'lar! Taze et!")
					_boss_summon(m, "Gnoll Yardımcısı", "gnoll", 2, 220.0, 11.0, 4.2, 1.0, 3.0)
			if melee and _bready(m, "maul"):
				_bset(m, "maul", 6.0)
				boss_hit(m, 1.9, "Parçalama")
				return true
		"vancleef":
			if hpf < 0.5 and not m.flags.has("guards"):
				m.flags["guards"] = true
				boss_say(m, "VanCleef: Muhafızlar, saldırın!")
				_boss_summon(m, "Defias Muhafızı", "defias", 2, 260.0, 13.0, 4.2, 1.0, 3.0)
			if hpf < 0.25 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.25
				m.atk_int *= 0.8
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if melee and _bready(m, "stab"):
				_bset(m, "stab", 5.0)
				boss_hit(m, 1.7, "Kör Bıçak")
				return true
		"thokk":
			if hpf < 0.5 and not m.flags.has("ele"):
				m.flags["ele"] = true
				boss_say(m, "Thokk buzdan hizmetkârlarını çağırdı!")
				_boss_summon(m, "Buz Hizmetkârı", "frost", 3, 240.0, 12.0, 3.6, 0.8, 3.0)
			if hpf < 0.25 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.2
				boss_say(m, "Thokk'un buzları çatırdıyor!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if d <= 9.0 and _bready(m, "nova"):
				_bset(m, "nova", 11.0)
				boss_spell(m, 1.4, "Buz Dalgası", Color("8ad0ff"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 9.0, Color("8ad0ff"), 0.6)
				P["slow_t"] = 4.0
				return true
			if melee and _bready(m, "smash"):
				_bset(m, "smash", 6.0)
				boss_hit(m, 1.9, "Buzul Yumruğu")
				return true
			if d > m.rad + m.reach + 1.5 and d < 22.0 and _bready(m, "spike"):
				_bset(m, "spike", 7.0)
				boss_spell(m, 0.9, "Buz Mızrağı", Color("a8e0ff"))
				return true
		"vurgan":
			for t in [0.7, 0.4]:
				var key := "w%d" % roundi(t * 100.0)
				if hpf < t and not m.flags.has(key):
					m.flags[key] = true
					boss_say(m, "Vurgan: Muhafızlar, kazın şunları!")
					_boss_summon(m, "Kara Demir Muhafızı", "guard", 2, 300.0, 16.0, 3.8, 1.0, 3.5)
			if hpf < 0.3 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.15
				m.atk_int = 1.9
				boss_say(m, "Vurgan: Madeni başınıza yıkacağım!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if d <= 7.5 and _bready(m, "flame"):
				_bset(m, "flame", 9.0)
				boss_spell(m, 1.3, "Kor Dalgası", Color("ff7a2a"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 7.5, Color("ff7a2a"), 0.6)
				apply_dot(6.0, m.dmg * 0.12, "Yanık", Color("ff6a2a"))
				return true
			if melee and _bready(m, "cleave"):
				_bset(m, "cleave", 6.0)
				boss_hit(m, 1.8, "Kazma Darbesi")
				return true
			if d > 6.0 and d < 20.0 and _bready(m, "bolt"):
				_bset(m, "bolt", 5.0)
				boss_spell(m, 0.9, "Kızgın Cevher", Color("ff9a3a"))
				return true
		"golemagg":
			if hpf < 0.3 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.2
				boss_say(m, "Golemagg'ın çekirdeği kızıl parlıyor!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if hpf < 0.65 and not m.flags.has("pups"):
				m.flags["pups"] = true
				boss_say(m, "Golemagg'ın yanında çekirdek köpekleri belirdi!")
				_boss_summon(m, "Çekirdek Köpeği", "ember", 3, 380.0, 18.0, 4.0, 0.8, 3.5)
			if d <= 9.0 and _bready(m, "quake"):
				_bset(m, "quake", 10.0)
				boss_spell(m, 1.5, "Magma Dalgası", Color("ff7a2a"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 9.0, Color("ff7a2a"), 0.6)
				apply_dot(5.0, m.dmg * 0.1, "Yanık", Color("ff6a2a"))
				sfx.play("thunder", -4)
				return true
			if melee and _bready(m, "stomp"):
				_bset(m, "stomp", 6.0)
				boss_hit(m, 2.1, "Ateş Yumruğu")
				return true
			if d > m.rad + m.reach + 1.5 and d < 22.0 and _bready(m, "rocks"):
				_bset(m, "rocks", 7.0)
				boss_spell(m, 1.0, "Lav Fırlatma", Color("ff9a3a"))
				return true
		"geddon":
			if hpf < 0.5 and not m.flags.has("arma"):
				m.flags["arma"] = true
				boss_say(m, "Baron Geddon: Armagedon!")
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 14.0, Color("ff4a1a"), 0.8)
				if d <= 14.0:
					boss_spell(m, 2.6, "Armagedon", Color("ff4a1a"))
				sfx.play("shout")
				return true
			if hpf < 0.25 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.25
				m.spd *= 1.15
				boss_say(m, "Baron Geddon alev alev yanıyor!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
			if d <= 10.0 and _bready(m, "inferno"):
				_bset(m, "inferno", 12.0)
				boss_spell(m, 1.6, "Cehennem", Color("ff5a1a"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 10.0, Color("ff5a1a"), 0.7)
				return true
			if d <= 20.0 and _bready(m, "bomb"):
				_bset(m, "bomb", 14.0)
				apply_dot(8.0, m.dmg * 0.14, "Yaşayan Bomba", Color("ffb040"))
				return true
			if melee and _bready(m, "cleave"):
				_bset(m, "cleave", 6.0)
				boss_hit(m, 1.8, "Yanık Dokunuş")
				return true
			if d > 6.0 and d < 22.0 and _bready(m, "bolt"):
				_bset(m, "bolt", 5.0)
				boss_spell(m, 0.9, "Kor Oku", Color("ff9a3a"))
				return true
		"sulfuron":
			for t in [0.75, 0.45]:
				var key := "w%d" % roundi(t * 100.0)
				if hpf < t and not m.flags.has(key):
					m.flags[key] = true
					boss_say(m, "Sulfuron: Hizmetkârlar, bunları ezin!")
					_boss_summon(m, "Kül Hizmetkârı", "guard", 2, 420.0, 20.0, 3.8, 1.1, 3.5)
			if hpf < 0.3 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.15
				m.atk_int = 1.9
				boss_say(m, "Sulfuron: Çekicim sizi küle çevirecek!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if d <= 8.0 and _bready(m, "flame"):
				_bset(m, "flame", 10.0)
				boss_spell(m, 1.4, "Kül Dalgası", Color("ff7a2a"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 8.0, Color("ff7a2a"), 0.6)
				knockback(m, 5.0)
				return true
			if melee and _bready(m, "hammer"):
				_bset(m, "hammer", 6.0)
				boss_hit(m, 2.0, "Kül Çekici")
				return true
			if d > 6.0 and d < 20.0 and _bready(m, "bolt"):
				_bset(m, "bolt", 5.0)
				boss_spell(m, 1.0, "Kor Mızrağı", Color("ff9a3a"))
				return true
		"gruff":
			if hpf < 0.4 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.2
				boss_say(m, "Gruff Swiftbite çılgına döndü!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if hpf < 0.7 and not m.flags.has("pups"):
				m.flags["pups"] = true
				boss_say(m, "Gruff yavrularını çağırdı!")
				_boss_summon(m, "Yavru Timsah", "croc", 3, 160.0, 7.0, 4.4, 0.8, 3.0)
			if melee and _bready(m, "roll"):
				_bset(m, "roll", 9.0)
				boss_hit(m, 2.4, "Ölüm Kıvrımı")
				knockback(m, 5.0)
				return true
			if melee and _bready(m, "snap"):
				_bset(m, "snap", 5.0)
				boss_hit(m, 1.6, "Çene Kilidi")
				return true
			if d > m.rad + m.reach + 1.0 and d < 26.0 and _bready(m, "mud"):
				_bset(m, "mud", 6.0)
				boss_spell(m, 0.9, "Çamur Püskürtme", Color("6a5a30"))
				return true
		"arctikus":
			if hpf < 0.35 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.3
				m.spd *= 1.25
				boss_say(m, "Büyük Baba Arctikus öfkelendi!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if melee and _bready(m, "maul"):
				_bset(m, "maul", 7.0)
				boss_hit(m, 2.2, "Parçala!")
				return true
			if melee and _bready(m, "rend"):
				_bset(m, "rend", 15.0)
				apply_dot(8.0, m.dmg * 0.14, "Yırtma", Color("ff4a4a"))
				m.atk_t = maxf(m.atk_t, 1.0)
				return true
		"grik":
			if d <= 6.5 and _bready(m, "nova"):
				_bset(m, "nova", 9.0)
				boss_spell(m, 1.3, "Don Dalgası", Color("8ae0ff"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 6.0, Color("8ae0ff"), 0.6)
				P["slow_t"] = 4.0
				return true
			if d > 5.0 and d < 17.0 and _bready(m, "bolt"):
				_bset(m, "bolt", 5.0)
				boss_spell(m, 0.9, "Buz Oku", Color("b8f0ff"))
		"choksul":
			if hpf < 0.3 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.35
				m.atk_int = 1.8
				boss_say(m, "Chok'sul: EZİN!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
			if d <= 7.0 and _bready(m, "slam"):
				_bset(m, "slam", 9.0)
				boss_spell(m, 1.5, "Yer Yarığı", Color("d8b070"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 7.0, Color("d8b070"), 0.6)
				knockback(m, 7.0)
				sfx.play("thunder", -4)
				return true
		"hogger":
			if not m.flags.has("s0"):
				m.flags["s0"] = true
				boss_say(m, "Hogger gnoll çıraklarını çağırdı!")
				_boss_summon(m, "Gnoll Çırağı", "gnoll", 2, 100.0, 9.0, 4.0, 0.9, 3.0)
			if hpf < 0.5 and not m.flags.has("s1"):
				m.flags["s1"] = true
				boss_say(m, "Hogger: Yiiipe! Gelin, gelin!")
				_boss_summon(m, "Gnoll Çırağı", "gnoll", 2, 100.0, 9.0, 4.0, 0.9, 3.0)
			if hpf < 0.4 and not m.flags.has("eat"):
				m.flags["eat"] = true
				m.eat_t = 4.0
				boss_say(m, "Hogger yemek yiyor ve canını yeniliyor!")
				float_text(_bpos(m), "Yiyor...", Color("43d17f"), true)
				return true
			if melee and _bready(m, "cleave"):
				_bset(m, "cleave", 8.0)
				boss_hit(m, 1.7, "Pençe!")
				return true
		"vancleef":
			for t in [0.75, 0.5, 0.25]:
				var key := "w%d" % roundi(t * 100.0)
				if hpf < t and not m.flags.has(key):
					m.flags[key] = true
					boss_say(m, "VanCleef: Muhafızlar! Şunları öldürün!")
					_boss_summon(m, "Defias Haydudu", "defias", 2, 150.0, 11.0, 4.2, 1.0, 3.0)
			if hpf < 0.5 and not m.flags.has("thrash"):
				m.flags["thrash"] = true
				m.atk_int = 1.5
				boss_say(m, "VanCleef: Hiçbir şey beni durduramaz!")
				float_text(_bpos(m), "Çılgınlık!", Color("ff6a3a"), true)
			if melee and _bready(m, "stab"):
				_bset(m, "stab", 8.0)
				boss_hit(m, 2.0, "Sırttan Bıçak!")
				return true
			if melee and _bready(m, "poison"):
				_bset(m, "poison", 12.0)
				apply_dot(10.0, m.dmg * 0.1, "Ölümcül Zehir", Color("7be85a"))
		"ragnaros":
			if hpf < 0.5 and not m.flags.has("s1"):
				m.flags["s1"] = true
				boss_say(m, "Ragnaros: ALEV OĞULLARIM, ÖNÜNÜZE ÇIKIN!")
				_boss_summon(m, "Alev Oğlu", "ember", 4, 220.0, 22.0, 3.8, 1.0, 8.0)
			if hpf < 0.25 and not m.flags.has("s2"):
				m.flags["s2"] = true
				boss_say(m, "Ragnaros: ÇOK ERKEN GELDİNİZ!")
				_boss_summon(m, "Alev Oğlu", "ember", 4, 220.0, 22.0, 3.8, 1.0, 8.0)
			if _bready(m, "wrath"):
				_bset(m, "wrath", 22.0)
				boss_say(m, "Ragnaros: Ateşin gazabını tadın!")
				boss_spell(m, 1.8, "Ragnaros'un Gazabı", Color("ff7a30"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z) + 1.5, m.z), 14.0, Color("ff7a30"), 0.8)
				knockback(m, 12.0)
				sfx.play("thunder", -2)
				return true
			if melee and _bready(m, "lava"):
				_bset(m, "lava", 12.0)
				boss_hit(m, 2.2, "Lav Patlaması")
				return true
			if d > m.rad + m.reach + 1.5 and d < 34.0 and _bready(m, "magma"):
				_bset(m, "magma", 3.0)
				boss_spell(m, 1.0, "Magma Topu", Color("ff9a40"))
		"kezan":
			if hpf < 0.6 and not m.flags.has("call"):
				m.flags["call"] = true
				boss_say(m, "Kezan Kırgazık: Zindan muhafızları, bana yardım edin!")
				_boss_summon(m, "Kara Demir Zindan Muhafızı", "ironclad", 2, 240.0, 15.0, 3.4, 1.0, 4.0)
			if hpf < 0.3 and not m.flags.has("rage"):
				m.flags["rage"] = true
				m.dmg *= 1.35
				m.atk_int = 1.9
				boss_say(m, "Kezan Kırgazık: Kaçışınız yok!")
				float_text(_bpos(m), "Öfke!", Color("ff6a3a"), true)
				sfx.play("shout")
			if d > m.rad + m.reach + 1.0 and d < 16.0 and _bready(m, "charge"):
				_bset(m, "charge", 9.0)
				boss_say(m, "Kezan Kırgazık hücum ediyor!")
				boss_spell(m, 1.3, "Baltalı Hücum", Color("c83a3a"))
				knockback(m, 5.0)
				return true
			if melee and _bready(m, "cleave"):
				_bset(m, "cleave", 5.0)
				boss_hit(m, 1.8, "Zincirleme Vuruş")
				apply_dot(5.0, m.dmg * 0.1, "Kanama", Color("c82a2a"))
				return true
		"modrek":
			if hpf < 0.7 and not m.flags.has("p1"):
				m.flags["p1"] = true
				boss_say(m, "Lord Modrek: Zindanım sizi gömecek!")
				_boss_summon(m, "Kara Demir Zindan Muhafızı", "ironclad", 3, 260.0, 16.0, 3.4, 1.0, 5.0)
			if hpf < 0.4 and not m.flags.has("p2"):
				m.flags["p2"] = true
				m.dmg *= 1.25
				m.spd *= 1.1
				boss_say(m, "Lord Modrek: Tahtımı savunacağım!")
				float_text(_bpos(m), "İkinci Evre!", Color("ffcc33"), true)
				sfx.play("shout")
			if hpf < 0.18 and not m.flags.has("p3"):
				m.flags["p3"] = true
				m.dmg *= 1.2
				boss_say(m, "Lord Modrek: BU ZİNDAN BENİMLE BİRLİKTE ÇÖKECEK!")
				_boss_summon(m, "Kara Demir Zindan Muhafızı", "ironclad", 2, 260.0, 16.0, 3.4, 1.0, 5.0)
			if d <= 9.0 and _bready(m, "quake"):
				_bset(m, "quake", 11.0)
				boss_spell(m, 1.5, "Taht Sarsıntısı", Color("d8b070"))
				ring_fx(Vector3(m.x, height_at(m.x, m.z), m.z), 9.0, Color("d8b070"), 0.65)
				knockback(m, 6.5)
				sfx.play("thunder", -4)
				return true
			if melee and _bready(m, "smash"):
				_bset(m, "smash", 5.5)
				boss_hit(m, 2.1, "İmparator Yargısı")
				return true
			if d > m.rad + m.reach + 1.5 and d < 24.0 and _bready(m, "rocks"):
				_bset(m, "rocks", 7.5)
				boss_spell(m, 1.0, "Kara Demir Parçası", Color("8a8070"))
				return true
	return false

func _step_mob(m, dt: float) -> void:
	var node: Node3D = m.node
	if m.dead:
		var k: float = T - m.died_at
		var kf: float = T - m.fade_t if m.fade_t > 0.0 else k - 0.8
		var gy: float = height_at(m.x, m.z) + m.yoff
		if m.boss == "ragnaros":
			node.rotation.z = 0.0
			node.position.y = gy - minf(k, 2.5) * 1.2
			if kf >= 0.0:
				node.visible = false
		elif k < 0.8:
			node.rotation.z = lerpf(0.0, 1.5, k / 0.8)
			node.position.y = gy + 0.1
		elif kf < 0.0:
			node.rotation.z = 1.5
			node.position.y = gy + 0.1
		elif kf < 0.8:
			node.scale = Vector3.ONE * m.sc * maxf(0.001, 1.0 - kf / 0.8)
		else:
			node.visible = false
		if m.temp and kf >= 0.8 and not m.gc:
			m.gc = true
			node.queue_free()
			hud.plate_hide(m.id)
			if loot_mob == m:
				close_loot()
			return
		if m.sparkle != null:
			m.sparkle.position.y = height_at(m.x, m.z) + 0.8 + sin(T * 4.0) * 0.1
			if kf >= 0.0 or loot_mob == null and m.loot.is_empty():
				m.sparkle.queue_free()
				m.sparkle = null
		var pd := Vector2(m.hx - P["x"], m.hz - P["z"]).length()
		if SpawnDirector.can_respawn(k, SpawnDirector.respawn_delay(m.respawn, m.lvl, m.boss != "", m.temp), pd, 16.0, m.temp):
			m.dead = false
			m.hp = m.maxhp
			m.x = m.hx
			m.z = m.hz
			m.state = "idle"
			m.bleed_t = 0.0
			m.slow = 0.0
			m.loot = []
			m.loot_money = 0
			m.fade_t = 0.0
			if m.sparkle != null:
				m.sparkle.queue_free()
				m.sparkle = null
			if loot_mob == m:
				close_loot()
			node.visible = true
			node.rotation.z = 0.0
			node.scale = Vector3.ONE * m.sc
			node.position.y = height_at(m.x, m.z) + m.yoff
			_boss_reset(m)
		return
	var dx: float = P["x"] - m.x
	var dz: float = P["z"] - m.z
	var d := sqrt(dx * dx + dz * dz)
	var moving := false
	m.stun = maxf(0.0, m.stun - dt)
	m.slow = maxf(0.0, m.slow - dt)
	var msp: float = m.spd * (0.5 if m.slow > 0.0 else 1.0)
	if m.bleed_t > 0.0:
		m.bleed_t -= dt
		m.bleed_tick -= dt
		if m.bleed_tick <= 0.0:
			m.bleed_tick += 2.0
			var bd := maxi(1, roundi(m.bleed_v * (0.9 + randf() * 0.2)))
			m.hp -= bd
			float_text(Vector3(m.x, 1.9 * m.sc, m.z) + Vector3(0, m.node.position.y, 0), str(bd), Color("ff6a5a"), false)
			if m.hp <= 0.0:
				kill_mob(m)
				return
	if mode == "play" and not P["dead"] and m.state == "idle" and d < m.aggro:
		m.state = "chase"
	if m.boss != "":
		if m.state == "chase" and not m.engaged:
			_boss_engage(m)
		elif m.state != "chase" and m.engaged:
			_boss_reset(m)
		if m.state == "chase" and m.spd == 0.0 and d > 40.0:
			m.state = "return"
	if P["dead"] and m.state == "chase":
		m.state = "return"
	if m.stun > 0.0:
		pass
	elif m.state == "chase":
		var hd := Vector2(m.x - m.hx, m.z - m.hz).length()
		if hd > 38.0:
			m.state = "return"
		elif m.boss == "" and m.ranged > 0.0 and m.eat_t <= 0.0 and NavSteer.ranged_move_direction(Vector2(m.x, m.z), Vector2(P["x"], P["z"]), m.ranged) != Vector2.ZERO:
			# Menzilli düşmanlar çok yaklaşınca geri çekilir, uzaklaşınca tercih ettiği mesafeye döner.
			var kd := NavSteer.ranged_move_direction(Vector2(m.x, m.z), Vector2(P["x"], P["z"]), m.ranged)
			var kc := collide(m.x + kd.x * msp * 0.85 * dt, m.z + kd.y * msp * 0.85 * dt, m.rad * 0.6)
			m.x = kc.x
			m.z = kc.y
			moving = true
		elif d > (m.rad + 0.9 if m.ranged <= 0.0 else m.ranged - 2.0) and m.eat_t <= 0.0:
			var near: Array = []
			if m.boss == "":
				for o in mobs:
					if o != m and not o.dead and absf(o.x - m.x) < 2.4 and absf(o.z - m.z) < 2.4:
						near.append(Vector2(o.x, o.z))
			var aim := Vector2(dx, dz) / d
			if m.boss == "" and m.ranged <= 0.0 and d < 7.0:
				# Yakın dövüşçüler oyuncunun etrafında kendi payına düşen noktaya yürür, tek noktada yığılmaz.
				var spot := NavSteer.melee_approach_point(Vector2(P["x"], P["z"]), m.id, m.rad + 0.9) - Vector2(m.x, m.z)
				if spot.length() > 0.3:
					aim = spot.normalized()
			var dir := NavSteer.blend_direction(aim, NavSteer.separation_vector(Vector2(m.x, m.z), near, 2.2), 0.55)
			var c := collide(m.x + dir.x * msp * dt, m.z + dir.y * msp * dt, m.rad * 0.6)
			m.x = c.x
			m.z = c.y
			moving = true
		m.yaw = atan2(dx, dz)
		m.atk_t -= dt
		if m.boss == "" and not m.flags.has("enr") and m.hp < m.maxhp * 0.25:
			m.flags["enr"] = true
			m.dmg *= 1.25
			m.atk_int *= 0.8
			float_text(Vector3(m.x, 2.6 * m.sc + m.node.position.y, m.z), "Öfkelendi!", Color("ff5a3a"), false)
		var busy := false
		if m.boss != "":
			busy = _boss_ai(m, dt, d)
		if not busy and m.ranged > 0.0 and d <= m.ranged and m.atk_t <= 0.0:
			m.atk_t = 2.6
			var fd := maxi(1, roundi(m.dmg * 0.8 * (0.85 + randf() * 0.3)))
			player_hp_loss(fd)
			float_text(Vector3(m.x, 2.4 * m.sc + m.node.position.y, m.z), "Ateş Oku", Color("ff9a40"), false)
			ring_fx(Vector3(P["x"], P["y"], P["z"]), 1.4, Color("ff8030"), 0.4)
			sfx.play("whirl", -10)
			m.lunge = 0.2
		elif not busy and m.ranged <= 0.0 and d <= m.rad + m.reach and m.atk_t <= 0.0:
			m.atk_t = m.atk_int
			hurt_player(m.dmg * (0.85 + randf() * 0.3), m)
			m.lunge = 0.2
	elif m.state == "return":
		var rx: float = m.hx - m.x
		var rz: float = m.hz - m.z
		var rd := sqrt(rx * rx + rz * rz)
		if rd < 0.6:
			m.state = "idle"
		else:
			m.x += rx / rd * m.spd * 1.2 * dt
			m.z += rz / rd * m.spd * 1.2 * dt
			m.yaw = atan2(rx, rz)
			moving = true
		m.hp = minf(m.maxhp, m.hp + m.maxhp * 0.25 * dt)
	else:
		m.w_t -= dt
		if m.w_t <= 0.0:
			m.w_t = 2.0 + randf() * 4.0
			var a := randf() * TAU
			var r := randf() * 5.0
			m.wx = m.hx + cos(a) * r
			m.wz = m.hz + sin(a) * r
		var wx: float = m.wx - m.x
		var wz: float = m.wz - m.z
		var wd := sqrt(wx * wx + wz * wz)
		if wd > 0.5:
			m.x += wx / wd * 1.2 * dt
			m.z += wz / wd * 1.2 * dt
			m.yaw = atan2(wx, wz)
			moving = true
	if m.lunge > 0.0:
		m.lunge -= dt
	var y: float = height_at(m.x, m.z) + m.yoff
	node.position = Vector3(m.x, y, m.z)
	node.rotation = Vector3(0, m.yaw, 0)
	if m.lunge > 0.0:
		node.position += Vector3(sin(m.yaw), 0, cos(m.yaw)) * 0.25
	m.ph += dt * ((6.0 if m.state == "idle" else 12.0) if moving else 0.0)
	var s := sin(m.ph) * 0.7 if moving else 0.0
	if m.legs.size() >= 4:
		m.legs[0].rotation.x = s
		m.legs[3].rotation.x = s
		m.legs[1].rotation.x = -s
		m.legs[2].rotation.x = -s
	WowAssets.update_locomotion(node, moving, m.lunge > 0.0)

func _step_npcs(dt: float) -> void:
	for n in npcs:
		var node: Node3D = n["node"]
		var nr: Dictionary = node.get_meta("rig")
		var d := Vector2(n["x"] - P["x"], n["z"] - P["z"]).length()
		if d < 7.0:
			var ty := atan2(P["x"] - n["x"], P["z"] - n["z"])
			var df := fposmod(ty - node.rotation.y + PI, TAU) - PI
			node.rotation.y += df * minf(1.0, dt * 4.0)
		if n["role"] == "smith":
			nr["armR"].rotation.x = -0.9 + sin(T * 5.0) * 0.7
		else:
			nr["armR"].rotation.x = sin(T * 1.7 + n["x"]) * 0.04
		node.position.y = n["y"] + sin(T * 1.4 + n["z"]) * 0.015

func _animate_player(dt: float) -> void:
	var ph0 := walk_ph
	walk_ph += P["spd"] * dt * 9.0
	if P["spd"] > 0.2 and P["jy"] <= 0.05 and floorf(walk_ph / PI) != floorf(ph0 / PI):
		sfx.play("step", -16)
	var sw: float = sin(walk_ph) * 0.75 * P["spd"]
	var air: bool = P["jy"] > 0.05
	rig["legL"].rotation.x = -0.7 if air else sw
	rig["legR"].rotation.x = 0.3 if air else -sw
	rig["armL"].rotation.x = -2.2 if air else (-0.3 - sw * 0.35)
	var bob: float = absf(sin(walk_ph)) * 0.07 * P["spd"]
	if swing_t > 0.0:
		swing_t += dt
		var prof: Dictionary = Items.SWING_STYLES.get(swing_style, Items.SWING_STYLES["axe"])
		var u: float = swing_t / float(prof["dur"])
		if u >= 1.0:
			swing_t = 0.0
			rig["armR"].rotation.x = sw * 0.35
			rig["armR"].rotation.z = 0.0
		else:
			rig["armR"].rotation.x = lerpf(float(prof["from"]), float(prof["to"]), u * u)
			rig["armR"].rotation.z = lerpf(float(prof["side"]), 0.0, u)
	else:
		rig["armR"].rotation.x = sw * 0.35 - 0.2 + sin(T * 2.0) * 0.03
	player.position = Vector3(P["x"], P["y"] + bob, P["z"])
	player.rotation.y = P["yaw"] + ((1.0 - P["spin"] / 0.6) * TAU if P["spin"] > 0.0 else 0.0)
	if P["dead"]:
		player.rotation.x = lerpf(player.rotation.x, -1.4, minf(1.0, dt * 6.0))
		player.position.y = P["y"] + 0.3
	else:
		player.rotation.x = lerpf(player.rotation.x, 0.0, minf(1.0, dt * 10.0))

func _update_camera(dt: float) -> void:
	cam_dist = lerpf(cam_dist, cam_dist_t, minf(1.0, dt * 10.0))
	var cp := cos(cam_pitch)
	var tgt := Vector3(P["x"], P["y"] + 1.6, P["z"])
	var pos := Vector3(P["x"] + sin(cam_yaw) * cp * cam_dist, P["y"] + 1.9 + sin(cam_pitch) * cam_dist, P["z"] + cos(cam_yaw) * cp * cam_dist)
	if map == "mine":
		var best := 0.0
		for k in range(1, 11):
			var t := float(k) / 10.0
			var q := tgt.lerp(pos, t)
			if _mine_sd(q.x, q.z) > -0.9 or q.y > 8.5:
				break
			best = t
		pos = tgt.lerp(pos, maxf(best, 0.12))
	var gh := height_at(pos.x, pos.z) + 1.0
	if pos.y < gh:
		pos.y = gh
	cam.position = pos
	cam.look_at(tgt, Vector3.UP)
	if swamp_fx:
		swamp_fx.position = Vector3(P["x"], P["y"] + (1.5 if map == "ash" else 1.0), P["z"])
	if snow_node:
		snow_node.position = Vector3(P["x"], P["y"] + 16.0, P["z"])

func _step_effects(_dt: float) -> void:
	if worldmap and worldmap.visible:
		_refresh_worldmap()
	for n in npcs:
		if n.has("mark3d"):
			var mk := npc_mark(n)
			var lb: Label3D = n["mark3d"]
			lb.visible = mk != ""
			lb.text = mk
			lb.position.y = 3.1 + sin(T * 3.0) * 0.12
	_step_daynight(_dt)
	if rain_node:
		rain_node.position = Vector3(P["x"], P["y"] + 16.0, P["z"])
	for n in res_nodes:
		if not n["on"] and T >= n["t"]:
			n["on"] = true
			n["node"].visible = true
	if mine_lantern:
		mine_lantern.position = Vector3(P["x"], P["y"] + 2.4, P["z"])
		mine_lantern.light_energy = 1.7 + sin(T * 13.0) * 0.08
	if swamp_fx:
		swamp_fx.position = Vector3(P["x"], P["y"] + 3.0, P["z"])
	for f in flame_nodes:
		f.scale = Vector3(1.0 + sin(T * 14.0) * 0.12, 1.0 + sin(T * 11.0 + 1.0) * 0.2, 1.0 + sin(T * 13.0) * 0.12)
	if fire_light:
		fire_light.light_energy = 2.3 + sin(T * 17.0) * 0.4 + sin(T * 9.0) * 0.25
	if forge_light:
		forge_light.light_energy = 3.0 + sin(T * 9.0) * 0.5
	if gate_light:
		gate_light.light_energy = 2.0 + sin(T * 11.0) * 0.4
	if lava_mat:
		lava_mat.emission_energy_multiplier = (0.8 if map == "ash" else 3.5) + sin(T * 3.0) * 0.2

func _lvl_color(l: int) -> Color:
	var d: int = l - P["lvl"]
	if d >= 4:
		return Color("ff4a4a")
	if d >= 2:
		return Color("ff9a3a")
	if d >= -1:
		return Color("ffe45c")
	if d >= -3:
		return Color("7fe08a")
	return Color("a8a8a8")

func _mob_kind(m) -> String:
	if m.kind in ["skull", "dwarf", "bear"] and m.boss != "":
		return m.kind
	if m.temp:
		return "skull"
	if m.kind in ["trogg", "gnoll", "murloc", "shaman", "croc", "bog", "frost", "skeleton"]:
		return "skull"
	if m.kind in ["defias", "darkiron"]:
		return "dwarf"
	if m.nm == "Kurt":
		return "wolf"
	if m.nm == "Yaban Domuzu":
		return "boar"
	return "bear"

func _update_hud() -> void:
	if hud == null:
		return
	var buffs: Array = []
	if P["bs_t"] > 0.0:
		buffs.append({"kind": "shout", "t": P["bs_t"]})
	if P["sb_t"] > 0.0:
		buffs.append({"kind": "shield", "t": P["sb_t"]})
	if P["rk_t"] > 0.0:
		buffs.append({"kind": "reck", "t": P["rk_t"]})
	if P["bst_t"] > 0.0:
		buffs.append({"kind": "bstorm", "t": P["bst_t"]})
	var t0 = P["target"]
	var exec_ok: bool = t0 != null and not t0.dead and t0.hp <= t0.maxhp * 0.2 and P["lvl"] >= 4
	hud.update_player({"lvl": P["lvl"], "hp": P["hp"], "maxhp": max_hp(), "rage": P["rage"], "xp": P["xp"], "xpneed": xp_need(P["lvl"]),
		"cd": P["cd"], "gcd": P["gcd"], "pot": potion_count(), "potcd": P["pot_cd"], "exec_ok": exec_ok, "buffs": buffs})
	if t0 != null and not t0.dead and t0.boss != "":
		hud.update_boss({"name": t0.nm, "hp": t0.hp, "maxhp": t0.maxhp, "enr": t0.flags.has("enr") or (t0.hp < t0.maxhp * 0.25)})
	else:
		hud.update_boss({})
	var t = P["target"]
	if t != null and not t.dead:
		hud.update_target({"name": t.nm, "lvl": t.lvl, "hp": t.hp, "maxhp": t.maxhp, "color": _lvl_color(t.lvl), "kind": _mob_kind(t),
			"hint": "Kanıyor" if t.bleed_t > 0.0 else ("Yavaş" if t.slow > 0.0 else ""),
			"tot": "Sen", "tot_hp": P["hp"] / max_hp() * 100.0} if t.state == "chase" else {"name": t.nm, "lvl": t.lvl, "hp": t.hp, "maxhp": t.maxhp, "color": _lvl_color(t.lvl), "kind": _mob_kind(t),
			"hint": "Kanıyor" if t.bleed_t > 0.0 else ("Yavaş" if t.slow > 0.0 else "")})
	else:
		hud.update_target({})
	var mp: Array = []
	for m in mobs:
		if not m.dead:
			mp.append(Vector2(m.x, m.z))
	var np: Array = []
	for n in npcs:
		np.append({"p": Vector2(n["x"], n["z"]), "mark": npc_mark(n)})
	var qwp: Array = _quest_waypoints() if mode == "play" else []
	var qmini: Array = []
	for w in qwp:
		qmini.append({"p": w["p"], "kind": w["kind"]})
	hud.update_minimap({"px": P["x"], "pz": P["z"], "cam_yaw": cam_yaw, "pyaw": P["yaw"], "mobs": mp, "npcs": np, "swamp": map == "swamp", "mine": map == "mine", "ash": map == "ash", "qt": qmini})
	hud.set_shout(shout_status() if mode == "play" and not P["dead"] else "")
	hud.set_waypoints(_waypoint_screen(qwp) if mode == "play" and not P["dead"] else [])
	# isim levhaları
	for m in mobs:
		var show: bool = mode == "play" and not m.dead and Vector2(m.x - P["x"], m.z - P["z"]).length() < (40.0 if m.boss != "" else 22.0)
		var wp := Vector3(m.x, m.node.position.y + (1.7 * m.sc + 0.3 if m.boss != "ragnaros" else 8.8), m.z)
		if show and not cam.is_position_behind(wp):
			hud.plate(m.id, cam.unproject_position(wp), "%s %d" % [m.nm, m.lvl], _lvl_color(m.lvl), m.hp / m.maxhp, ("<" + m.title + ">") if m.title != "" else "", "", P["target"] == m)
		else:
			hud.plate_hide(m.id)
	for n in npcs:
		var wp2 := Vector3(n["x"], n["y"] + 2.4, n["z"])
		var d := Vector2(n["x"] - P["x"], n["z"] - P["z"]).length()
		if mode == "play" and d < 26.0 and not cam.is_position_behind(wp2):
			hud.plate("npc_" + n["id"], cam.unproject_position(wp2), n["name"], Color("7fe08a"), -1.0, "<" + n["title"] + ">", npc_mark(n), false)
		else:
			hud.plate_hide("npc_" + n["id"])
	var nn = near_npc()
	var ptxt := ""
	if nn != null and not dlg_open and mode == "play" and not P["dead"]:
		ptxt = "G — Konuş: " + nn["name"]
	elif mode == "play" and not P["dead"] and (near_room_exit() or near_house_door() >= 0):
		ptxt = "G — Dışarı çık" if near_room_exit() else "G — İçeri gir: " + String(house_doors[near_house_door()]["name"])
	elif mode == "play" and not P["dead"] and not near_wall().is_empty():
		var nw := near_wall()
		ptxt = "G — Kelime duvarını oku" if not P["walls"].has(nw["id"]) else "Kelime duvarı (okundu): " + Shouts.word_text(nw)
	elif mode == "play" and not P["dead"] and not near_node().is_empty():
		var nd: Dictionary = Prog.NODES[near_node()["kind"]]
		ptxt = ("G — Topla: " + nd["name"]) if P["prof"].has("mine") else (nd["name"] + " (Madencilik gerekli)")
	elif mode == "play" and not P["dead"]:
		for pt in portals:
			if Vector2(pt["x"] - P["x"], pt["z"] - P["z"]).length() < 9.0:
				ptxt = "Portalın içinden geç: " + pt["label"]
	hud.set_prompt(ptxt)
	# bölge
	var dc := Vector2(P["x"] - CITY.x, P["z"] - CITY.z).length()
	var dv := Vector2(P["x"], P["z"]).length()
	var z := "c" if dc < 27.0 else ("v" if dv < 16.0 else "w")
	if mode == "play" and not P["dead"]:
		_check_discoveries()
	if _room_idx() >= 0:
		z = "v"
	elif map == "swamp":
		z = "sv" if dv < 16.0 else "sw"
	elif map == "mine":
		z = "zd" if P["z"] < -90.0 else "mn"
	elif map == "ash":
		z = "ak" if dv < 16.0 else "ad"
	if z != zone_now:
		zone_now = z
		if mode == "play":
			if z == "mn":
				hud.banner("KARA DEMİR MADENİ", "Demirkazan'ın altı")
			elif z == "zd":
				hud.banner("KARA DEMİR ZİNDANI", "Buradan canlı dönen az")
			elif z == "ak":
				hud.banner("KÜL NÖBETÇİLERİ KAMPI", "Güvenli sığınak")
			elif z == "ad":
				hud.banner("KÜL DİYARI", "Gökten kül yağıyor")
			elif z == "sv":
				hud.banner("BATAKLIK KARAKOLU", "Güvenli sığınak")
			elif z == "sw":
				hud.banner("SİSLİ BATAKLIK", "Karanlık göller")
			elif z == "c":
				hud.banner("DEMİRKAZAN", "Cüce başkenti")
			elif z == "v":
				hud.banner("KAR DAĞI KÖYÜ", "Kamp ateşi")
			else:
				hud.banner("KAR DAĞI VADİSİ", "Cüce toprakları")
		hud.set_zone({"c": "Demirkazan", "v": "Kar Dağı Köyü", "w": "Kar Dağı Vadisi", "sv": "Bataklık Karakolu", "sw": "Sisli Bataklık", "mn": "Kara Demir Madeni", "zd": "Kara Demir Zindanı", "ak": "Kül Nöbetçileri Kampı", "ad": "Kül Diyarı"}[z])

# ---------- kendi kendine test ----------
