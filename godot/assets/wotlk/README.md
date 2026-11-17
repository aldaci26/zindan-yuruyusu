# WotLK Asset Import Contract

Use Godot 4.3 and import rigged characters, creatures and equipment as glTF 2.0 binary (.glb) scenes.

## Private/local asset folder

Place client-derived or otherwise non-redistributable files only under assets/wotlk_local/. This directory is ignored by Git. It is intentionally excluded from commits and releases. The project can load these local files for private testing, but do not publish them unless the exact asset license permits redistribution.

## First supported creature

Place a properly licensed, rigged wolf model at assets/wotlk_local/creatures/wolf.glb for private/local testing, or assets/wotlk/creatures/wolf.glb only if the model is independently licensed for redistribution.

The existing outdoor wolf spawn loads the local version first, then the public asset version, and finally falls back to the existing procedural wolf. The imported scene should contain:
- a Node3D root;
- one or more MeshInstance3D nodes;
- a Skeleton3D with skin weights;
- an AnimationPlayer with clips whose names include Idle/Stand, Walk/Run, Attack/Bite and optionally Death/Die.

## Equipment

For each equipped item, the runtime looks for equipment/<item_id>.glb in wotlk_local first, then wotlk. Example: equipment/axe_old.glb. Models are attached to matching Skeleton3D bones when available; the current procedural dwarf rig has named fallback sockets. Per-model alignment may need adjustment in the source GLB.

## Other reserved creature paths
- creatures/frost_wolf.glb
- creatures/trogg.glb

## Asset acceptance checklist
1. Source URL and exact repository commit are recorded.
2. File-level license and attribution are recorded; root repository license alone is not enough.
3. The source is not extracted proprietary client data or an unlicensed game rip.
4. Model imports in Godot 4.3 without missing textures/materials.
5. Skeleton, skin weights and animation tracks are present.
6. Model scale, forward axis, root motion and material roughness are checked in the WotLK art lab.
7. The asset is tested in the live game with a procedural fallback still available.

Do not commit Blizzard .m2, .wmo, .blp, .adt files, extracted textures or sounds to this public repository unless the applicable rights expressly permit redistribution.


## Vendored CC0 graphics

The `wow` branch now includes a curated Quaternius CC0-1.0 asset library
under `assets/wotlk/third_party/quaternius/`:

- 401 binary GLB models (approximately 43.69 MiB).
- Animal and creature models, including the real rigged Wolf model.
- Humanoid character models.
- Medieval village props, modular dungeon pieces, weapons, RPG equipment,
  enemies and nature/environment models.
- GLB mesh/material data is imported; **not every pack includes image textures**.
  Quaternius confirms that texture coverage varies by pack, and the Ultimate
  Animated Animal and Ultimate Nature pages mark their models as untextured.
  Texture-map coverage is therefore a separate audit/import task. Each file is
  size-checked and GLB-header-checked during import.
- Full per-file source, source-pack and upstream blob SHA records are in
  `third_party/quaternius/ASSET_MANIFEST.json`.

The runtime wolf scene is available at `assets/wotlk/creatures/wolf.glb`.
The isolated WotLK art lab now loads this imported model first and retains the
procedural wolf as a fallback.

See `QUATERNIUS_ASSET_CREDITS.md` for the exact pinned source revision,
pack-by-pack license evidence and redistribution boundaries. These are
independently licensed fantasy assets, not Blizzard/WoW client files; they
provide a legal visual foundation but do not yet reproduce WoW's proprietary
WotLK models or textures.


## Visual test scene

To preview the imported Wolf model without changing the main game scene, open
`wow_art_lab.tscn` in Godot 4.3 and run the scene. The scene uses the imported
Wolf GLB when present and keeps the procedural fallback if the asset cannot be
loaded. The main project scene remains unchanged.
