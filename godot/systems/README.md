# Sistem modülleri

`android-mobile-edition` dalındaki özgün yardımcı modüllerden seçilenler. Hiçbiri Reia ya da başka bir projeden kod/varlık kopyalamaz; yalnızca saf fonksiyonlardır ve `main.gd` içinde şuralarda kullanılır:

| Modül | Kullanım |
|---|---|
| `save_manager.gd` | Sürümlü kayıt zarfı, eski kayıtları kabul etme, her yazışta `.bak` yedeği; ana kayıt bozuksa yedekten yükleme (oyunda "yedekten yüklendi" yazar). |
| `combat_rules.gd` | Zırh/blok hesabı (`incoming_damage`), kritik ve çeşitleme (`outgoing_damage`), 3 sn içinde art arda vuruşlarda %2,5'lik kombo (en çok %25), çeviklikle kaçınma. |
| `spawn_director.gd` | Boss başına en çok 8 geçici yardımcı, yeniden doğuş gecikmesi (oyuncu 16 birimden yakınsa doğmaz), uzaktaki sıradan düşmanlar için AI seyreltme, nadir düşman şansı (%2-3,5; 2,2x can, 1,2x hasar, 1,8x ödül). |
| `navigation_steering.gd` | Yakın düşmanların birbirine yığılmasını azaltan ayrışma yönü. |
| `npc_dialogue.gd` | NPC hafızası (selam metni, "Söylentiler" ve "Bölge tehlikeleri" konuşmaları); kayda eklenir. |

Alınmayanlar: olay yolu, durum makinesi, düşman duyma/görme AI'ı, ayarlar ve hava simülasyonu (ana oyunda kendi karşılıkları var), mobil kontroller, Horde Survivors modu, testler.
