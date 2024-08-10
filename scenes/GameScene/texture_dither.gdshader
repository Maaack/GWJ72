/* 
This shader is under MIT license.
*/

shader_type canvas_item;

uniform sampler2D dither_texture : repeat_enable;
uniform sampler2D color_palette;

uniform int bit_depth = 32;
uniform int pixel_size = 1;
uniform float contrast = 1.0;
uniform float offset = 0.0;
uniform bool active = true;

vec3 texture_dither(in sampler2D _texture, in vec2 _uv, in vec2 _texture_pixel_size)
{
		// sample the screen texture at the desired output resolution (according to pixel_size)
	// this will effectively pixelate the resulting output
	vec2 screen_size = vec2(textureSize(_texture, 0)) / float(pixel_size);
	vec2 screen_sample_uv = floor(_uv * screen_size) / screen_size;
	vec3 screen_color = texture(_texture, _uv + _texture_pixel_size / 2.0).rgb;
	
	// calculate pixel luminosity (https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color)
	float lum = (screen_color.r * 0.299) + (screen_color.g * 0.587) + (screen_color.b * 0.114);
	lum = (((lum - 0.5) + offset) * contrast) + 0.5;
	lum = clamp(lum, 0.0, 1.0);
	
	// reduce luminosity bit depth to give a more banded visual if desired
	float bits = float(bit_depth);
	lum = floor(lum * bits) / bits;
	
	ivec2 color_size = textureSize(color_palette, 0);
	float color_count = float(color_size.x);
	float color_texel_size = 1.0 / color_count;

	// to support multicolour palettes, we want to dither between the two colours on the palette
	// which are adjacent to the current pixel luminosity.
	float lum_floor = floor(max(lum - 0.001, 0) * (color_count - 1.0));
	float lum_lower_x = lum_floor * color_texel_size + color_texel_size / 2.0;
	float lum_upper_x = (lum_floor + 1.0) * color_texel_size + color_texel_size / 2.0;
	
	// map the dither texture onto the screen. there are better ways of doing this that makes the dither pattern 'stick'
	// with objects in the 3D world, instead of being mapped onto the screen. see lucas pope's details posts on how he 
	// achieved this in Obra Dinn: https://forums.tigsource.com/index.php?topic=40832.msg1363742#msg1363742
	ivec2 noise_size = textureSize(dither_texture, 0);
	vec2 noise_pixel_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
	vec2 noise_uv = (screen_sample_uv * noise_pixel_size * screen_size);
	float threshold = texture(dither_texture, noise_uv).r;
	
	// adjust the dither slightly so min and max aren't quite at 0.0 and 1.0
	// otherwise we wouldn't get fullly dark and fully light dither patterns at lum 0.0 and 1.0
	threshold = threshold * 0.99 + 0.005;

	float ramp_val = lum < threshold ? 0.0f : 1.0f;
	// sample at the lower bound colour if ramp_val is 0.0, upper bound colour if 1.0
	vec2 color_sample_uv = vec2(mix(lum_lower_x, lum_upper_x, ramp_val), 0.5);
	return texture(color_palette, color_sample_uv).rgb;
}

void fragment() 
{
	if (active) {
		COLOR.rgb = texture_dither(TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	}
}