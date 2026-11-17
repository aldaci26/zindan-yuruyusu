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

These services are intentionally isolated. The current playable game still uses its existing quest, inventory, combat and save systems. They have not yet been connected to the main scene, and this test build should be treated as a playable baseline rather than a completed MMORPG conversion.

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
