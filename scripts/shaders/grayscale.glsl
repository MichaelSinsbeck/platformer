//extern number screenY;
vec4 col;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	col = texture2D(texture, texture_coords);

	float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
	return vec4(gray, gray, gray, col.a/3);
}
