# Art Direction & Asset Acquisition Plan

## Target

Build an original fantasy MMORPG presentation strongly inspired by the broad visual language of early World of Warcraft: saturated but earthy colors, exaggerated readable silhouettes, chunky armor, hand-painted-looking surfaces, ornate fantasy frames, bold item rarity colors, and dense readable HUD.

**Legal boundary:** Do not copy, extract, bundle, or redistribute Blizzard/WoW client files, textures, models, icons, fonts, sounds, maps, or UI artwork. A 99% pixel-for-pixel or asset-for-asset match is neither a realistic open-asset target nor a lawful one. Aim for a close genre/style impression using independently licensed assets and original UI composition.

## Current project constraints

- Godot 4.3, Forward+.
- The current world, characters, props and much of the interface are procedurally generated in GDScript.
- Preserve the existing gameplay, save format, quest/inventory/combat logic and controls.
- Keep all work on the `wow` branch. Never modify `main`.
- Existing `godot/assets/kenney/` content is already referenced by the project README; inventory and license-audit those files before adding duplicates.

## Selected asset strategy

Use a curated multi-pack stack rather than one incompatible "all-in-one" pack:

1. **3D humanoids / creatures / animation — Quaternius**
   - Start with the CC0 editions of Animated Characters / Ultimate Modular Men, Ultimate Monsters, and the Universal Animation Library Standard subset.
   - Prefer rigged GLB/glTF assets and confirm each exact pack's license and included animation subset before import.
   - Use for player/NPC/enemy replacement prototypes; do not replace all characters until scale, skeleton and animation retargeting are verified.

2. **Weapons, armor, shields, potions and world props — Quaternius Ultimate RPG Items Bundle**
   - Candidate source for 3D equipment and loot props.
   - Render item thumbnails from the models to keep the inventory art visually consistent.
   - Confirm exact pack license and preserve its license file.

3. **Environment — KayKit + Kenney**
   - KayKit Dungeon Remastered / Adventurers / Forest or Nature packs for modular fantasy locations and readable silhouettes.
   - Kenney Fantasy Town / Survival / existing packs for supporting props and modular pieces.
   - These are stylized low-poly building blocks, not WoW's hand-painted art; unify them with shared lighting, color grading, material roughness and custom textures.

4. **UI panels, slots and controls — Kenney**
   - UI Pack RPG Extension, UI Pack Adventure and existing Kenney UI assets as structural components only.
   - Build an original WoW-inspired layout in Godot: player/target frames, action bars, cast bar, minimap frame, chat tabs, bag slots, character paper-doll and tooltip panels.
   - Do not reproduce Blizzard's exact griffon motifs, frame art, logos or screen layout pixel-for-pixel.

5. **Spell, ability, status and item icons — CC0 icon sources + original renders**
   - First inspect the CC0 "Skill, item and spell icons" OpenGameArt pack.
   - Supplement missing categories with icons rendered from our own 3D item models or original generated icon art.
   - Do not use Game-Icons CC-BY assets unless attribution is added to the asset manifest and in-game credits.

6. **Textures / skies — ambientCG and Poly Haven**
   - Use only CC0 materials/HDRIs where they fit the stylized art direction.
   - Avoid photoreal PBR materials that would clash with the intended painterly fantasy look.

## Implementation phases (in order)

### Phase 0 — Asset audit and visual baseline
- Inventory current asset folders, file sizes, import settings and license files.
- Identify which meshes/textures are generated in scripts and which are already imported.
- Capture a baseline screenshot of the current player, a common enemy, town, dungeon and HUD.
- Do not delete or overwrite current assets.

### Phase 1 — Asset manifest and download
- Download only exact pack editions whose source page and license are verified.
- Store unmodified source packs under `godot/assets/third_party/<publisher>/<pack>/`.
- Keep each pack's original LICENSE / README / attribution files beside it.
- Add `godot/assets/ASSET_MANIFEST.md` with source URL, exact pack name/version, license, author and files actually used.
- Do not commit unused pack contents or huge archives; extract only required files while retaining notices.

### Phase 2 — Visual prototype
- Import one humanoid, one creature, one weapon, one armor piece, one tree/rock set and one UI panel.
- Verify scale, skeleton, materials, draw calls, texture memory and Windows export.
- Build a separate visual test scene; do not alter the playable map yet.

### Phase 3 — Character and creature conversion
- Replace one player/NPC and one common enemy as a vertical slice.
- Retarget idle, walk, run, attack, hit and death animations.
- Confirm hitboxes, navigation, combat ranges, camera framing and save compatibility.
- Only then migrate remaining creatures and bosses in batches.

### Phase 4 — World and environment conversion
- Convert one small outdoor area and one dungeon room first.
- Add modular terrain, vegetation, buildings, rocks, props, sky, fog and lighting.
- Keep navigation/collision and quest locations aligned with existing coordinates.
- Migrate other maps only after the first area passes gameplay testing.

### Phase 5 — Items and inventory art
- Replace placeholder item visuals with consistent model thumbnails / original icons.
- Add quality borders and rarity colors (poor, common, uncommon, rare, epic, legendary).
- Preserve item IDs, stats, drop tables, vendor values and save keys.
- Create missing icons in coherent batches by category: weapons, armor slots, consumables, materials, quest items.

### Phase 6 — WoW-inspired UI redesign
- Rebuild player/target frames, action bar, cast bar, minimap, chat, bags, character panel, quest log, merchant and tooltips.
- Preserve all existing input bindings and keyboard/controller behavior.
- Make UI scale cleanly at 1280x720, 1920x1080 and 4K; test readable text and safe margins.

### Phase 7 — Effects, polish and optimization
- Add original spell particles, impact effects, loot glow, selection rings and ambient effects.
- Add shared palette/material rules and post-processing carefully.
- Profile low/medium/high settings; reduce overdraw and texture memory.
- Run the short Windows build and manual gameplay regression after every migration batch.

## Acceptance gates

A phase is not complete just because files import. It must:
- pass Godot 4.3 import and Windows export;
- preserve movement, combat, quests, loot, inventory, vendors and save/load;
- show no missing resources or script errors;
- have source/license recorded for every third-party asset used;
- remain isolated to the `wow` branch.

## Initial recommendation

The best starting combination is **Quaternius (rigged characters, monsters, RPG items) + KayKit (fantasy environment) + Kenney (UI structure and supporting props) + CC0 icon sources**. No single pack will deliver the requested breadth or WoW-like finish. The closest result will come from consistent art direction, custom material treatment, original item icons and a carefully rebuilt interface—not bulk-copying one game's assets.


## Expansion: rigged CC0 characters, skeletons and modular environments

The asset pipeline now includes pinned KayKit CC0 repositories in addition to
the expanded Quaternius CC0 model selection:

- Adventurers: textured, rigged humanoids with 75 published animations.
- Skeletons: textured, rigged undead characters with 90+ published animations.
- Dungeon: 200+ modular environment pieces using a shared atlas.
- Quaternius additions: medieval buildings, interiors, crops, nature, wildlife,
  fish, dinosaurs, modular dungeon pieces, modular women, knight gear and
  survival props.

A separate visual gallery scene is used to inspect imported assets without
changing the playable scene. The runtime only replaces mobs for which a
reasonably matching model is available (currently spider, skeleton/ashbone,
defias, darkiron, miner and guard). Other species retain their procedural
fallbacks until a species-appropriate model is verified; do not substitute
unrelated models merely to claim 100% coverage.

## Painterly material atlas

The repository now has an original 16-tile brush-painted-style material atlas
generator (albedo, roughness and metallic maps) and a Godot preview scene.
This is procedural project art, not a hand-painted-by-human claim. The next
step is to apply it per material/UV set and tune the surface response in the
gallery before replacing existing model atlases.
