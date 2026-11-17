extends RefCounted
## Günlük: keşfedilen bilgiler (diyaloglardan açılır) ve görev veren NPC'lerin yerleri.

const LORE := {
	"l_wolves": {"title": "Kurt Sürüleri", "text": "Kar Dağı kurtları kışın aç kalınca köy sınırına iner. Ragna, sürüyü yönetenlerin yaşlı dişi kurtlar olduğunu söylüyor."},
	"l_trogg": {"title": "Trogg Kalesi", "text": "Troggalar buzdan kaleler yapmayı eski ogrelerden öğrenmiş. Grik'nir'in kalesi doğu geçidinde, rüzgârın en sert estiği yerde."},
	"l_gate": {"title": "Kapı Muhafızlarının Yemini", "text": "Demirkazan kapısını tutan muhafızlar, kapı düşerse kendilerinin de düşeceğine yemin eder. Dorn bu yemini yirmi yıldır tutuyor."},
	"l_bank": {"title": "Demirkazan'ın Hazinesi", "text": "Bankanın en alt katında kralın ilk madeninden çıkan külçeler saklanır. Gundri'ye göre kimse o kapıyı yüz yıldır açmamış."},
	"l_inn": {"title": "Han Türküsü", "text": "Kelda'nın hanında söylenen eski türkü, Demirkazan'ı ilk kuran yedi cücenin kar fırtınasında ateşi nasıl yaktığını anlatır."},
	"l_forge": {"title": "Dövme Sırrı", "text": "Borga, Kara Demir'in ancak kor halindeyken üç kez katlanırsa kırılmadığını söylüyor. Bu hüner babasından kalmış."},
	"l_potion": {"title": "Hilda'nın Karışımı", "text": "Hilda'nın iksirlerindeki kırmızı yosun bataklıktan gelir. Tüccar Fenn'le yıllardır karşılıklı mal takası yaparlar."},
	"l_mine": {"title": "Kara Demir Madeni'nin Tarihi", "text": "Madenin üst galerileri bin yıl önce açıldı. Durin'e göre en derindeki Vurgan'ın odası, madencilerin kendi kazdığı değil, orada hep varmış."},
	"l_ragnaros": {"title": "Ateş Efendisi", "text": "Thrum, dağın kalbindeki Ragnaros'un uyanışını Kara Demir büyücülerinin ayinlerine bağlıyor. Ateşi söndürmek için en yüksek odaya çıkmak gerek."},
	"l_defias": {"title": "Defias Kardeşliği", "text": "Defias, bir zamanlar kralın taş ustalarıydı. Ücretleri ödenmeyince haydut oldular; reisleri VanCleef hâlâ haklı olduğuna inanıyor."},
	"l_marsh": {"title": "Sisli Bataklık", "text": "Muck'a göre sis, Murloc şamanlarının ayinleriyle her gece kalınlaşıyor. Karakol sisin içinde yolunu bayraklarla işaretliyor."},
	"l_gruff": {"title": "Gruff Swiftbite", "text": "Brenna, devasa timsahın bir zamanlar karakolun sevgili avı olduğunu, sonra göldeki karanlık bir şeyin onu azdırdığını söylüyor."},
	"l_caravan": {"title": "Kervan Yolu", "text": "Fenn'in kervanları bataklıktan güneye, kül yağan diyarlara uzanan eski bir yolu kullanıyordu. Yol şimdi kapalı; kimse neden olduğunu bilmiyor."},
	"l_ashland": {"title": "Kül Diyarı", "text": "Ragnaros uyanınca gökten kül yağmaya başladı. Torga'ya göre yer çatlamış, lav havuzları yürünmez hâle gelmiş; Kül Nöbetçileri son sığınağı tutuyor."},
	"l_golemagg": {"title": "Golemagg", "text": "Zeyra'ya göre Golemagg batıdaki kor ocağının bekçisi. Canı azalınca çekirdek köpeklerini çağırıyor; Magma Dalgası yakınındakileri yakıyor."},
	"l_geddon": {"title": "Baron Geddon", "text": "Geddon etrafına cehennem halkası yayıyor ve Yaşayan Bomba ile hedefini yakıyor. Canı yarıya inince Armagedon ile herkesi sarsıyor."},
	"l_sulfuron": {"title": "Kül Lordu Sulfuron", "text": "Sulfuron güneybatıda çekiciyle oturuyor. Hizmetkârlarını çağırıyor; canı azaldıkça öfkeleniyor."},
	"l_ash": {"title": "Kül Diyarı Söylentisi", "text": "Güneyde, bataklığın ötesinde gökten kül yağan bir diyar olduğu söyleniyor. Ragnaros'un uyanışından sonra orası yaşanmaz olmuş."},
}

## Görev -> görev vereni
const GIVERS := {
	"q_wolf": "Avcı Başı Ragna, Demirkazan", "q_trogg": "Avcı Başı Ragna, Demirkazan", "q_grik": "Avcı Başı Ragna, Demirkazan", "q_arc": "Avcı Başı Ragna, Demirkazan",
	"q_boar": "Muhafız Dorn, Demirkazan", "q_gnoll": "Muhafız Dorn, Demirkazan", "q_chok": "Muhafız Dorn, Demirkazan", "q_hogger": "Muhafız Dorn, Demirkazan",
	"q_mine1": "Madenci Başı Durin, Demirkazan", "q_mine2": "Madenci Başı Durin, Demirkazan", "q_mine3": "Madenci Başı Durin, Demirkazan",
	"q_bear": "Komutan Thrum, Demirkazan", "q_defias": "Komutan Thrum, Demirkazan", "q_dark": "Komutan Thrum, Demirkazan", "q_vc": "Komutan Thrum, Demirkazan", "q_rag": "Komutan Thrum, Demirkazan",
	"q_murloc": "Bekçi Muck, Bataklık Karakolu", "q_shaman": "Bekçi Muck, Bataklık Karakolu", "q_croc": "Bekçi Muck, Bataklık Karakolu",
	"q_bog": "Kaşif Brenna, Bataklık Karakolu",
	"q_ash1": "Nöbetçi Torga, Kül Nöbetçileri Kampı", "q_ash2": "Nöbetçi Torga, Kül Nöbetçileri Kampı", "q_ash3": "Nöbetçi Torga, Kül Nöbetçileri Kampı", "q_ash4": "Nöbetçi Torga, Kül Nöbetçileri Kampı",
	"q_ash5": "Kor Avcısı Zeyra, Kül Nöbetçileri Kampı", "q_ash6": "Kor Avcısı Zeyra, Kül Nöbetçileri Kampı", "q_ash7": "Kor Avcısı Zeyra, Kül Nöbetçileri Kampı", "q_gruff": "Kaşif Brenna, Bataklık Karakolu",
}

static func unlock(lore: Dictionary, id: String) -> bool:
	if not LORE.has(id) or lore.has(id):
		return false
	lore[id] = true
	return true

static func giver(qid: String) -> String:
	return str(GIVERS.get(qid, "Bilinmiyor"))
