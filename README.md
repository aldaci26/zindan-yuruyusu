# Zindan Yürüyüşü

Tarayıcıda oynanan, World of Warcraft'tan esinlenmiş açık dünya mini RPG. Tek dosya (`index.html`), kurulum ve sunucu gerekmez. iPhone dikey ekranına sığacak şekilde tasarlandı.

## Özellikler

- **Açık dünya:** 80x80 karelik harita, 4 bölge (Yeşilvadi, Karaorman, Kızıl Çöl, Buzdağı), 4 köy, yollar
- **4 sınıf:** Savaşçı, Büyücü, Rahip, Avcı. Her sınıfın 4 yeteneği var, yetenekler seviye atladıkça açılır
- **Avcı'nın kurdu:** sadık bir kurt seni takip eder ve hedefine saldırır
- **Büyü süresi:** Ateş Topu, Meteor, Şifa gibi büyüler birkaç saniye hazırlanır, yürürsen iptal olur
- **Seviye 1-20**, dinlenmiş tecrübe (köyde dinlenince bir sonraki öldürmeler çift tecrübe verir)
- **Görevler:** 17 görev, "!" ve "?" işaretleri, görev takibi, mektup teslim görevleri
- **Elit canavarlar, bölge patronları ve final patronu** (Buz Ejderhası)
- **Ganimet:** Sıradan, Nadir, Üstün, Destansı eşyalar
- **Köylerde:** şifacı, tüccar, görev veren, **uçuş ustası** (keşfettiğin köylere hızlı seyahat)
- **Binek**, şifalı otlar, iksirler
- **Yetenek puanları:** her seviyede 1 puan. Güç, Dayanıklılık, Zihin, Keskin Göz (kritik şansı) ve Çeviklik (hız) arasında dağıt, her biri 5 kademe
- **Ev Taşı:** 8 saniye hazırlanır, savaş dışında son girdiğin köye ışınlar. 5 dakika bekleme süresi
- **Maden damarları:** haritada ⛏️ taşlar, üzerinden geç, altın topla. Ara sıra parlak mücevher çıkar
- **Başarımlar**, gece-gündüz döngüsü, mini harita, dünya haritası, kar yağışı
- Otomatik kayıt (`localStorage`)

## 3D sürüm (deneme)

`3d.html` dosyası oyunun 3D deneme sürümüdür: Dun Morogh esintili karlı bir vadide **cüce savaşçı**. Kodla çizilmiş özgün low-poly sahne, üçüncü şahıs kamera, öfke (rage) ile çalışan yetenekler (Güçlü Vuruş, Savuruş, Kalkan Çarpması), kurt, yaban domuzu ve ayı avı, kamp ateşi ve köy. Pages açıksa adres: `https://aldaci26.github.io/zindan-yuruyusu/3d.html`

Kontroller: sol yarıda sürükle = yürü, sağ yarıda sürükle = kamera, düşmana dokun = hedef seç. Klavyede WASD, Q/E kamera, `Boşluk` otomatik saldırı, `1` `2` `3` yetenekler, `F` iksir.

## Kontroller

| Dokunmatik | Klavye |
| --- | --- |
| Ekranın sol tarafına dokun ve sürükle: yürü | Ok tuşları / WASD |
| Düşmana dokun: hedef seç | `Tab`: en yakın hedef |
| Kılıç düğmesi: otomatik saldırı | `Boşluk` |
| Yetenek düğmeleri | `1` `2` `3` `4` |
| İksir / binek / Ev Taşı | `F` / `Z` / `H` |
| Konuş düğmesi (NPC yakınında çıkar) | `E` |
| Karakter / görevler / harita | `C` / `Q` / `M` |

## Oynamak

1. `index.html` dosyasını bir tarayıcıda aç, veya
2. GitHub Pages ile yayınla: **Settings → Pages → Branch: `main` / `/ (root)`**. Adres `https://KULLANICI.github.io/zindan-yuruyusu/` olur.

iPhone'da Safari'de aç, Paylaş düğmesi → **Ana Ekrana Ekle** ile tam ekran uygulama gibi kullan.

## Teknik

Saf HTML, CSS ve JavaScript, dış kütüphane yok. Yazı tipleri Google Fonts'tan yüklenir, yüklenemezse sistem yazı tipine düşer. Dünya sabit bir tohumdan üretilir.
