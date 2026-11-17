extends RefCounted
## Dallanan sohbetler. Düğüm: text, opts, isteğe bağlı etkiler (lore, rep, money, xp, speech_xp, once).
## Seçenek: label, next ("" = sohbetten çık), need {speech, lvl, q}, check {dc, ok, fail} (Hitabet ikna denemesi).

const TREES := {
	"ragna": {
		"start": {"text": "Kurtlar ve troggalar derdim. Sen ne soracaksın, savaşçı?", "opts": [
			{"label": "Kurtlar neden köye iniyor?", "next": "wolves"},
			{"label": "Troggaların kalesi nerede?", "next": "trogg"},
			{"label": "Avcıların sırrını öğretir misin? (İkna)", "next": "", "check": {"dc": 14, "ok": "ok", "fail": "fail"}, "need": {"speech": 5}},
			{"label": "Sağ ol, gidiyorum.", "next": ""}]},
		"wolves": {"text": "Kışın aç kalıyorlar. Sürüyü yaşlı dişi kurtlar yönetir; onları yenersen gençler dağılır.", "lore": "l_wolves", "opts": [{"label": "Anladım.", "next": "start"}]},
		"trogg": {"text": "Doğu geçidinde, rüzgârın en sert estiği yerde. Buzdan bir kale kurmuşlar; ogrelerden öğrenmişler.", "lore": "l_trogg", "opts": [{"label": "Anladım.", "next": "start"}]},
		"ok": {"text": "Hm, dilin işe yarıyor. Al şunu, atalarımın izleme püf noktasını da öğretirim.", "rep": ["dem", 150], "money": 400, "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Güzel konuşuyorsun ama bende iş yaramaz. Önce kendini kanıtla.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
	"gundri": {
		"start": {"text": "Eşyaların burada güvende. Başka ne lazım?", "opts": [
			{"label": "Bankanın en altında ne var?", "next": "vault"},
			{"label": "Bana indirim yapar mısın? (İkna)", "next": "", "check": {"dc": 15, "ok": "ok", "fail": "fail"}, "need": {"speech": 8}},
			{"label": "Hoşça kal.", "next": ""}]},
		"vault": {"text": "Kralın ilk madeninden çıkan külçeler. Kapı yüz yıldır açılmadı; anahtarı kimse bilmiyor.", "lore": "l_bank", "opts": [{"label": "Anladım.", "next": "start"}]},
		"ok": {"text": "İyi pazarlık yaptın. Sana küçük bir ikram bırakıyorum.", "money": 600, "rep": ["dem", 100], "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Bankada pazarlık olmaz, dostum.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
	"kelda": {
		"start": {"text": "Sıcak çorba, yumuşak yatak, iyi bir türkü. Hangisi?", "opts": [
			{"label": "Türküyü söyler misin?", "next": "song"},
			{"label": "Hanın tarihi nedir?", "next": "history"},
			{"label": "Hoşça kal.", "next": ""}]},
		"song": {"text": "'Yedi cüce, kar fırtınası, bir kıvılcım...' Kuran yedi cücenin ateşi nasıl yaktığını anlatır. Dinlemek canını yeniler.", "lore": "l_inn", "xp": 80, "once": true, "opts": [{"label": "Çok güzeldi.", "next": "start"}]},
		"history": {"text": "Bu han, kapı muhafızlarının ilk nöbet yeriydi. Duvarlardaki izler savaşlardan kalma.", "opts": [{"label": "Anladım.", "next": "start"}]},
	},
	"dorn": {
		"start": {"text": "Kapıda nöbetteyim. Bir sorun mu var?", "opts": [
			{"label": "Kapı muhafızlığı nasıl bir şey?", "next": "oath"},
			{"label": "Sana yardım edebilirim. (İkna)", "next": "", "check": {"dc": 13, "ok": "ok", "fail": "fail"}, "need": {"speech": 3}},
			{"label": "Hoşça kal.", "next": ""}]},
		"oath": {"text": "Kapı düşerse biz de düşeriz. Yirmi yıldır bu yemini tutuyorum.", "lore": "l_gate", "opts": [{"label": "Saygı duyuyorum.", "next": "start"}]},
		"ok": {"text": "Cesaretini seviyorum. Nöbet defterime adını yazdım; muhafızlar seni tanıyacak.", "rep": ["dem", 150], "xp": 120, "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Güzel sözler, ama kapıda sözle iş görülmez.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
	"hilda": {
		"start": {"text": "İksirlerim en iyisi. Karışımın sırrını soracak mısın?", "opts": [
			{"label": "Kırmızı yosun nereden geliyor?", "next": "moss"},
			{"label": "Karışımı öğretir misin? (İkna)", "next": "", "check": {"dc": 16, "ok": "ok", "fail": "fail"}, "need": {"speech": 10}},
			{"label": "Hoşça kal.", "next": ""}]},
		"moss": {"text": "Bataklıktan. Tüccar Fenn'le yıllardır mal takası yaparız.", "lore": "l_potion", "opts": [{"label": "Anladım.", "next": "start"}]},
		"ok": {"text": "İyi, seni sevdim. Şu küçük keseyi al, kendi yolunda işine yarar.", "money": 800, "rep": ["dem", 100], "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Karışım sırrı kolay verilmez.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
	"borga": {
		"start": {"text": "Demirde hile olmaz. Ne konuşacağız?", "opts": [
			{"label": "Kara Demir'i nasıl işlersin?", "next": "forge"},
			{"label": "Baltamı bedavaya bilersin, di mi? (İkna)", "next": "", "check": {"dc": 17, "ok": "ok", "fail": "fail"}, "need": {"speech": 12}},
			{"label": "Hoşça kal.", "next": ""}]},
		"forge": {"text": "Kor halindeyken üç kez katlarsın, kırılmaz. Babamdan kaldı; bunu bilen çok az kişi var.", "lore": "l_forge", "opts": [{"label": "Anladım.", "next": "start"}]},
		"ok": {"text": "Ah, madem öyle... Bu seferlik aldığım paranın yarısını bırakıyorum.", "money": 1000, "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Demirci parasız iş yapmaz.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
	"durin": {
		"start": {"text": "Madenin kapısı her zaman açık. Derinlere inmeye mi hazırsın?", "opts": [
			{"label": "Madenin tarihi nedir?", "next": "history"},
			{"label": "En derindeki oda neden kapalı?", "next": "deep", "need": {"lvl": 12}},
			{"label": "Hoşça kal.", "next": ""}]},
		"history": {"text": "Üst galeriler bin yıl önce açıldı. Ama en alttaki oda... orayı biz kazmadık, hep oradaydı.", "lore": "l_mine", "opts": [{"label": "Anladım.", "next": "start"}]},
		"deep": {"text": "Vurgan'ın odası. İçeri girenlerden geri dönen az. Yine de güçlü görünüyorsun.", "xp": 150, "once": true, "opts": [{"label": "Hazırım.", "next": "start"}]},
	},
	"thrum": {
		"start": {"text": "Dağ komutanı olarak konuşuyorum. Dinliyorum.", "opts": [
			{"label": "Ateş Efendisi hakkında ne biliyorsun?", "next": "rag"},
			{"label": "Defias kimlerdir?", "next": "defias"},
			{"label": "Güneyde ne var?", "next": "south", "need": {"q": "q_rag"}},
			{"label": "Hoşça kal.", "next": ""}]},
		"rag": {"text": "Ragnaros'un uyanışını Kara Demir büyücülerinin ayinlerine bağlıyorum. Onu yenmek için en yüksek odaya çıkmalısın.", "lore": "l_ragnaros", "opts": [{"label": "Anladım.", "next": "start"}]},
		"defias": {"text": "Eski taş ustaları. Ücret alamayınca haydut oldular. VanCleef hâlâ haklı olduğuna inanıyor.", "lore": "l_defias", "opts": [{"label": "Anladım.", "next": "start"}]},
		"south": {"text": "Bataklığın ötesinde, kül yağan bir diyar var derler. Ateşin uyanışından sonra orası yaşanmaz olmuş.", "lore": "l_ash", "opts": [{"label": "Anladım.", "next": "start"}]},
	},
	"muck": {
		"start": {"text": "Sis her gün biraz daha kalınlaşıyor. Ne istiyorsun?", "opts": [
			{"label": "Sis neden bu kadar yoğun?", "next": "fog"},
			{"label": "Karakola yardım edebilirim. (İkna)", "next": "", "check": {"dc": 12, "ok": "ok", "fail": "fail"}, "need": {"speech": 2}},
			{"label": "Hoşça kal.", "next": ""}]},
		"fog": {"text": "Murloc şamanları her gece ayin yapıyor; sis o yüzden kalınlaşıyor.", "lore": "l_marsh", "opts": [{"label": "Anladım.", "next": "start"}]},
		"ok": {"text": "Güveniyorum sana. Karakolun mühürünü al; bataklıkta herkes tanıyacak.", "rep": ["kar", 200], "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Bataklıkta kelimeler yetmez.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
	"brenna": {
		"start": {"text": "Bataklığı benden iyi bilen yoktur. Sor bakalım.", "opts": [
			{"label": "Gruff Swiftbite kim?", "next": "gruff"},
			{"label": "Gölün dibinde ne var?", "next": "lake", "need": {"lvl": 11}},
			{"label": "Hoşça kal.", "next": ""}]},
		"gruff": {"text": "Karakolun eski sevgili avı. Sonra göldeki karanlık bir şey onu azdırdı.", "lore": "l_gruff", "opts": [{"label": "Anladım.", "next": "start"}]},
		"lake": {"text": "Bilmiyorum. Ama dibinden yükselen sis, kuzeyden gelen ateşle aynı kokuyor.", "xp": 140, "once": true, "opts": [{"label": "Anladım.", "next": "start"}]},
	},
	"fenn": {
		"start": {"text": "Mal alırım, mal satarım. Ya da hikâye anlatırım.", "opts": [
			{"label": "Kervan yolu nerede?", "next": "road"},
			{"label": "Bana özel fiyat yapar mısın? (İkna)", "next": "", "check": {"dc": 15, "ok": "ok", "fail": "fail"}, "need": {"speech": 9}},
			{"label": "Hoşça kal.", "next": ""}]},
		"road": {"text": "Güneye, kül yağan diyarlara uzanan eski bir yoldu. Şimdi kapalı; kimse nedenini bilmiyor.", "lore": "l_caravan", "opts": [{"label": "Anladım.", "next": "start"}]},
		"ok": {"text": "Tamam tamam, şu kese senin. Ama kimseye söyleme!", "money": 900, "rep": ["kar", 100], "once": true, "opts": [{"label": "Teşekkürler.", "next": "start"}]},
		"fail": {"text": "Bu fiyat zaten kâr bırakmıyor.", "opts": [{"label": "Peki.", "next": "start"}]},
	},
}

static func node(npc_id: String, node_id: String) -> Dictionary:
	var t: Dictionary = TREES.get(npc_id, {})
	return t.get(node_id, {})

static func has_tree(npc_id: String) -> bool:
	return TREES.has(npc_id)
