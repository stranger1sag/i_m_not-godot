shader_type canvas_item;

uniform sampler2D noise_texture; // 噪声纹理
uniform float dissolve_threshold : hint_range(0.0, 1.0); // 控制熔解程度
uniform vec4 dissolve_color : source_color = vec4(1,0,0,1); // 融毁时的高光颜色

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float noise_value = texture(noise_texture, UV).r; // 取噪声纹理的红色通道

    // 计算溶解程度
    float alpha = smoothstep(dissolve_threshold - 0.05, dissolve_threshold, noise_value);

    // 颜色混合效果 
	vec3 final_color = tex_color.rgb;
    final_color = mix(final_color, tex_color.rgb, alpha);

    COLOR *= vec4(final_color, tex_color.a * alpha);
}