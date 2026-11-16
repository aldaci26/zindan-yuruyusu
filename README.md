# Zindan Yürüyüşü: 3D Cüce Savaşçı

World of Warcraft'tan esinlenmiş 3D bir cüce savaşçı oyunu. Godot 4.3 ile yapıldı, yalnızca Windows için derlenir.

## İndir

[Releases](../../releases) sayfasında iki sürüm var:

- **son-surum**: `main` dalının kararlı sürümü
- **entegrasyon-surum**: `entegrasyon` dalının deneme sürümü (güvenli kayıt/yedek, savaş kuralları, nadir düşmanlar, NPC hafızası)

`CuceSavasci-Windows.zip` dosyasını aç, `CuceSavasci.exe` çalıştır. Sürüm imzasızdır; "Windows bilgisayarını korudu" çıkarsa *Ek bilgi → Yine de çalıştır*. Kontroller, yetenekler, eşyalar, bosslar ve görevler: [godot/README.md](godot/README.md)

## Oyun

- Üç harita: Kar Dağı Vadisi (Demirkazan şehri), Sisli Bataklık ve Kara Demir Madeni; portallarla geçilir
- WoW tarzı arayüz, eşya sistemi (nadirlik, setler, satıcılar, banka), 10 boss, 21 görev
- Savaşçı yetenekleri ve yetenek ağacı, meslekler, itibar, başarımlar, gece-gündüz ve hava

## Geliştirme

Proje `godot/` klasöründe; Godot 4.3 ile aç ve çalıştır. Derleme `.github/workflows/godot-export.yml` ile yapılır.

Üçüncü taraf varlıklar: Kenney (CC0) modelleri, `godot/assets/kenney/LICENSE.txt`.
