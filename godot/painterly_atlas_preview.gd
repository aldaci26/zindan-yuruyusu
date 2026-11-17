extends Node3D
const NAMES:=["Snow stone","Dark stone","Warm stone","Oak wood","Iron","Gold","Leather","Blue cloth","Red cloth","Green cloth","Ice","Moss","Grass","Bone","Fur","Ember"]
func _ready() -> void:
 var ap="res://assets/materials/painterly_fantasy_albedo.png"
 var rp="res://assets/materials/painterly_fantasy_roughness.png"
 var mp="res://assets/materials/painterly_fantasy_metallic.png"
 if not ResourceLoader.exists(ap):
  push_warning("Painterly atlas has not been generated yet.")
  return
 var shader=load("res://assets/materials/painterly_atlas.gdshader") as Shader
 var albedo=load(ap); var rough=load(rp); var metal=load(mp)
 var world:=WorldEnvironment.new()
 var env:=Environment.new()
 env.background_mode=Environment.BG_COLOR
 env.background_color=Color("#25313d")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color=Color("#b8c6d1")
 env.ambient_light_energy=0.8
 world.environment=env
 add_child(world)
 var sun:=DirectionalLight3D.new()
 sun.rotation_degrees=Vector3(-42.0,-32.0,0.0)
 sun.light_energy=1.2
 sun.shadow_enabled=true
 add_child(sun)
 for i in range(16):
  var instance:=MeshInstance3D.new()
  var mesh:=SphereMesh.new()
  mesh.radius=0.9; mesh.height=1.8; mesh.radial_segments=32; mesh.rings=16
  instance.mesh=mesh
  var mat:=ShaderMaterial.new()
  mat.shader=shader
  mat.set_shader_parameter("albedo_atlas",albedo)
  mat.set_shader_parameter("roughness_atlas",rough)
  mat.set_shader_parameter("metallic_atlas",metal)
  mat.set_shader_parameter("tile_index",i)
  instance.material_override=mat
  instance.position=Vector3(float(i%4)*2.5-3.75,1.0,float(i/4)*2.5-3.75)
  add_child(instance)
  var label:=Label3D.new()
  label.text=NAMES[i]; label.position=Vector3(0.0,1.2,0.0)
  label.font_size=28; label.pixel_size=0.006
  label.modulate=Color("#f4ead7"); label.outline_size=6
  label.outline_modulate=Color("#111820")
  instance.add_child(label)
 var camera:=Camera3D.new()
 camera.position=Vector3(0.0,11.0,17.0)
 camera.fov=48.0; camera.current=true
 add_child(camera)
 camera.look_at(Vector3(0.0,0.7,0.0),Vector3.UP)
