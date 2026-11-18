# WoW-inspired MMORPG foundation (Godot 4.3)

This folder contains an isolated, data-driven foundation for gradually expanding Zindan Yürüyüşü. It does not replace or modify the existing single-player gameplay systems.

## Included

- `data/item_definition.gd`: item identity, quality, stack, equipment slot and stats.
- `data/quest_definition.gd`: quest prerequisites, objectives and rewards.
- `data/creature_definition.gd`: creature stats, combat ranges and loot-table data.
- `data/spell_definition.gd`: spell costs, cast/cooldown and effect data.
- `services/quest_log.gd`: quest registration, progress, completion, turn-in and serializable quest state.
- `services/inventory_service.gd`: stack-aware inventory operations and serializable state.

## Integration status

`mmorpg_bridge.gd` (`MMORPGBridge`) connects these services to the game without replacing anything:

- At startup it builds item, quest, creature and spell definitions from the game's own data (`Items.db()`, `QUESTS`, the `*_MTYPES` tables, `HudScript.ABIL`) and validates them; problems are logged with `push_warning("mmorpg: ...")`.
- `main.gd` mirrors quest accept, kill progress and turn-in into `MMORPGQuestLog`, and mirrors the bag and money into `MMORPGInventoryService` on every inventory change. After loading a save the mirror is rebuilt from the saved quest state.
- The game's own quest, inventory and save systems remain the source of truth. The save format is unchanged.

Equipment stats, spell execution, creature AI and loot are still driven by the existing game code.

## Architecture and licensing rules

- Godot 4.3 and GDScript only; no .NET dependency.
- Keep the game client independent from TrinityCore/AzerothCore. Those projects are architectural references, not runtime dependencies.
- Preserve the existing save format until a migration is implemented and tested.
- Do not import Blizzard client files, leaked source code, copyrighted textures, models, sounds, maps or extracted game data. Non-commercial intent does not grant redistribution rights.
- Use original content or assets whose licenses explicitly permit the intended use.

## Next integration steps

1. Add adapters around the existing quest and inventory behavior without replacing them.
2. Add save-data migration and compatibility checks.
3. Integrate equipment stats and spell execution incrementally.
4. Add creature AI, loot resolution and world interactions as separate services.
5. Consider multiplayer/server authority only after the single-player systems are stable.
