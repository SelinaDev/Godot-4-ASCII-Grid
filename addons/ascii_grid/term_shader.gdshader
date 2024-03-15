shader_type canvas_item;

uniform sampler2D glyphs;
uniform sampler2D character_grid;
uniform sampler2D fg_color;
uniform sampler2D bg_color;
	
const vec2 tile_size = vec2(1.0 / 8.0, 1.0 / 16.0);
uniform vec2 grid_size;
uniform int chars_per_line = 16;

void fragment() {
	vec2 cell_coord = floor(UV * grid_size) + vec2(0.5);
	vec2 cell_uv = fract(UV * grid_size);
	int char_code = int((texture(character_grid, cell_coord / grid_size).r) * 256.0);
	vec2 glyph_pixel_pos = (vec2(
		float(char_code % chars_per_line),
		float(char_code / chars_per_line)
	) + cell_uv) / vec2(float(chars_per_line), float(256 / chars_per_line));
	vec3 fg_color_pixel = texture(fg_color, cell_coord / grid_size).rgb;
	vec3 bg_color_pixel = texture(bg_color, cell_coord / grid_size).rgb;
	vec3 char_pixel = texture(glyphs, glyph_pixel_pos, 0.0).rgb;
	COLOR.rgb = mix(bg_color_pixel, fg_color_pixel, char_pixel.r);
}