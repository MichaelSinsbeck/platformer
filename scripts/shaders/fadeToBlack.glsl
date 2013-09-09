vec4 col;
extern number percentage;
number bright;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	col = texture2D(texture, texture_coords);
	if (percentage < 50)
	{
		bright = 2-percentage/12.5;
	} else {
		bright = (percentage-75)/25;
	}
	
	bright = min(bright,1);
	
	bright = - bright*bright + 2*bright;
	
	return vec4(col.r*bright, col.g*bright, col.b*bright, 1);
}
