
# --- Otomatik duman testi: run_smoke.sh bu bloğu geçici bir proje kopyasındaki main.gd'ye ekler ---
func _selftest() -> void:
	var fails := 0
	for mp in ["snow", "swamp", "mine", "snow"]:
		_enter_map(mp)
		for i in 60:
			step(0.1)
		var bosses := 0
		for mb in mobs:
			if mb.boss != "":
				bosses += 1
		print("MAP ", mp, " mobs=", mobs.size(), " bosses=", bosses, " npcs=", npcs.size())
		if mobs.is_empty():
			fails += 1
	# gece-gündüz ve hava
	for ph in [0.0, 120.0, 165.0]:
		T = ph
		day_acc = 1.0
		for i in 20:
			step(0.2)
	# görevler: her görevin ödülü gerçek bir eşya olmalı
	for qid in QUESTS:
		for r in QUESTS[qid]["rew"]:
			if not Items.db().has(r):
				print("EKSİK ÖDÜL ", qid, " ", r)
				fails += 1
	# kayıt / yükleme
	save_game()
	if not load_game():
		print("KAYIT YÜKLENEMEDİ")
		fails += 1
	# yetenek ve kalite
	for q in [0, 1, 2]:
		apply_quality(q)
	print("SMOKE ", "OK" if fails == 0 else "FAIL %d" % fails)
	get_tree().quit(fails)
