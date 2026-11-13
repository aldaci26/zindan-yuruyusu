# Cüce Savaşçı (3D, Godot 4)

Karlı vadide kurt, domuz ve ayı avla; Demirkazan cüce şehrinde görev al, demirciden silah, tüccardan iksir al.

## İndir ve oyna
**Releases** sayfasından işletim sistemine uygun dosyayı indir:
- **Windows**: `CuceSavasci-Windows.zip` → aç → `CuceSavasci.exe`. ("Windows bilgisayarını korudu" çıkarsa: *Ek bilgi → Yine de çalıştır*.)
- **Mac**: `CuceSavasci-Mac.zip` → aç → uygulamaya sağ tık → *Aç*.
- **Linux**: `CuceSavasci-Linux.tar.gz` → aç → `./CuceSavasci.x86_64`.

Sürümler imzasızdır, bu yüzden işletim sistemi bir kez uyarı verir.

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
Üç görev vericisi (Avcı Başı Ragna, Muhafız Dorn, Komutan Thrum) birer görev zinciri verir; biri bitince sıradaki açılır. Toplam 13 görev var: trogg, gnoll, Defias ve Kara Demir avları ile Grik'nir, Arctikus, Chok'sul, Hogger, VanCleef ve Ragnaros boss görevleri. Her görev tecrübe, para ve üç eşyadan birini seçme hakkı verir. Görev vericisinin üstündeki `!` yeni görev, `?` teslim demektir.

## Düşmanlar
Kurt, yaban domuzu ve dağ ayısına ek olarak dört kamp vardır: **Troggar** (doğu, Sv 3-6), **Gnoll'lar** (doğu-güney, Sv 4-7), **Defias haydutları** (güneybatı, Sv 6-8) ve **Kara Demir büyücüleri** (batı, Sv 7-9; uzaktan ateş okuyla vururlar). Her türün kendine özel çerçöpü düşer.

## Bosslar
Dünyada 6 WoW bossu var, hepsi yüksek canlı ve kendine özel yeteneklidir; ölünce mor/mavi eşya bırakır ve beş-on dakikada yeniden doğar:
- **Büyük Baba Arctikus** (Sv 6, batı ormanı): Parçala, Yırtma (kanama), canı azalınca öfke.
- **Grik'nir the Cold** (Sv 5, doğu): Don Dalgası (yavaşlatır), Buz Oku.
- **Chok'sul** (Sv 7, batı): Yer Yarığı (geri savurur), öfke.
- **Hogger** (Sv 8, doğu): gnoll çırakları çağırır, canı azalınca yemek yiyip iyileşir.
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
