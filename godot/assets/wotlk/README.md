# WotLK Asset Import Contract

Use Godot 4.3 and import rigged characters, creatures and equipment as glTF 2.0 binary (.glb) scenes. This folder intentionally contains no extracted Blizzard client files and no unverified third-party models.

## First supported creature

Place a properly licensed, rigged wolf model at creatures/wolf.glb.

The existing outdoor wolf spawn will automatically load it when present. Otherwise it uses the existing procedural wolf model. The imported scene should contain:
- a Node3D root;
- one or more MeshInstance3D nodes;
- a Skeleton3D with skin weights;
- an AnimationPlayer with clips whose names include Idle/Stand, Walk/Run, Attack/Bite and optionally Death/Die.

The runtime animation mapper is case-insensitive and accepts common clip-name variants.

## Other reserved paths
- creatures/frost_wolf.glb
- creatures/trogg.glb

## Equipment attachment

Use WowAssetRuntime.attach_equipment() to attach a PackedScene to a named Skeleton3D bone (preferred) or to the existing procedural dwarf rig as a fallback. Supply candidate bone names for the source rig, e.g. ["Hand.R", "hand_r", "RightHand"]. Validate the actual bone names in the imported asset before shipping.

## Asset acceptance checklist
1. Source URL and exact repository commit are recorded.
2. File-level license and attribution are recorded; root repository license alone is not enough.
3. The source is not extracted proprietary client data or an unlicensed game rip.
4. Model imports in Godot 4.3 without missing textures/materials.
5. Skeleton, skin weights and animation tracks are present.
6. Model scale, forward axis, root motion and material roughness are checked in the WotLK art lab.
7. The asset is tested in the live game with a procedural fallback still available.

Do not commit Blizzard .m2, .wmo, .blp, .adt files, extracted textures or sounds to this public repository unless the applicable rights expressly permit redistribution.
