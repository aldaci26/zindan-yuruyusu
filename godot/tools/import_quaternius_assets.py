#!/usr/bin/env python3
"""Import a curated set of CC0 Quaternius GLB assets into the Godot project.

The source revision and the selected pack list are deliberately pinned. This
script is run by GitHub Actions, where network access is available.
"""
from __future__ import annotations

import json
import os
import shutil
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

SOURCE_REPO = "trebeljahr/quaternius-showcase"
SOURCE_COMMIT = "0128ca510d653bb04d6d1e4885bd8890b5050b4f"
TREE_URL = (
    f"https://api.github.com/repos/{SOURCE_REPO}/git/trees/"
    f"{SOURCE_COMMIT}?recursive=1"
)
RAW_ROOT = f"https://raw.githubusercontent.com/{SOURCE_REPO}/{SOURCE_COMMIT}/"
PROJECT_ROOT = Path(__file__).resolve().parents[1]
ASSET_ROOT = PROJECT_ROOT / "assets" / "wotlk" / "third_party" / "quaternius"
RUNTIME_WOLF = PROJECT_ROOT / "assets" / "wotlk" / "creatures" / "wolf.glb"

# Only packs whose source pages are individually confirmed CC0-1.0 in the
# pinned upstream LICENSES.md are allowed here. Do not add QAL packs.
PACKS = {
    "animals_pack": "https://quaternius.com/packs/ultimateanimatedanimals.html",
    "modular_men": "https://quaternius.com/packs/ultimatemodularcharacters.html",
    "medieval_village_pack": "https://quaternius.com/packs/medievalvillage.html",
    "medieval_weapons_pack": "https://quaternius.com/packs/medievalweapons.html",
    "modular_dungeon_1": "https://quaternius.com/packs/modulardungeon.html",
    "easy_enemies_pack": "https://quaternius.com/packs/easyenemy.html",
    "nature_pack": "https://quaternius.com/packs/ultimatenature.html",
    "rpg_items_pack": "https://quaternius.com/packs/ultimaterpg.html",
    "buildings_pack_2": "https://quaternius.com/packs/buildings.html",
    "buildings_pack_3": "https://quaternius.com/packs/ultimatetexturedbuildings.html",
    "crops_pack": "https://quaternius.com/packs/ultimatecrops.html",
    "cute_fish_pack": "https://quaternius.com/packs/cutefish.html",
    "dinosaurs_pack": "https://quaternius.com/packs/animateddinosaurs.html",
    "fish_pack": "https://quaternius.com/packs/animatedfish.html",
    "house_interior_pack": "https://quaternius.com/packs/ultimatehomeinterior.html",
    "modular_dungeon_pack": "https://quaternius.com/packs/medievaldungeon.html",
    "modular_medieval_buildings_pack": "https://quaternius.com/packs/modularmedievalbuildings.html",
    "modular_women": "https://quaternius.com/packs/ultimatemodularwomen.html",
    "real_time_strategy_pack": "https://quaternius.com/packs/ultimatefantasyrts.html",
    "simple_nature_pack": "https://quaternius.com/packs/simplenature.html",
    "single_knight_pack": "https://quaternius.com/packs/knightcharacter.html",
    "street_pack": "https://quaternius.com/packs/modularstreets.html",
    "survival_pack": "https://quaternius.com/packs/survival.html",
}


def request_bytes(url: str, token: str = "") -> bytes:
    headers = {"User-Agent": "zindan-yuruyusu-asset-import/1.0"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    last_error = None
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=90) as response:
                return response.read()
        except (urllib.error.URLError, TimeoutError) as exc:
            last_error = exc
            if attempt == 3:
                break
            time.sleep(2 ** attempt)
    raise RuntimeError(f"Download failed after retries: {url}: {last_error}")


def main() -> int:
    token = os.environ.get("GITHUB_TOKEN", "")
    tree_data = json.loads(request_bytes(TREE_URL, token))
    if tree_data.get("truncated"):
        raise RuntimeError("Upstream Git tree was truncated; refusing partial import.")

    allowed_prefixes = tuple(f"public/glb/{pack}/" for pack in PACKS)
    selected = [
        entry for entry in tree_data.get("tree", [])
        if entry.get("type") == "blob"
        and entry.get("path", "").startswith(allowed_prefixes)
        and entry.get("path", "").lower().endswith(".glb")
    ]
    if not selected:
        raise RuntimeError("No GLB files found in the pinned, allowlisted packs.")

    ASSET_ROOT.mkdir(parents=True, exist_ok=True)
    manifest = {
        "source_repository": f"https://github.com/{SOURCE_REPO}",
        "source_commit": SOURCE_COMMIT,
        "source_license_manifest": (
            f"https://github.com/{SOURCE_REPO}/blob/{SOURCE_COMMIT}/LICENSES.md"
        ),
        "license": "CC0-1.0",
        "creator": "Quaternius (Kay Lousberg)",
        "packs": PACKS,
        "assets": [],
    }

    total_bytes = 0
    for index, entry in enumerate(selected, start=1):
        source_path = entry["path"]
        relative_path = source_path.removeprefix("public/glb/")
        destination = ASSET_ROOT / relative_path
        destination.parent.mkdir(parents=True, exist_ok=True)
        data = request_bytes(RAW_ROOT + source_path, token)
        expected_size = int(entry["size"])
        if len(data) != expected_size:
            raise RuntimeError(
                f"Size mismatch for {source_path}: got {len(data)}, "
                f"expected {expected_size}"
            )
        if data[:4] != b"glTF":
            raise RuntimeError(f"Invalid GLB header: {source_path}")
        destination.write_bytes(data)
        total_bytes += len(data)
        manifest["assets"].append({
            "path": relative_path,
            "source_path": source_path,
            "git_blob_sha": entry["sha"],
            "size_bytes": len(data),
            "license": "CC0-1.0",
            "source_pack_page": PACKS[relative_path.split("/", 1)[0]],
        })
        print(f"[{index}/{len(selected)}] {relative_path} ({len(data):,} bytes)")

    # The runtime already knows this stable path. Keep the original vendor
    # copy too; Git stores identical file content as a single blob.
    wolf_source = ASSET_ROOT / "animals_pack" / "Wolf.glb"
    if not wolf_source.is_file():
        raise RuntimeError("The expected Wolf.glb model is missing from animals_pack.")
    RUNTIME_WOLF.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(wolf_source, RUNTIME_WOLF)

    manifest["summary"] = {
        "file_count": len(selected),
        "total_bytes": total_bytes,
        "runtime_aliases": {
            "assets/wotlk/creatures/wolf.glb": (
                "third_party/quaternius/animals_pack/Wolf.glb"
            )
        },
    }
    manifest_path = ASSET_ROOT / "ASSET_MANIFEST.json"
    manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(
        f"Imported {len(selected)} GLB assets "
        f"({total_bytes / 1024 / 1024:.2f} MiB)."
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"ASSET IMPORT FAILED: {exc}", file=sys.stderr)
        raise
