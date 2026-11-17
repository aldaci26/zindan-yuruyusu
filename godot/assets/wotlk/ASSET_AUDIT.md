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


## Expanded model/animation audit

Pinned CC0 KayKit sources were added after checking their own README and
LICENSE.txt files. The Adventurers repository states CC0 1.0 Universal and
describes four fully rigged/animated textured characters with 75 animations.
The Skeletons repository states CC0 1.0 Universal and describes four
fully rigged/animated textured skeletons with 90+ animations. The Dungeon
repository states CC0 1.0 Universal and describes 200+ modular dungeon assets.

The import script pins exact commit SHAs, keeps the source notices, verifies
GLB headers, parses GLB animation names, validates external glTF buffer/image
references, and records SHA-256 plus upstream blob SHA in the KayKit manifest.
FBX/OBJ duplicates and sample renders are not imported.

The Quaternius allowlist now includes additional CC0 medieval architecture,
interiors, crops, wildlife, fish, dinosaurs, dungeon, knight, survival and
environment packs from the same pinned showcase revision. The per-pack
license evidence is in its pinned LICENSES.md; the showcase MIT license is
not treated as the model license.

### Runtime integration status

The runtime now attempts imported models for spider, skeleton, ashbone,
defias, darkiron, miner and guard. It keeps the procedural fallback for
species without a good matching model. It also maps many existing weapon,
shield, helmet and shoulder item IDs to imported Quaternius meshes. These
attachments still require visual alignment checks in Godot; the gallery and
Windows CI import are the acceptance path.

### Texture status

KayKit's character and dungeon packs include their own shared gradient atlases.
The project also generates an original 16-material painterly-style albedo,
roughness and metallic atlas. The latter is procedural brush-stroke art, not
human hand-painted artwork. It is not yet automatically applied to every
model: each model's UV/material slots must be checked before replacement.


## Further CC0 source expansion

Additional KayKit repositories were checked at their pinned revisions. Their
own READMEs and LICENSE.txt files state CC0 1.0 Universal:

- Medieval Hexagon Pack — `84fa4e91af6a88989be7c99e0891cede11f2ca38`.
- City Builder Bits — `63976910ca04d16f0fc531b9c614244be8128713`.
- Halloween Bits — `6dc69bf6b2fa766a985754f35ec6a0324090e6c6`.

Gobkit's repository README and LICENSE state CC0 1.0 Universal. Its pinned
revision `4e73c68fa6e8ca9d948fcc0ce7215c830a022c3b` contains 8 rigged minions,
10 rigged animals and 41 nature/environment GLBs. The README documents a
single baked animation track segmented by frame ranges; these segments are
recorded in the manifest but are not yet split into runtime clips.

The visual gallery includes representative Gobkit creatures and KayKit
environment props. They are not assigned to unrelated mob species until their
silhouettes and animations are reviewed in Godot.
