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
