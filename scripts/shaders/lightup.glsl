vec4 col;
extern number percentage = 0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	col = texture2D(texture, texture_coords);
	
	col.r = 1 - (1-col.r) * (1-percentage);
	col.g = 1 - (1-col.g) * (1-percentage);
	col.b = 1 - (1-col.b) * (1-percentage);
	
	return col;
}


