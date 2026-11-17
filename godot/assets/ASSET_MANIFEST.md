# Project asset manifest

Per-file machine-readable provenance is stored beside the imported libraries.

## Quaternius — CC0-1.0

- Source: https://github.com/trebeljahr/quaternius-showcase
- Pinned revision: `0128ca510d653bb04d6d1e4885bd8890b5050b4f`
- License evidence: the pinned `LICENSES.md` lists each pack's own source page
  and CC0-1.0 status. The showcase MIT license covers code only.
- Packs: Ultimate Animated Animals, Ultimate Modular Men, Medieval Village,
  Modular Weapons, Modular Dungeons, Easy Enemies, Ultimate Nature, Ultimate
  RPG Items, Buildings, Ultimate Buildings, Ultimate Crops, Animated Cute Fish,
  Animated Dinosaurs, Animated Fish, Ultimate House Interior, Medieval Dungeon,
  Modular Medieval Buildings, Ultimate Modular Women, Ultimate Fantasy RTS,
  Simple Nature, Animated Knight, Modular Streets and Survival.
- Destination: `assets/wotlk/third_party/quaternius/`
- QAL releases are excluded from raw public redistribution.

## KayKit — CC0-1.0

Each selected repository's README and LICENSE.txt explicitly state CC0 1.0.

| Pack | Repository commit | Content |
| --- | --- | --- |
| Adventurers | `KayKit-Character-Pack-Adventures-1.0` @ `672074b73ba276876a19e8816ecdc5241817ab47` | Rigged/animated textured humanoids, 75 animations, accessories and atlas |
| Skeletons | `KayKit-Character-Pack-Skeletons-1.0` @ `15b62b9bad122f72926c10fb14d622c73819fa54` | Rigged/animated skeletons, 90+ animations, accessories and atlas |
| Dungeon | `KayKit-Dungeon-Remastered-1.0` @ `b0ca9bd96a8072ab36a3a5464f00ed1e06a16d07` | 200+ modular dungeon props and shared atlas |

Destination: `assets/third_party/kaykit/`. The importer excludes FBX/OBJ
duplicates and screenshots, validates GLB animation metadata and checks
external glTF buffer/image references.

## Original project-generated painterly-style maps

- Generator: `tools/generate_painterly_atlas.py`
- Outputs: `materials/painterly_fantasy_albedo.png`,
  `painterly_fantasy_roughness.png`, `painterly_fantasy_metallic.png`
- 1024×1024, 4×4 grid, 16 material tiles.
- Procedural brush-stroke style original project art; not extracted from WoW
  and not described as human hand-painted.
- Preview: `painterly_atlas_preview.tscn`.

## Future CC0 material sources

- Poly Haven license: https://polyhaven.com/license
- ambientCG license: https://docs.ambientcg.com/license/

Both publish CC0 assets. Prefer stylized/painterly-compatible materials over
photoreal scans so they do not clash with the intended art direction.

## Engine decision and legal boundary

Keep Godot 4.3. It already supports glTF/GLB, Skeleton3D, AnimationPlayer,
shader materials and Windows CI. Blender is the free conversion/retargeting
tool. Do not publish Blizzard client-derived M2/WMO/BLP/ADT, textures, maps,
icons, UI, audio or fonts.


## Gobkit — CC0-1.0

- Source: https://github.com/Ariescar/gobkit-free-assets
- Pinned revision: `4e73c68fa6e8ca9d948fcc0ce7215c830a022c3b`
- The repository README and LICENSE explicitly identify CC0 1.0 Universal.
- Imported: 8 minions, 10 animals and 41 nature/environment GLBs, plus
  README/LICENSE. Textures are baked into the GLBs.
- The README documents a single baked animation track segmented into
  idle/attack/dead (and walk for animals) at 24 fps. Segment metadata is
  recorded in the generated manifest; runtime subclip playback remains a
  separate integration task.
- Destination: `assets/third_party/gobkit/`

## Additional KayKit CC0 packs

- Medieval Hexagon: 200+ medieval hex tiles, buildings, nature props and a
  shared atlas; pinned to `84fa4e91af6a88989be7c99e0891cede11f2ca38`.
- City Builder Bits: town props and buildings; pinned to
  `63976910ca04d16f0fc531b9c614244be8128713`.
- Halloween Bits: cemetery and spooky environment props; pinned to
  `6dc69bf6b2fa766a985754f35ec6a0324090e6c6`.

Each pack's README and LICENSE.txt state CC0 1.0 Universal. Their glTF files,
external buffers and referenced texture maps are retained with original paths.
