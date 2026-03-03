shader_type canvas_item;

uniform float tear_strength : hint_range(0.0, 20.0) = 8.0;
uniform float tear_speed : hint_range(0.0, 10.0) = 3.0;

void fragment() {
	float y = UV.y;
	float offset = sin(y * 50.0 + TIME * tear_speed) * tear_strength / 1000.0;
	float tear_mask = step(0.97, fract(y * 12.0 + TIME * 0.5));
	vec2 uv = UV + vec2(offset * tear_mask, 0.0);
	uv = clamp(uv, vec2(0.0), vec2(1.0));
	COLOR = texture(TEXTURE, uv);
}
