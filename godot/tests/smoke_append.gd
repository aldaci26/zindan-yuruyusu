
# --- Otomatik duman testi: run_smoke.sh bu bloğu geçici bir proje kopyasındaki main.gd'ye ekler ---
func _selftest() -> void:
	var fails := 0
	for mp in ["snow", "swamp", "mine", "ash", "snow"]:
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
	# savaş çığlıkları: duvarlar kurulmalı, her çığlık hatasız kullanılmalı
	for mp3 in ["snow", "swamp", "ash"]:
		_enter_map(mp3)
		for i in 3:
			step(0.1)
		var want := 0
		for w3 in Shouts.WALLS:
			if w3["map"] == mp3:
				want += 1
		if wall_list.size() != want:
			print("ÇIĞLIK duvar sayısı ", mp3, " ", wall_list.size(), "/", want)
			fails += 1
		P["x"] = wall_list[0]["x"]
		P["z"] = wall_list[0]["z"] + 2.0
		P["walls"].clear()
		if not try_read_wall() or P["walls"].size() != 1:
			print("ÇIĞLIK okunamadı ", mp3)
			fails += 1
	for w4 in Shouts.WALLS:
		P["walls"][w4["id"]] = true
	for sid in Shouts.ORDER:
		P["shout_sel"] = sid
		P["shout_cd"] = 0.0
		use_shout()
		step(0.1)
	P["walls"].clear()
	P["skin_t"] = 0.0
	_enter_map("snow")
	# görev işaretleri: her etkin/teslim görev için her haritada bir işaret çıkmalı
	for mp2 in ["snow", "swamp", "mine", "ash"]:
		_enter_map(mp2)
		for i in 5:
			step(0.1)
		for qid in QUESTS:
			for st2 in ["active", "ready"]:
				qs.clear()
				qs[qid] = {"st": st2, "n": 0}
				var w2: Array = _quest_waypoints()
				if w2.size() != 1:
					print("İŞARET YOK ", mp2, " ", qid, " ", st2)
					fails += 1
				else:
					var sc2: Array = _waypoint_screen(w2)
					if sc2.size() != 1:
						fails += 1
		qs.clear()
	_enter_map("snow")
	# yetenekler: bütün çubuk hatasız çalışmalı
	P["lvl"] = MAX_LVL
	for ai in HudScript.ABIL.size():
		var tm = nearest_mob(60.0)
		if tm == null:
			break
		var dk: String = HudScript.ABIL[ai]["kind"]
		var off := 10.0 if dk in ["charge", "throw"] else 2.0
		P["x"] = tm.x
		P["z"] = tm.z - off
		P["y"] = height_at(P["x"], P["z"])
		P["rage"] = 100.0
		P["gcd"] = 0.0
		P["cd"][ai] = 0.0
		P["target"] = tm
		tm.hp = tm.maxhp
		tm.dead = false
		ability(ai)
		for k in 6:
			step(0.1)
	print("YETENEKLER ", HudScript.ABIL.size())
	# beceriler ve perkler
	for sid in Skills.ORDER:
		for k in 300:
			skill_xp(sid, 5.0)
		if skl(sid) < 30:
			print("BECERİ GELİŞMEDİ ", sid)
			fails += 1
	for pk in Skills.PERKS:
		take_perk(pk["id"])
	if P["perks"].size() < 10:
		print("PERK ALINAMADI ", P["perks"].size())
		fails += 1
	progui.win.visible = true
	for tb in 5:
		progui.tab = tb
		progui.refresh()
	progui.win.visible = false
	print("BECERİLER ", P["perks"].size(), " perk")
	# diyalog ağaçları: bağlantılar geçerli olmalı ve düğümler hatasız gösterilmeli
	for nid in DialogueTrees.TREES:
		cur_npc = {"id": nid, "name": nid, "title": "t", "role": "quest", "qs": []}
		var tr: Dictionary = DialogueTrees.TREES[nid]
		if not tr.has("start"):
			print("DİYALOG BAŞLANGIÇ YOK ", nid)
			fails += 1
		for ndid in tr:
			var nd: Dictionary = tr[ndid]
			if nd.has("lore") and not Journal.LORE.has(nd["lore"]):
				print("DİYALOG BİLGİ YOK ", nid, " ", ndid)
				fails += 1
			if nd.has("rep") and not Prog.FACTIONS.has(nd["rep"][0]):
				print("DİYALOG İTİBAR HATALI ", nid, " ", ndid)
				fails += 1
			for o in nd.get("opts", []):
				var refs: Array = []
				if o.get("next", "") != "":
					refs.append(o["next"])
				if o.has("check"):
					refs.append(o["check"]["ok"])
					refs.append(o["check"]["fail"])
				for r in refs:
					if not tr.has(r):
						print("DİYALOG BAĞLANTI YOK ", nid, " ", ndid, " -> ", r)
						fails += 1
				if o.get("need", {}).has("q") and not QUESTS.has(o["need"]["q"]):
					print("DİYALOG GÖREV YOK ", nid, " ", ndid)
					fails += 1
			talk_node(nid, ndid)
		P["talked"] = {}
		P["skl"]["speech"] = {"lv": 35, "xp": 0.0}
		for ndid in tr:
			for o in tr[ndid].get("opts", []):
				if o.has("check"):
					_talk_choose(nid, o)
	cur_npc = null
	hud.hide_dialog()
	for qid in Journal.GIVERS:
		if not QUESTS.has(qid):
			print("GÜNLÜK GÖREV YOK ", qid)
			fails += 1
	for qid in QUESTS:
		if not Journal.GIVERS.has(qid):
			print("GÜNLÜK VEREN YOK ", qid)
			fails += 1
	progui.win.visible = true
	progui.tab = 1
	progui.refresh()
	progui.win.visible = false
	print("DİYALOG ", DialogueTrees.TREES.size(), " ağaç, bilgi ", P["lore"].size(), "/", Journal.LORE.size())
	# kayıt / yükleme
	save_game()
	if not load_game():
		print("KAYIT YÜKLENEMEDİ")
		fails += 1
	elif P["perks"].size() < 10 or skl("onehand") < 30:
		print("KAYITTA BECERİ KAYBI")
		fails += 1
	# yetenek ve kalite
	for q in [0, 1, 2]:
		apply_quality(q)
	print("SMOKE ", "OK" if fails == 0 else "FAIL %d" % fails)
	get_tree().quit(fails)
