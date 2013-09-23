//extern number screenY;
vec4 col;
extern number amount = 1;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	col = texture2D(texture, texture_coords);

	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	
	col.r = (gray-col.r)*amount + col.r;
	col.g = (gray-col.g)*amount + col.g;
	col.b = (gray-col.b)*amount + col.b;
	
	
	
	return col;
}
