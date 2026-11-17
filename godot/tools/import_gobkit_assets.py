#!/usr/bin/env python3
"""Import curated Gobkit CC0 models using its official read-only model manifest.

The API exposes per-pack/per-model licenses and named animation clips. We use
only its exact URLs, never construct download URLs, and keep hashes for every
downloaded binary so the public repository is reproducible.
"""
from __future__ import annotations
import concurrent.futures
import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

API_URL = "https://gobkit.com/api/free"
ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "assets" / "third_party" / "gobkit"
SOURCE_REPO = "https://gobkit.com"
SOURCE_LICENSE = "CC0 1.0 (public domain)"
ALLOW_PACK_IDS = {
    "gobkit-free-pack",
    "gobkit-animal-pack",
    "gobkit-animalB-pack",
    "gobkit-farm-pack",
    "gobkit-animal006-pack",
    "gobkit-animal007-pack",
    "gobkit-animal008-pack",
    "gobkit-animal009-pack",
    "gobkit-animal011-pack",
    "gobkit-animal012-pack",
    "gobkit-animal013-pack",
    "gobkit-birds-pack",
    "gobkit-dino-pack",
    "gobkit-human003-pack",
    "gobkit-human006-pack",
    "gobkit-human010-pack",
    "gobkit-human011-pack",
    "gobkit-human013-pack",
    "gobkit-human016-pack",
    "gobkit-insect001-pack",
    "gobkit-insect002-pack",
}

def get_bytes(url: str) -> bytes:
    headers = {"User-Agent": "zindan-yuruyusu-cc0-asset-import/2.0"}
    last_error = None
    for attempt in range(5):
        try:
            request = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(request, timeout=120) as response:
                return response.read()
        except (urllib.error.URLError, TimeoutError) as exc:
            last_error = exc
            if attempt < 4:
                time.sleep(2 ** attempt)
    raise RuntimeError(f"Download failed: {url}: {last_error}")

def inspect_glb(data: bytes) -> list[str]:
    if len(data) < 20 or data[:4] != b"glTF":
        raise RuntimeError("Invalid GLB header")
    if int.from_bytes(data[4:8], "little") != 2:
        raise RuntimeError("Only glTF 2.0 binary assets are accepted")
    json_length = int.from_bytes(data[12:16], "little")
    document = json.loads(data[20:20 + json_length].decode("utf-8").rstrip("\x00 \r\n"))
    return [item.get("name", f"animation_{i}") for i, item in enumerate(document.get("animations", []))]

def main() -> int:
    raw_manifest = get_bytes(API_URL)
    api = json.loads(raw_manifest)
    if api.get("schemaVersion") != 2 or int(api.get("totalFreeModels", 0)) < 200:
        raise RuntimeError("Gobkit API schema/count changed; review before importing")

    packs = {pack.get("id"): pack for pack in api.get("packs", [])}
    missing_packs = sorted(ALLOW_PACK_IDS - set(packs))
    if missing_packs:
        raise RuntimeError("Allowlisted Gobkit packs missing from API: " + ", ".join(missing_packs))

    allowed_urls = set(api.get("glbs", []))
    selected = []
    pack_manifest = []
    for pack_id in sorted(ALLOW_PACK_IDS):
        pack = packs[pack_id]
        if not str(pack.get("license", "")).startswith("CC0 1.0"):
            raise RuntimeError(f"Pack license is not CC0: {pack_id}")
        models = pack.get("models", [])
        if not models:
            raise RuntimeError(f"Pack has no model metadata: {pack_id}")
        pack_manifest.append({
            "id": pack_id,
            "name": pack.get("name", pack_id),
            "kind": pack.get("kind", ""),
            "count": pack.get("count", len(models)),
            "license": pack["license"],
            "animations": pack.get("animations", []),
            "source_zip": pack.get("zip", ""),
        })
        for model in models:
            url = str(model.get("url", ""))
            if url not in allowed_urls or not url.startswith("https://gobkit.com/freebies/") or not url.lower().endswith(".glb"):
                raise RuntimeError(f"Model URL not present verbatim in glbs[]: {url}")
            if not str(model.get("license", "")).startswith("CC0 1.0"):
                raise RuntimeError(f"Model license is not CC0: {model.get('id')}")
            if model.get("format") != "glb":
                raise RuntimeError(f"Unexpected model format: {model.get('id')}")
            selected.append((pack, model, url))

    old_manifest_path = DEST / "ASSET_MANIFEST.json"
    legacy_nature = []
    if old_manifest_path.is_file():
        old = json.loads(old_manifest_path.read_text(encoding="utf-8"))
        legacy_nature = [
            item for item in old.get("assets", [])
            if str(item.get("path", "")).startswith("nature/")
        ]

    old_api_hashes = {}
    if old_manifest_path.is_file():
        old = json.loads(old_manifest_path.read_text(encoding="utf-8"))
        old_api_hashes = {
            item.get("source_url"): item.get("sha256")
            for item in old.get("assets", [])
            if item.get("source_url") and item.get("sha256")
        }

    def download(item):
        pack, model, url = item
        relative = urllib.parse.urlsplit(url).path.split("/freebies/", 1)[1]
        if ".." in Path(relative).parts:
            raise RuntimeError(f"Unsafe asset path: {relative}")
        data = get_bytes(url)
        sha256 = hashlib.sha256(data).hexdigest()
        previous = old_api_hashes.get(url)
        if previous and previous != sha256:
            raise RuntimeError(
                f"Upstream Gobkit file changed for {url}; review the new binary "
                "and update the lock deliberately."
            )
        animation_names = inspect_glb(data)
        declared = model.get("animations", [])
        declared_names = [
            entry if isinstance(entry, str) else entry.get("name", "")
            for entry in declared
        ]
        declared_names = [name for name in declared_names if name]
        missing_clips = [
            name for name in declared_names
            if not any(name.casefold() == actual.casefold() for actual in animation_names)
        ]
        if model.get("rigged") and declared_names and not animation_names:
            raise RuntimeError(f"Rigged model has no GLB animation clips: {model.get('id')}")
        destination = DEST / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
        return {
            "path": relative,
            "model_id": model.get("id", ""),
            "model_name": model.get("name", ""),
            "pack_id": pack.get("id", ""),
            "pack_name": pack.get("name", ""),
            "source_url": url,
            "source_api": API_URL,
            "sha256": sha256,
            "size_bytes": len(data),
            "license": model.get("license", pack.get("license", SOURCE_LICENSE)),
            "rigged": bool(model.get("rigged", False)),
            "fps": model.get("fps", pack.get("fps", 24)),
            "animations": declared,
            "animation_names_in_glb": animation_names,
            "missing_declared_clips": missing_clips,
        }

    DEST.mkdir(parents=True, exist_ok=True)
    print(f"Importing {len(selected)} models from {len(pack_manifest)} CC0 Gobkit packs")
    records = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as pool:
        for index, record in enumerate(pool.map(download, selected), start=1):
            records.append(record)
            if index % 20 == 0 or index == len(selected):
                print(f"[{index}/{len(selected)}] {record['path']} ({record['size_bytes']:,} bytes)")

    legacy_source = {
        "repository": "https://github.com/Ariescar/gobkit-free-assets",
        "commit": "4e73c68fa6e8ca9d948fcc0ce7215c830a022c3b",
        "license": "CC0-1.0",
        "retained_legacy_paths": [item["path"] for item in legacy_nature],
    }
    manifest = {
        "source": API_URL,
        "source_site": SOURCE_REPO,
        "license": SOURCE_LICENSE,
        "api_schema_version": api.get("schemaVersion"),
        "api_total_free_models": api.get("totalFreeModels"),
        "api_snapshot_sha256": hashlib.sha256(raw_manifest).hexdigest(),
        "selected_packs": pack_manifest,
        "legacy_github_nature_source": legacy_source,
        "assets": legacy_nature + records,
        "summary": {
            "selected_api_model_count": len(records),
            "legacy_nature_model_count": len(legacy_nature),
            "total_model_count": len(records) + len(legacy_nature),
            "rigged_model_count": sum(bool(item.get("rigged")) for item in records),
            "animated_model_count": sum(bool(item.get("animation_names_in_glb")) for item in records),
            "total_bytes": sum(item.get("size_bytes", 0) for item in records) + sum(item.get("size_bytes", 0) for item in legacy_nature),
        },
    }
    segment_assets = {}
    for record in records:
        ranged = [
            item for item in record.get("animations", [])
            if isinstance(item, dict) and "from" in item and "to" in item
        ]
        if ranged:
            segment_assets[record["path"]] = {
                "fps": record.get("fps", 24),
                "animations": ranged,
            }
    (DEST / "ANIMATION_SEGMENTS.json").write_text(
        json.dumps({"assets": segment_assets}, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    manifest["animation_segments_file"] = "ANIMATION_SEGMENTS.json"
    old_manifest_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(manifest["summary"], indent=2))
    return 0

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"GOBKIT API IMPORT FAILED: {exc}", file=sys.stderr)
        raise
