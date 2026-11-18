# Cüce Savaşçı (3D, Godot 4)

Karlı vadide kurt, domuz ve ayı avla; Demirkazan cüce şehrinde görev al, demirciden silah, tüccardan iksir al.

## İndir ve oyna
`wow` dalının güncel Windows test sürümünü GitHub deposunda **Actions → WoW Windows build → Artifacts → CuceSavasci-Windows** bölümünden indir. ZIP'i açıp `CuceSavasci.exe` dosyasını çalıştır. ("Windows bilgisayarını korudu" çıkarsa: *Ek bilgi → Yine de çalıştır*.) Dosya imzasızdır; Windows uyarı verebilir.

## Kontroller
| Tuş | İşlev |
|---|---|
| W A S D | Yürü |
| Boşluk | Zıpla |
| Sağ tık basılı tut | Kamerayı çevir |
| Sol tık | Hedef seç |
| Tekerlek / Q E | Yakınlaştır / kamerayı döndür |
| R | Otomatik saldırı |
| 1 - 9 | Yetenekler |
| 0 veya F | Can iksiri |
| Tab | En yakın hedef |
| Esc | Hedefi bırak, tekrar basınca oyun menüsü (ses, tam ekran, kaydet ve çık) |
| G | NPC ile konuş, yakındaki cesetten ganimet al |
| B / C | Çanta / Karakter penceresi |
| Sol tık (ceset) | Ganimet penceresini aç |
| Sağ tık (eşya) | Giy, iksiri iç, satıcıdayken sat |
| H | Yardım penceresi |
| F11 | Tam ekran |

## Yetenekler (savaşçı, Öfke ile çalışır)
| Tuş | Yetenek | Seviye | Ne yapar |
|---|---|---|---|
| 1 | Kahramanlık Darbesi | 1 | Güçlü vuruş |
| 2 | Hamle | 1 | Hedefe atılır, sersemletir, öfke verir |
| 3 | Yaralama | 2 | Kanatır (zamanla hasar) |
| 4 | Savaş Narası | 2 | Saldırıyı %25 artırır |
| 5 | Gök Gürültüsü | 3 | Yakındakilere vurur ve yavaşlatır |
| 6 | Kalkan Bloğu | 3 | 5 sn gelen hasarı %70 azaltır |
| 7 | İnfaz | 4 | Canı %20 altındaki hedefe dev hasar |
| 8 | Ölümcül Darbe | 5 | Devasa vuruş |
| 9 | Kasırga | 6 | Çevredeki herkese vurur |

## Eşyalar
WoW Classic mantığıyla: nadirlik renkleri (gri, beyaz, yeşil, mavi, mor), 16 ekipman yuvası, 16 gözlü çanta, bakır/gümüş/altın parası, eşya ipuçları ve giyili eşyayla karşılaştırma. Canavarlar ceset üzerinde ganimet bırakır (sol tık veya G). Tüccar Hilda ve Demirci Borga eşya satar, sattıklarını geri alabilirsin. Görev ödüllerinde eşya seçersin. İki takım vardır: Derin Ocak Takımı ve Dağ Kralının Mirası; parça sayısına göre ek güç verir. Eşyalar sadece istatistik değiştirir, görünüm değişmez.

## Görevler
Üç görev vericisi (Avcı Başı Ragna, Muhafız Dorn, Komutan Thrum) birer görev zinciri verir; biri bitince sıradaki açılır. Toplam 28 görev var (Kar Dağı, Bataklık, Maden ve Kül Diyarı görevleri dahil). Her görev tecrübe, para ve üç eşyadan birini seçme hakkı verir. Görev vericisinin üstündeki `!` yeni görev, `?` teslim demektir. Kabul ettiğin her görevin hedefi (öldürülecek mob ya da teslim edilecek NPC) ekranda altın bir işaretle, mesafesiyle birlikte gösterilir; hedef ekran dışındaysa kenarda ok görünür. Mini haritada ve dünya haritasında (M) da altın elmasla işaretlenir. Hedef başka haritadaysa ilgili portal gösterilir.

## Düşmanlar
Kurt, yaban domuzu ve dağ ayısına ek olarak dört kamp vardır: **Troggar** (doğu, Sv 3-6), **Gnoll'lar** (doğu-güney, Sv 4-7), **Defias haydutları** (güneybatı, Sv 6-8) ve **Kara Demir büyücüleri** (batı, Sv 7-9; uzaktan ateş okuyla vururlar). Her türün kendine özel çerçöpü düşer.

## Bosslar
Dünyada 10 boss var, hepsi yüksek canlı ve kendine özel yeteneklidir; ölünce mor/mavi eşya bırakır ve beş-on dakikada yeniden doğar:
- **Büyük Baba Arctikus** (Sv 6, batı ormanı): Parçala, Yırtma (kanama), canı azalınca öfke.
- **Grik'nir the Cold** (Sv 5, doğu): Don Dalgası (yavaşlatır), Buz Oku.
- **Chok'sul** (Sv 7, batı): Yer Yarığı (geri savurur), öfke.
- **Hogger** (Sv 8, doğu): gnoll çırakları çağırır, canı azalınca yemek yiyip iyileşir.
- **Buzul Devi Thokk** (Sv 9, doğu, dünya canavarı): Buz Dalgası ile yavaşlatır, canı yarıya inince buz hizmetkârları çağırır; Buzul Devi'nin Kalkanı ve Don Pelerini düşürür.
- **Edwin VanCleef** (Sv 9, güneybatı): Defias haydutları çağırır, Sırttan Bıçak, zehir.
- **Ragnaros** (Sv 10, Demirkazan'daki büyük ocakta): Gazap (geri savurur), Magma Topu, Alev Oğulları. Kendiliğinden saldırmaz; sen saldırınca uyanır. Ona yaklaşmadan önce iyi eşya topla.

## Kayıt
Oyun her 20 saniyede, görev alıp bitirince ve menüden çıkarken kendiliğinden kaydolur. Başlangıç ekranında **Devam et** ile kaldığın yerden devam edersin. Kayıt dosyası bilgisayarında oyun verileri klasöründe (`cuce_save.json`) durur.

## Kendin derlemek istersen
Godot 4.3 ile bu klasörü aç (`project.godot`), F5. Dışarıdan dosya yok; her şey kodla üretilir.

## Arayüz (WoW tarzı)
Taş-metal çerçeveli oyuncu/hedef/aksiyon çubuğu, altın grifon kanatları, bölmeli tecrübe çubuğu, sohbet sekmeleri (Genel / Savaş Kaydı), mini harita saati, mikro menü (Karakter, Yardım, Menü) ve çanta çubuğu (B).

## Üçüncü taraf varlıklar
Köydeki evler, çadırlar, variller, sandıklar, çit, tezgâh ve araba modelleri **Kenney** (www.kenney.nl) tarafından hazırlanmış, CC0 (kamu malı) lisanslı Fantasy Town ve Survival kitlerindendir (`godot/assets/kenney/`, lisans dosyası orada).

## İkinci harita: Sisli Bataklık
Demirkazan plazasındaki mavi portaldan (ve bataklıktaki turuncu portaldan geri) geçilir. Seviye 8–10: Murloc, Murloc Şamanı, Timsah, Bataklık Canavarı, boss Gruff Swiftbite. Bataklık Karakolu'nda 2 görev veren NPC ve bir tüccar var; 5 yeni görev, yeni eşyalar ve takas edilebilir ganimetler eklendi. Oyun kaydı hangi haritada olduğunu hatırlar.

## Zindan: Kara Demir Madeni
Demirkazan'ın sol portalından (turuncu) girilir, Sv 12+ önerilir. Dört odalı tek kişilik bir zindandır: madenciler, örümcekler, golemler ve muhafızlar. Ortada **Gorduk Taşyürek** (ara boss: deprem, kaya fırlatma, taş parçaları), en dipte **Vurgan** (son boss: kor dalgası, muhafız çağırma, öfke) bulunur. Giriş odasındaki mavi portal Demirkazan'a döndürür. Madenci Başı Durin'in üç görevi vardır. Ölürsen madenin girişinde canlanırsın.

## Meslekler, itibar ve başarımlar (K)
- **Madencilik** (Madenci Başı Durin): Kar Dağı'ndaki ve madendeki damarlara yaklaşıp G'ye bas. Demir ve Kara Demir cevheri verir. Damarlar 150 sn sonra yeniden çıkar.
- **Deri İşleme** (Avcı Başı Ragna): Hayvanlardan ham deri düşer; deriyi işleyip pelerin ve kemer yaparsın.
- **Demircilik** (Demirci Borga): Cevheri külçeye çevirir, külçe ve deriden silah ve zırh dökersin. Üretim Demirkazan içinde yapılır.
- **İtibar**: Demirkazan Kalesi, Bataklık Karakolu, Maden Loncası ve Kül Nöbetçileri. Görev teslimi ve düşman öldürmek itibar kazandırır; Dost ve üstünde o gruptaki satıcılar %5-20 indirim yapar.
- **Başarımlar**: 27 başarım; boss, görev, meslek, itibar ve seviye hedefleri.

## Test sürümü
Windows test derlemeleri GitHub Actions üzerinden ZIP artifact olarak yayımlanır. Bu dal, mevcut tek oyunculu oyunun test edilebilir sürümünü içerir; yeni MMORPG veri servisleri henüz ana oyun döngüsüne bağlanmamıştır.

## Üçüncü harita: Kül Diyarı
Bataklık Karakolu'ndaki kırmızı portaldan girilir, Sv 14–20. Gökten kül yağan, lav havuzlarıyla dolu bir diyardır (havuzlara girilemez). Düşmanlar: Kül Elementali (uzaktan vurur), Cüruf Golemi, Kül Ogresi, Yanık İskelet. Üç boss vardır: **Golemagg** (Magma Dalgası, çekirdek köpekleri), **Baron Geddon** (Cehennem halkası, Yaşayan Bomba, Armagedon), **Sulfuron** (hizmetkâr çağırma, Kül Dalgası, öfke). Kül Nöbetçileri Kampı'nda iki görev vericisi (Nöbetçi Torga, Kor Avcısı Zeyra) ve tüccar Rolf bulunur; yedi görev, "Kül Dövmesi" eşya takımı ve yeni bir itibar grubu (Kül Nöbetçileri) eklendi. Kampın portalları Bataklık'a ve Demirkazan'a döndürür.

## Savaş Çığlıkları
Kar Dağı, Bataklık ve Kül Diyarı'nda üçer **kelime duvarı** (parlayan mavi rünlü taş) vardır; yanına gidip **G** ile okuyunca bir çığlık kelimesi öğrenirsin ve tecrübe kazanırsın. Üç çığlık var, her biri 3 kelimeyle güçlenir: **Taş Yıkan** (önündeki düşmanları geri savurur), **Demir Deri** (süreli hasar azaltma), **Kül Nefesi** (önündeki düşmanları yakar). **Z** çığlığı kullanır, **X** çığlık değiştirir (tuşlar değiştirilebilir). Tüm çığlıklar ortak bir bekleme süresini paylaşır; durum ekranın üstünde görünür. Öğrenilen kelimeler kayda girer.

## Banka, dünya haritası, ayarlar
- **Bankacı Gundri** (Demirkazan): 28 yuvalık depo; "Banka" ve "Çantam" sekmeleriyle eşya koyup alırsın, çantada sağ tık da bankaya koyar. Banka kayda dahildir.
- **M**: dünya haritası (kamplar, bosslar, portallar, `!`/`?` NPC'ler).
- **Esc menüsü**: grafik kalitesi (Düşük/Orta/Yüksek) ve ses; seçimler `user://ayarlar.cfg` dosyasına kaydedilir.
- Kar Dağı ve Bataklık'ta gece-gündüz, kar fırtınası ve yağmur vardır.
- **Tuş atama**: Esc menüsünde "Tuş atama" ile hareket, zıplama, pencere tuşları vb. değiştirilir; aynı tuşu başka işleme verirsen iki işlem yer değiştirir.
- **Kısayol çubuğu**: yetenek simgelerini fareyle sürükleyip başka kutuya bırakarak yerlerini değiştirirsin; düzen kaydedilir.

## Güvenlik ve oynanış sistemleri
- Kayıt dosyası sürümlüdür ve her kayıtta yedeklenir; ana dosya bozulursa yedekten yüklenir.
- Savaş: art arda vuruşlarda küçük kombo bonusu, çeviklikle düşman saldırısından kaçınma ("Kaçındın").
- Kamplarda nadiran **Nadir** düşmanlar doğar (daha çok can/hasar, daha iyi ödül). Boss başına en çok 8 yardımcı çıkar; uzaktaki sıradan düşmanlar daha seyrek güncellenir.
- NPC'ler seni hatırlar; "Söylentiler" ve "Bölge tehlikeleri" konuşmaları vardır. Ayrıntılar: `godot/systems/README.md`.

## Notlar

- Kamera yakınlaştırması (fare tekerleği) yumuşak geçişlidir; fikir Reia'nın (AGPL-3.0) kamera betiğinden esinlenmiştir, kod kopyalanmamıştır.
