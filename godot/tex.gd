extends RefCounted
## Kodla boyanan dokular (dış dosya yok). Boyut 240: 3'e, 6'ya ve 8'e tam bölünür, böylece döşenir.

const S := 240

static func _rng(seed_v: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_v
	return r

static func _finish(img: Image) -> ImageTexture:
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)

static func _speckle(img: Image, r: RandomNumberGenerator, n: int, amt: float) -> void:
	for k in n:
		var x := r.randi() % S
		var y := r.randi() % S
		var c := Color.BLACK if r.randf() < 0.5 else Color.WHITE
		img.set_pixel(x, y, img.get_pixel(x, y).lerp(c, r.randf() * amt))

static func stone() -> ImageTexture:
	var r := _rng(11)
	var img := Image.create(S, S, false, Image.FORMAT_RGB8)
	img.fill(Color8(91, 84, 76))
	var rows := 6
	var bh := S / rows
	var bw := S / 3
	for j in rows:
		var off := (j % 2) * bw / 2
		for i in range(-1, 4):
			var l := 132.0 + r.randf() * 48.0
			var x := i * bw + off + 2
			var y := j * bh + 2
			img.fill_rect(Rect2i(x, y, bw - 4, bh - 4), Color8(int(l + 16), int(l + 5), int(l - 12)))
			img.fill_rect(Rect2i(x, y, bw - 4, 3), Color8(int(l + 34), int(l + 24), int(l + 8)))
			img.fill_rect(Rect2i(x, y + bh - 8, bw - 4, 4), Color8(int(l - 26), int(l - 34), int(l - 46)))
	_speckle(img, r, 900, 0.18)
	return _finish(img)

static func wood() -> ImageTexture:
	var r := _rng(23)
	var img := Image.create(S, S, false, Image.FORMAT_RGB8)
	var pw := S / 4
	for i in 4:
		var l := 92.0 + r.randf() * 30.0
		img.fill_rect(Rect2i(i * pw, 0, pw, S), Color8(int(l + 34), int(l + 8), int(l - 28)))
		for g in 22:
			var gx := i * pw + r.randi() % pw
			var a := 0.12 + r.randf() * 0.18
			for y in range(0, S, 2):
				var px := clampi(gx + int(sin(y * 0.05 + g) * 1.5), 0, S - 1)
				img.set_pixel(px, y, img.get_pixel(px, y).lerp(Color8(40, 20, 8), a))
		img.fill_rect(Rect2i(i * pw, 0, 3, S), Color8(30, 14, 5))
	return _finish(img)

static func roof() -> ImageTexture:
	var r := _rng(37)
	var img := Image.create(S, S, false, Image.FORMAT_RGB8)
	img.fill(Color8(74, 28, 18))
	var rows := 8
	var th := S / rows
	var tw := S / 6
	for j in rows:
		var off := (j % 2) * tw / 2
		for i in range(-1, 7):
			var l := 0.8 + r.randf() * 0.35
			var x := i * tw + off + 1
			img.fill_rect(Rect2i(x, j * th, tw - 2, th - 3), Color8(int(158 * l), int(62 * l), int(40 * l)))
			img.fill_rect(Rect2i(x, j * th, tw - 2, 3), Color8(int(190 * l), int(96 * l), int(66 * l)))
			img.fill_rect(Rect2i(x + 2, j * th + th - 6, tw - 6, 3), Color8(int(110 * l), int(40 * l), int(26 * l)))
	_speckle(img, r, 500, 0.12)
	return _finish(img)

static func cobble() -> ImageTexture:
	var r := _rng(53)
	var img := Image.create(S, S, false, Image.FORMAT_RGB8)
	img.fill(Color8(70, 63, 56))
	var n := 8
	var cs := S / n
	for j in n:
		for i in n:
			var l := 118.0 + r.randf() * 55.0
			var c := Color8(int(l + 14), int(l + 3), int(l - 14))
			var x := i * cs
			var y := j * cs
			img.fill_rect(Rect2i(x + 4, y + 2, cs - 8, cs - 4), c)
			img.fill_rect(Rect2i(x + 2, y + 5, cs - 4, cs - 10), c)
			img.fill_rect(Rect2i(x + 5, y + 3, cs - 12, 3), c.lightened(0.18))
	_speckle(img, r, 700, 0.14)
	return _finish(img)

## Arazi için el boyaması hissi: iki ölçekli leke, ince tanecik, hafif çizgi
static func detail() -> ImageTexture:
	var nz := FastNoiseLite.new()
	nz.seed = 7
	nz.frequency = 0.03
	nz.fractal_octaves = 3
	var nz2 := FastNoiseLite.new()
	nz2.seed = 19
	nz2.frequency = 0.12
	nz2.fractal_octaves = 2
	var src := nz.get_seamless_image(S, S, false, false, 0.1, true)
	var src2 := nz2.get_seamless_image(S, S, false, false, 0.1, true)
	var r := _rng(5)
	var img := Image.create(S, S, false, Image.FORMAT_RGB8)
	for y in S:
		for x in S:
			var v := 0.78 + 0.16 * src.get_pixel(x, y).r + 0.12 * src2.get_pixel(x, y).r
			v *= 0.96 + r.randf() * 0.08
			img.set_pixel(x, y, Color(v * 0.99, v, v * 1.04))
	return _finish(img)
