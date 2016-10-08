vec4 col;
extern number percentage = 0;
number bright;
extern number grayAmount = 0;
#define PI 3.1415926535897932384626433832795
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	col = texture2D(texture, texture_coords);
	
	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114))*0.75;
	
	col.r = (gray-col.r)*grayAmount + col.r;
	col.g = (gray-col.g)*grayAmount + col.g;
	col.b = (gray-col.b)*grayAmount + col.b;
	
	/*if (percentage < 25)
	{
		bright = 1;
		//2-percentage/12.5;
	} else {
		bright = (percentage-75)/25;
	}
	
	bright = min(bright,1);
	
	bright = - bright*bright + 2*bright;*/
	
	bright = 1-sin(PI*percentage/100);
	
	return vec4(col.r*bright, col.g*bright, col.b*bright, 1);
}
