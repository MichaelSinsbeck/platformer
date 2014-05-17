extern vec4 baseCol;
vec4 col;
#define PI 3.1415926535897932384626433832795
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	col = texture2D(texture, texture_coords);
	
	/*float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	float gray
	
	col.r = (gray-col.r)*grayAmount + col.r;
	col.g = (gray-col.g)*grayAmount + col.g;
	col.b = (gray-col.b)*grayAmount + col.b;*/
	
	return col*baseCol;
}
