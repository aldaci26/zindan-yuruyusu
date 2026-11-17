#!/usr/bin/env bash
# Kullanım: godot/tests/run_smoke.sh /yol/Godot_v4.3-stable_linux.x86_64
# Projeyi geçici dizine kopyalar, duman testini ekler, xvfb altında çalıştırır. Çıkış kodu 0 = başarılı.
set -euo pipefail
GODOT="${1:?Godot yürütülebilir dosyasının yolunu ver}"
SRC="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
cp -r "$SRC"/. "$TMP"/
rm -rf "$TMP/tests"
cat "$SRC/tests/smoke_append.gd" >> "$TMP/main.gd"
python3 - "$TMP/main.gd" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace("\t_update_camera(0.0)\n\nfunc _build_world", "\t_update_camera(0.0)\n\tmode = \"play\"\n\t_selftest.call_deferred()\n\nfunc _build_world", 1)
open(p, "w").write(s)
PY
"$GODOT" --headless --import --path "$TMP" >/dev/null 2>&1 || true
OUT="$(timeout 300 xvfb-run -a "$GODOT" --rendering-driver opengl3 --path "$TMP" 2>&1 | grep -E 'MAP |YETENEK|BECERİ|PERK|SMOKE|EKSİK|KAYIT|SCRIPT ERROR|Parse' || true)"
echo "$OUT"
echo "$OUT" | grep -q 'SMOKE OK'
