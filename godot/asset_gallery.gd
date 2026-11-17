extends Node3D
## Standalone inspection gallery for imported CC0 assets; main scene is untouched.

const ENTRIES := [
 {"label":"KayKit Knight","path":"res://assets/third_party/kaykit/adventurers/Characters/gltf/Knight.glb","scale":1.0},
 {"label":"KayKit Barbarian","path":"res://assets/third_party/kaykit/adventurers/Characters/gltf/Barbarian.glb","scale":1.0},
 {"label":"KayKit Mage","path":"res://assets/third_party/kaykit/adventurers/Characters/gltf/Mage.glb","scale":1.0},
 {"label":"KayKit Rogue","path":"res://assets/third_party/kaykit/adventurers/Characters/gltf/Rogue_Hooded.glb","scale":1.0},
 {"label":"Skeleton Warrior","path":"res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Warrior.glb","scale":1.0},
 {"label":"Skeleton Mage","path":"res://assets/third_party/kaykit/skeletons/Characters/gltf/Skeleton_Mage.glb","scale":1.0},
 {"label":"Quaternius Spider","path":"res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Spider.glb","scale":1.4},
 {"label":"Quaternius Rat","path":"res://assets/wotlk/third_party/quaternius/easy_enemies_pack/Rat.glb","scale":1.4},
 {"label":"Quaternius Wolf","path":"res://assets/wotlk/third_party/quaternius/animals_pack/Wolf.glb","scale":1.2},
 {"label":"Quaternius Fox","path":"res://assets/wotlk/third_party/quaternius/animals_pack/Fox.glb","scale":1.2},
 {"label":"Quaternius Stag","path":"res://assets/wotlk/third_party/quaternius/animals_pack/Stag.glb","scale":1.2},
 {"label":"RPG Armor","path":"res://assets/wotlk/third_party/quaternius/rpg_items_pack/Armor_Metal.glb","scale":1.6},
 {"label":"Knight Helmet","path":"res://assets/wotlk/third_party/quaternius/single_knight_pack/Helmet2.glb","scale":1.8},
 {"label":"Double Axe","path":"res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Axe_Double.glb","scale":1.8},
 {"label":"Heater Shield","path":"res://assets/wotlk/third_party/quaternius/medieval_weapons_pack/Shield_Heater.glb","scale":1.8},
 {"label":"KayKit Dungeon Chest","path":"res://assets/third_party/kaykit/dungeon/Assets/gltf/chest.glb","scale":1.8},
 {"label":"Gobkit Minion A","path":"res://assets/third_party/gobkit/minion/minion-a01.glb","scale":1.0},
 {"label":"Gobkit Minion C","path":"res://assets/third_party/gobkit/minion/minion-c01.glb","scale":1.0},
 {"label":"Gobkit Bat","path":"res://assets/third_party/gobkit/animal/Bat.glb","scale":1.4},
 {"label":"Gobkit Hippo","path":"res://assets/third_party/gobkit/animal/Hippo.glb","scale":1.2},
 {"label":"Gobkit Shark","path":"res://assets/third_party/gobkit/animal/Shark.glb","scale":1.2},
 {"label":"Medieval Hex Blacksmith","path":"res://assets/third_party/kaykit/medieval_hexagon/Assets/gltf/buildings/blue/building_blacksmith_blue.gltf","scale":1.2},
 {"label":"City Builder House","path":"res://assets/third_party/kaykit/city_builder/Assets/gltf/building_A.gltf","scale":1.2},
 {"label":"Halloween Arch","path":"res://assets/third_party/kaykit/halloween_bits/Assets/gltf/arch.gltf","scale":1.2},
]
func _ready() -> void:
 _build_environment()
 _build_ground()
 _build_camera()
 _build_gallery()
func _build_environment() -> void:
 var world:=WorldEnvironment.new()
 var env:=Environment.new()
 env.background_mode=Environment.BG_COLOR
 env.background_color=Color("#71879a")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color("#b5c6d2")
 env.ambient_light_energy=0.8
 env.tonemap_mode=Environment.TONE_MAPPER_FILMIC
 env.fog_enabled=true
 env.fog_light_color=Color("#9eafbb")
 env.fog_density=0.002
 world.environment=env
 add_child(world)
 var sun:=DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-48.0,-28.0,0.0)
 sun.light_color=Color("#ffe4c7")
 sun.light_energy=1.2
 sun.shadow_enabled=true
 add_child(sun)
func _build_ground() -> void:
 var ground:=MeshInstance3D.new()
 var mesh:=PlaneMesh.new()
 mesh.size=Vector2(46.0,46.0)
 ground.mesh=mesh
 var mat:=StandardMaterial3D.new()
 mat.albedo_color=Color("#56616a")
 mat.roughness=0.96
 ground.material_override=mat
 ground.position.y=-0.04
 add_child(ground)
func _build_camera() -> void:
 var camera:=Camera3D.new()
 camera.position=Vector3(0.0,17.0,34.0)
 camera.fov=55.0
 camera.current=true
 add_child(camera)
 camera.look_at(Vector3(0.0,1.0,4.0),Vector3.UP)
func _build_gallery() -> void:
 for index in range(ENTRIES.size()):
  var entry:Dictionary=ENTRIES[index]
  var path:=str(entry["path"])
  if not ResourceLoader.exists(path):
   push_warning("Gallery asset not imported yet: "+path)
   continue
  var packed:=load(path) as PackedScene
  if packed==null:
   push_warning("Gallery resource is not a PackedScene: "+path)
   continue
  var instance:=packed.instantiate() as Node3D
  if instance==null:
   push_warning("Gallery root is not Node3D: "+path)
   continue
  var column:=index%4
  var row:=index/4
  instance.position=Vector3(float(column)*4.5-6.75,0.0,float(row)*4.5-6.75)
  instance.scale=Vector3.ONE*float(entry.get("scale",1.0))
  add_child(instance)
  _play_idle(instance)
  var label:=Label3D.new()
  label.text=str(entry["label"])
  label.position=Vector3(0.0,2.8,0.0)
  label.font_size=36
  label.pixel_size=0.006
  label.modulate=Color("#f4ead7")
  label.outline_size=8
  label.outline_modulate=Color("#1c252d")
  instance.add_child(label)

func _play_idle(root: Node3D) -> void:
 for node in root.find_children("*","AnimationPlayer",true,false):
  var player:=node as AnimationPlayer
  if player==null:
   continue
  for animation_name in player.get_animation_list():
   var key:=animation_name.to_lower()
   if key.contains("idle") or key.contains("stand"):
    player.play(animation_name)
    return
