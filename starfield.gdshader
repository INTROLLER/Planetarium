shader_type canvas_item;

uniform vec2 resolution = vec2(400, 225);
uniform sampler2D noise_texture : filter_nearest, repeat_enable;
uniform float density : hint_range(1.0, 100.0, 0.1) = 20.0;
uniform float blink_speed : hint_range(0.1, 10.0) = 2.0;

vec3 rgb_to_normalized(vec3 rgb) {
    return rgb / 255.0;
}

void fragment() {
	vec3 color = vec3(3, 9, 17);
	vec2 uv = UV;
	uv.x *= resolution.x / resolution.y;

	// Noise for both position and phase randomness
	float noise = texture(noise_texture, uv).r;

	// Determine if it's a star
	float star = step(0.2, pow(noise, density));

	// Smooth blinking with time offset per star
	float phase = TIME * blink_speed + noise * 100.0;
	float blink = 0.5 + 0.5 * sin(phase);

	// Optional: smoothstep to make blinking smoother near edges
	blink = smoothstep(0.0, 1.0, blink);

	// Combine star presence with blinking
	float result = star * blink;

	vec3 background_color = rgb_to_normalized(color); // soft blueish background
	vec3 star_color = vec3(result);
	vec3 final_color = mix(background_color, star_color, result);
	COLOR = vec4(final_color, 1.0);
}