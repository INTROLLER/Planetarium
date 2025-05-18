shader_type canvas_item;

uniform float damage_flash : hint_range(0.0, 1.0); // Set this from code

void fragment() {
    vec3 base_color = texture(TEXTURE, UV).rgb;
    vec3 flash_color = vec3(1.0, 0.0, 0.0); // Pure red

    // Blend red into the base color
    COLOR.rgb = mix(base_color, flash_color, damage_flash);
}