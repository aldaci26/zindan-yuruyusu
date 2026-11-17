extends Node
## Kodla üretilen ses efektleri ve rüzgâr sesi (dış ses dosyası yok).

const RATE := 22050
var streams := {}
var pool: Array = []
var next := 0
var wind: AudioStreamPlayer
var amb: AudioStreamPlayer
var music: AudioStreamPlayer
var loops := {}
var cur_map := ""

func _ready() -> void:
	streams["swing"] = _make(0.2, func(t, n): return _noise_lp(n, 0.35) * sin(t / 0.2 * PI) * 0.5)
	streams["hit"] = _make(0.16, func(t, n): return (sin(TAU * (150.0 - 400.0 * t) * t) * 0.8 + _noise_lp(n, 0.5) * 0.5) * exp(-t * 22.0))
	streams["crit"] = _make(0.3, func(t, n): return (sin(TAU * (190.0 - 300.0 * t) * t) * 0.8 + _noise_lp(n, 0.6) * 0.5 + sin(TAU * 1400.0 * t) * 0.25) * exp(-t * 14.0))
	streams["hurt"] = _make(0.22, func(t, n): return (sin(TAU * (90.0 - 120.0 * t) * t) * 0.9 + _noise_lp(n, 0.3) * 0.5) * exp(-t * 14.0))
	streams["coin"] = _make(0.3, func(t, n): return (sin(TAU * 1320.0 * t) + (sin(TAU * 1760.0 * (t - 0.07)) if t > 0.07 else 0.0)) * 0.3 * exp(-t * 9.0))
	streams["level"] = _make(1.0, func(t, n): return _arp(t) * 0.35)
	streams["quest"] = _make(0.6, func(t, n): return (sin(TAU * 523.0 * t) * exp(-t * 6.0) + (sin(TAU * 784.0 * (t - 0.18)) * exp(-(t - 0.18) * 5.0) if t > 0.18 else 0.0)) * 0.35)
	streams["potion"] = _make(0.45, func(t, n): return sin(TAU * (400.0 + 180.0 * sin(t * 40.0)) * t) * 0.3 * sin(t / 0.45 * PI))
	streams["charge"] = _make(0.4, func(t, n): return _noise_lp(n, 0.15 + t * 1.2) * sin(t / 0.4 * PI) * 0.6)
	streams["shout"] = _make(0.55, func(t, n): return (_saw(150.0 * t) * 0.5 + _saw(225.0 * t) * 0.25) * sin(minf(t / 0.08, 1.0) * PI / 2.0) * exp(-t * 3.0) * 0.6)
	streams["block"] = _make(0.4, func(t, n): return (sin(TAU * 820.0 * t) + sin(TAU * 1330.0 * t) * 0.6 + sin(TAU * 2110.0 * t) * 0.3) * 0.3 * exp(-t * 9.0))
	streams["thunder"] = _make(0.6, func(t, n): return (_noise_lp(n, 0.12) * 0.9 + sin(TAU * 60.0 * t) * 0.5) * exp(-t * 6.0))
	streams["whirl"] = _make(0.6, func(t, n): return _noise_lp(n, 0.2 + 0.1 * sin(t * 30.0)) * sin(t / 0.6 * PI) * 0.6)
	streams["die"] = _make(0.8, func(t, n): return sin(TAU * (220.0 - 160.0 * t) * t) * exp(-t * 3.0) * 0.5)
	streams["click"] = _make(0.06, func(t, n): return sin(TAU * 900.0 * t) * exp(-t * 60.0) * 0.4)
	streams["step"] = _make(0.1, func(t, n): return _noise_lp(n, 0.25) * exp(-t * 40.0) * 0.5)
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)
	wind = AudioStreamPlayer.new()
	wind.stream = _wind()
	wind.volume_db = -24.0
	add_child(wind)
	amb = AudioStreamPlayer.new()
	amb.volume_db = -20.0
	add_child(amb)
	music = AudioStreamPlayer.new()
	music.volume_db = -19.0
	add_child(music)

var _lp := 0.0

func _noise_lp(n: float, k: float) -> float:
	_lp += (n - _lp) * clampf(k, 0.01, 1.0)
	return _lp * 1.8

func _saw(ph: float) -> float:
	return fmod(ph, 1.0) * 2.0 - 1.0

func _arp(t: float) -> float:
	var notes := [523.0, 659.0, 784.0, 1047.0]
	var v := 0.0
	for i in 4:
		var s: float = t - i * 0.12
		if s > 0.0:
			v += sin(TAU * notes[i] * s) * exp(-s * 4.0)
	return v

func _make(dur: float, fn: Callable) -> AudioStreamWAV:
	var n := int(dur * RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	_lp = 0.0
	for i in n:
		var v: float = fn.call(float(i) / RATE, randf() * 2.0 - 1.0)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	return w

func _wind() -> AudioStreamWAV:
	var n := 4 * RATE
	var data := PackedByteArray()
	data.resize(n * 2)
	var lp := 0.0
	var lp2 := 0.0
	for i in n:
		var t := float(i) / RATE
		lp += (randf() * 2.0 - 1.0 - lp) * 0.05
		lp2 += (lp - lp2) * 0.2
		var env := 0.55 + 0.45 * sin(t / 4.0 * TAU) * sin(t / 4.0 * TAU * 2.0 + 0.5)
		# döngü başı ve sonu aynı olsun
		var edge := minf(minf(t, 4.0 - t) / 0.2, 1.0)
		data.encode_s16(i * 2, int(clampf(lp2 * 5.0 * env * edge, -1.0, 1.0) * 20000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.data = data
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_end = n
	return w

func play(name: String, vol: float = 0.0, pitch: float = 1.0) -> void:
	if not streams.has(name):
		return
	var p: AudioStreamPlayer = pool[next]
	next = (next + 1) % pool.size()
	p.stream = streams[name]
	p.volume_db = vol
	p.pitch_scale = pitch * (0.95 + randf() * 0.1)
	p.play()

func start_ambient() -> void:
	if cur_map == "":
		set_map("snow")

## Harita başına ortam sesi ve müzik; ilk kullanımda üretilip saklanır
func set_map(name: String) -> void:
	if name == cur_map and wind.playing:
		return
	cur_map = name
	if not loops.has("m_" + name):
		loops["m_" + name] = _pad(name)
		if name == "swamp":
			loops["a_swamp"] = _loop(8.0, func(t, n): return _noise_lp(n, 0.04) * 0.5 + _frog(t))
		elif name == "ash":
			loops["a_ash"] = _loop(8.0, func(t, n): return _noise_lp(n, 0.03) * 0.5 + sin(TAU * 45.0 * t) * 0.12)
		elif name == "mine":
			loops["a_mine"] = _loop(8.0, func(t, n): return _noise_lp(n, 0.02) * 0.6 + sin(TAU * 55.0 * t) * 0.18 + _drip(t))
	music.stream = loops["m_" + name]
	music.play()
	if name == "snow":
		wind.volume_db = -24.0
		if not wind.playing:
			wind.play()
		amb.stop()
	else:
		wind.volume_db = -34.0 if name == "swamp" else -40.0
		if not wind.playing:
			wind.play()
		amb.stream = loops["a_" + name]
		amb.play()

func _frog(t: float) -> float:
	var v := 0.0
	for st in [0.7, 1.9, 2.4, 4.1, 5.6, 6.3]:
		var s: float = t - st
		if s > 0.0 and s < 0.25:
			v += sin(TAU * (260.0 + 40.0 * sin(s * 60.0)) * s) * exp(-s * 12.0) * 0.35
	for st2 in [1.2, 3.3, 5.0, 7.1]:
		var s2: float = t - st2
		if s2 > 0.0 and s2 < 0.2:
			v += sin(TAU * 3200.0 * s2) * sin(s2 * 80.0) * exp(-s2 * 10.0) * 0.12
	return v

func _drip(t: float) -> float:
	var v := 0.0
	for st in [0.9, 2.8, 4.4, 6.5]:
		var s: float = t - st
		if s > 0.0 and s < 0.3:
			v += sin(TAU * (1500.0 - 600.0 * s) * s) * exp(-s * 25.0) * 0.5
	return v

## Kesintisiz döngü: frekanslar tam sayı döngüye yuvarlanır
func _loop(dur: float, fn: Callable) -> AudioStreamWAV:
	var w := _make(dur, fn)
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_end = int(dur * RATE)
	return w

func _pad(name: String) -> AudioStreamWAV:
	var chords: Array = {
		"snow": [[220.0, 261.6, 329.6], [196.0, 246.9, 293.7], [174.6, 220.0, 261.6], [196.0, 246.9, 293.7]],
		"swamp": [[146.8, 174.6, 220.0], [130.8, 155.6, 196.0], [146.8, 174.6, 220.0], [116.5, 146.8, 174.6]],
		"mine": [[110.0, 130.8, 164.8], [103.8, 123.5, 155.6], [110.0, 130.8, 164.8], [98.0, 116.5, 146.8]],
		"ash": [[98.0, 116.5, 146.8], [87.3, 103.8, 130.8], [98.0, 116.5, 146.8], [82.4, 98.0, 123.5]],
	}[name]
	var dur := 16.0
	return _loop(dur, func(t, _n):
		var ci: int = int(t / 4.0) % 4
		var lt: float = fmod(t, 4.0)
		var env: float = sin(lt / 4.0 * PI)
		var v := 0.0
		for f in chords[ci]:
			var fr: float = roundf(f * 4.0) / 4.0
			v += sin(TAU * fr * t) * 0.5 + sin(TAU * fr * 2.0 * t) * 0.12
		return v * env * 0.22)

func set_volume(v: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(clampf(v, 0.0, 1.0)))
