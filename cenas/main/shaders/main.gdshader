shader_type canvas_item;

uniform float threshold : hint_range(0.0, 0.3) = 0.00;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float luminance = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	if (luminance < threshold) {
		tex_color.a = 0.0;
	}
	COLOR = tex_color;
}