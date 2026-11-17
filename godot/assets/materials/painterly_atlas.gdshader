shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform sampler2D albedo_atlas : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D roughness_atlas : filter_linear_mipmap, repeat_disable;
uniform sampler2D metallic_atlas : filter_linear_mipmap, repeat_disable;
uniform int tile_index : hint_range(0, 15) = 0;
void fragment() {
 vec2 tile=vec2(float(tile_index%4),float(tile_index/4));
 vec2 local_uv=clamp(UV,vec2(0.018),vec2(0.982));
 vec2 atlas_uv=tile*0.25+local_uv*0.25;
 ALBEDO=texture(albedo_atlas,atlas_uv).rgb;
 ROUGHNESS=texture(roughness_atlas,atlas_uv).r;
 METALLIC=texture(metallic_atlas,atlas_uv).r;
}
