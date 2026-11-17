# WoW-inspired MMORPG foundation (Godot 4.3)

This folder is an isolated, data-driven foundation for expanding Zindan Yürüyüşü toward a deeper MMORPG-style RPG. It does not replace the existing game systems yet. The current game remains playable while new domain services are tested independently.

## Design rules

- Godot 4.3 and GDScript only; no .NET dependency.
- Keep the game client independent from TrinityCore/AzerothCore. Those projects are architectural references, not runtime dependencies.
- Keep definitions separate from behavior: items, quests, creatures and spells are Resources; services operate on those definitions.
- Preserve the existing save format and existing main.gd behavior until a migration is explicitly implemented and tested.
- Do not import Blizzard client files, leaked source code, copyrighted textures, models, sounds, maps or extracted game data into this repository. Non-commercial intent does not itself grant redistribution rights.
- Use original content, CC0/CC-BY assets with their required attribution, or assets whose license explicitly permits the intended use.

## Included in this first foundation

- data/item_definition.gd: item identity, quality, stack, equipment slot and stat data.
- data/quest_definition.gd: quest prerequisites, objectives and reward data.
- data/creature_definition.gd: creature stats, combat ranges and loot-table data.
- data/spell_definition.gd: spell costs, cast/cooldown and effect data.
- services/quest_log.gd: accept, progress, completion, turn-in and serializable quest state.
- services/inventory_service.gd: stack-aware inventory operations and serializable state.
- tests/test_core.gd: headless smoke tests for the new services.

## Running the tests

From the repository root, run:

    godot --headless --path godot --editor --quit
    godot --headless --path godot --script res://mmorpg/tests/test_core.gd

The first command lets Godot scan/import the project and register global script classes. The second runs the focused service tests.

## Integration plan

1. Validate these services independently.
2. Add adapters around existing quest and inventory behavior; do not delete or replace the current implementation in one pass.
3. Migrate one feature at a time with save-data migration and regression tests.
4. Add creature AI, spell execution, loot resolution, equipment stats and world interaction as separate services.
5. Only then consider multiplayer/server authority; the current project is a single-player game.

## Data model notes

Quest objective dictionaries use:
- id: stable objective key within the quest.
- type: event type such as kill, collect, interact or explore.
- target_id: stable game-defined target identifier.
- required_count: positive integer.
- label: optional player-facing text.

Quest reward dictionaries are intentionally generic. Suggested keys are type, id, count, amount and label; the game decides how to apply them.

Creature loot entries and spell effects are also data descriptions, not executable scripts. Runtime services should validate and interpret them rather than evaluating arbitrary code from data files.
