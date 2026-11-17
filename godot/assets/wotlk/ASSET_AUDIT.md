# Six-repository asset audit — initial findings

Scope: the six repositories previously selected for this project. This is a source/repository-level audit, not a claim that every binary object in every Git tree has been exhaustively enumerated. GitHub code search does not index binary assets; the available connector does not expose recursive binary-tree enumeration. Therefore no binary asset is marked cleared without file-level evidence.

| Repository | What it provides for this project | Rigged, redistributable WoW character/creature assets verified |
|---|---|---|
| TrinityCore/TrinityCore | Server core, client-data extractors and data definitions | None verified. Extractors consume a separately obtained WoW client installation. |
| azerothcore/azerothcore-wotlk | WotLK server core, tools and database content | None verified. Client maps/models/textures are not granted by the server source license. |
| TrinityCore/CypherCore | C# server emulator and extractor-related tooling | None verified. Project code license does not relicense Blizzard client data. |
| Kelsidavis/wowee | Source code for an asset builder that extracts a user's legally obtained client into a loose-file Data tree; also contains experimental M2/WMO conversion tools | No redistribution-cleared model pack verified. Its README explicitly says the repository contains no Blizzard assets/data and requires the user to supply their own. Its code license has an additional restriction on commercial game use without written permission; original music is separately reserved. We are not copying its music or code. |
| DMCK96/azeroth-world-editor | World editor that reads the user's local client files | None verified. Its screenshots/editor output are not a redistributable asset pack. |
| bewarellamas/quest-customquestpack | Quest/database content | No 3D character, creature, environment or animation pack verified. |

## Decision

The repositories are useful for understanding extraction, metadata and world-data pipelines, but they are not a verified source of ready-to-redistribute WotLK character/creature art. The project must not copy extracted client assets into this public GitHub repository based only on the repositories' open-source licenses.

The import/runtime layer is now prepared for separately licensed GLB assets. When a source file is verified, add its exact source URL, commit, file-level license, attribution and conversion notes here before importing it.


## Extraction compatibility note

TrinityCore's server setup documentation states that the 3.3.5 branch requires the WotLK 3.3.5a client and that TrinityCore does not provide a client download. This supports treating extracted client data as a separate, user-supplied input rather than as an open-source repository asset.


## Follow-up: independently licensed model library added

After the initial six-repository audit, a separate asset source was verified and
imported: a curated selection from the Quaternius Showcase mirror, pinned to
commit `0128ca510d653bb04d6d1e4885bd8890b5050b4f`. Its per-pack
`LICENSES.md` maps each selected pack to an individual Quaternius source page
that identifies CC0-1.0. We imported 401 GLB files (43.69 MiB) from these packs:

- Ultimate Animated Animal Pack
- Ultimate Modular Men Pack
- Medieval Village Pack
- Modular Weapons Pack
- Modular Dungeons Pack
- Easy Enemy Pack
- Ultimate Nature Pack
- Ultimate RPG Pack

The GLBs contain the model geometry and available material data. Texture
coverage is pack-dependent: the official Ultimate Animated Animal and Ultimate
Nature pages mark their models as untextured, so this import is **not** claimed
to be a complete texture library. The runtime Wolf alias at `assets/wotlk/creatures/wolf.glb` now points to the
imported Quaternius Wolf model, and the isolated WotLK visual lab uses this
model first with the procedural wolf retained as fallback.

This resolves the lack of **redistribution-cleared independent fantasy assets**,
not the lack of authentic Blizzard WotLK assets. The imported models are
Quaternius art and are not represented as WoW client models or textures.
Full per-file paths, upstream blob SHAs, sizes, pack pages and license labels
are recorded in `third_party/quaternius/ASSET_MANIFEST.json`; attribution and
license boundaries are in `QUATERNIUS_ASSET_CREDITS.md`.


### Texture coverage caveat

Quaternius' FAQ states that texture coverage depends on the pack. The official
Ultimate Animated Animal and Ultimate Nature pack pages mark their models as
untextured. The current import therefore provides a real mesh/animation/prop
library and whatever materials are present in each GLB, but it does not satisfy
the separate requirement for a complete, consistent set of image texture maps.
Do not describe all 401 models as textured. A dedicated texture pass must
source CC0 textures (or original hand-painted textures) and record each
texture's provenance independently.
