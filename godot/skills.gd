extends RefCounted
## Savaşçı yetenekleri (WoW Classic savaşçısından esinli). Sıra = aksiyon çubuğu yuvası (1-9).

const LIST := [
	{"id": "heroic", "name": "Kahraman Vuruşu", "cost": 15, "cd": 0.0, "lvl": 1, "range": "Yakın menzil",
		"desc": "Hedefe silah hasarının 2.3 katı vurur."},
	{"id": "charge", "name": "Hücum", "cost": 0, "cd": 14.0, "lvl": 2, "range": "6-25 metre",
		"desc": "Hedefe atılır, 1.5 sn sersemletir ve 15 öfke verir."},
	{"id": "rend", "name": "Parçalama", "cost": 10, "cd": 0.0, "lvl": 3, "range": "Yakın menzil",
		"desc": "Hedefi kanatır: 15 saniye boyunca her 3 saniyede hasar verir."},
	{"id": "thunder", "name": "Gök Gürültüsü", "cost": 20, "cd": 6.0, "lvl": 4, "range": "Çevredekiler",
		"desc": "Yakındaki tüm düşmanlara hasar verir ve 8 sn yavaşlatır."},
	{"id": "bash", "name": "Kalkan Çarpması", "cost": 12, "cd": 10.0, "lvl": 5, "range": "Yakın menzil",
		"desc": "Hedefe vurur ve 2.5 saniye sersemletir."},
	{"id": "shout", "name": "Savaş Narası", "cost": 10, "cd": 3.0, "lvl": 6, "range": "Kendin",
		"desc": "Saldırı gücünü 60 saniye boyunca yüzde 25 artırır."},
	{"id": "block", "name": "Kalkan Bloğu", "cost": 10, "cd": 12.0, "lvl": 7, "range": "Kendin",
		"desc": "5 saniye boyunca aldığın hasarı yarıya indirir."},
	{"id": "execute", "name": "İdam", "cost": 15, "cd": 0.0, "lvl": 8, "range": "Yakın menzil",
		"desc": "Yalnızca canı yüzde 20'nin altındaki hedefe: silah hasarının 4.2 katı."},
	{"id": "mortal", "name": "Ölümcül Vuruş", "cost": 30, "cd": 6.0, "lvl": 8, "range": "Yakın menzil",
		"desc": "Hedefe silah hasarının 3.2 katı vurur."},
]

const BUFF_DUR := {"shout": 60.0, "block": 5.0, "rend": 15.0, "slow": 8.0, "stun": 2.5}
const BUFF_NAME := {"shout": "Savaş Narası", "block": "Kalkan Bloğu", "rend": "Parçalama", "slow": "Gök Gürültüsü", "stun": "Sersem"}
