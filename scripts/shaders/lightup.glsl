vec4 col;
extern number percentage = 0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	number value = percentage;
	if (value < 0) {value = 0;};
	if (value > 1) {value = 1;};
	
	col = texture2D(texture, texture_coords);
	
	col.r = 1 - (1-col.r) * (1-percentage);
	col.g = 1 - (1-col.g) * (1-percentage);
	col.b = 1 - (1-col.b) * (1-percentage);
	
	if (value > 0.9) {col.a = col.a*10*(1-value);};
	
	return col;
}


