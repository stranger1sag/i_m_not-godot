shader_type canvas_item;
uniform float speed = 1.5;
uniform vec4 heal_color:source_color = vec4(0.0,1.0,0.0,1.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv)*2.0;
	float alpha = smoothstep(1.0,0.8,dist);
	alpha *= sin(TIME*speed+dist*10.0)*0.5+0.5;
	vec3 color = vec3(0.0,1.0,0.0);
	COLOR = vec4(color,alpha);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
