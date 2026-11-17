# Quaternius asset provenance and redistribution

The project asset importer vendors only the eight allowlisted packs below from
the pinned Quaternius Showcase revision. The upstream per-pack license table
marks each listed pack as **CC0-1.0**. These files are third-party assets; the
game's own code license does not replace their asset license.

- Creator: Quaternius (Kay Lousberg)
- Source repository: https://github.com/trebeljahr/quaternius-showcase
- Pinned source commit: `0128ca510d653bb04d6d1e4885bd8890b5050b4f`
- Upstream license evidence:
  https://github.com/trebeljahr/quaternius-showcase/blob/0128ca510d653bb04d6d1e4885bd8890b5050b4f/LICENSES.md
- License: CC0 1.0 Universal
- Attribution is not required by CC0; credit is retained here as a courtesy.

| Pack folder | Upstream pack | License evidence |
| --- | --- | --- |
| `animals_pack/` | Ultimate Animated Animal Pack | CC0-1.0 |
| `modular_men/` | Ultimate Modular Men Pack | CC0-1.0 |
| `medieval_village_pack/` | Medieval Village Pack | CC0-1.0 |
| `medieval_weapons_pack/` | Modular Weapons Pack | CC0-1.0 |
| `modular_dungeon_1/` | Modular Dungeons Pack | CC0-1.0 |
| `easy_enemies_pack/` | Easy Enemy Pack | CC0-1.0 |
| `nature_pack/` | Ultimate Nature Pack | CC0-1.0 |
| `rpg_items_pack/` | Ultimate RPG Pack | CC0-1.0 |

The importer also creates `assets/wotlk/creatures/wolf.glb` as a runtime alias
of `third_party/quaternius/animals_pack/Wolf.glb`.

## Important art and license boundaries

- These are independent low-poly fantasy/game assets, **not World of Warcraft
  client assets** and not a recreation of Blizzard's proprietary models.
- The packs are selected because their individual source pages are listed as
  CC0-1.0 in the pinned upstream license manifest.
- Newer Quaternius releases may use the Quaternius Asset License (QAL), which
  does not permit redistributing the raw asset files. Do not add a QAL pack to
  this importer.
- Do not add extracted Blizzard `.m2`, `.wmo`, `.blp`, `.adt`, sounds,
  textures, maps, or other client-derived files to this public repository.
- Every additional third-party pack must be checked against its own source
  page and exact license before it is allowlisted.


## Texture coverage note

CC0 status permits redistribution of the listed model files, but it does not
mean every model includes image texture maps. Quaternius' FAQ says texture
coverage varies by pack; the Ultimate Animated Animal and Ultimate Nature
pages mark those packs as untextured. The imported GLBs retain their supplied
mesh/material data, but the project still needs a separate, file-level texture
audit and a consistent texture set before the art pass can be called complete.
