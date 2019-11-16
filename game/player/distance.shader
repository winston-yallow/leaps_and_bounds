shader_type spatial;
render_mode depth_draw_always;

void fragment() {
    
    // alpha based on depth
    float bg_depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    vec4 bg_upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, bg_depth * 2.0 - 1.0, 1.0);
    vec3 bg_pixel_position = bg_upos.xyz / bg_upos.w;
    float fg_depth = FRAGCOORD.z;
    vec4 fg_upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, fg_depth * 2.0 - 1.0, 1.0);
    vec3 fg_pixel_position = fg_upos.xyz / fg_upos.w;
    float depth_dist = distance(bg_pixel_position, fg_pixel_position);
    ALPHA = clamp(depth_dist * 0.75, 0.0, 1.0);
    
    // blurred grayscale
    vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 2.0);
    ALBEDO.rgb = vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114)));
    
}