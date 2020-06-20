shader_type canvas_item;
uniform vec4 primary_color : hint_color;	// Replaces Red
uniform vec4 secondary_color : hint_color; 	// Replaces Green
uniform vec4 tertiary_color : hint_color; 	// Replaces Blue
uniform vec4 skin_color : hint_color; 		// Replaces Yellow
uniform vec4 hair_color : hint_color; 		// Replaces Purple
uniform vec4 eye_color : hint_color; 		// Replaces Cyan

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (col.r > 0.0 && col.r > col.g && col.r > col.b) {
		COLOR = primary_color * col.r + vec4(col.g, col.g, col.g, 0.0);
		COLOR.a = col.a;
	} else if (col.g > 0.0 && col.g > col.b && col.g > col.r) {
		COLOR = secondary_color * col.g + vec4(col.r, col.r, col.r, 0.0);
		COLOR.a = col.a;
	} else if (col.b > 0.0 && col.b > col.g && col.b > col.r) {
		COLOR = tertiary_color * col.b + vec4(col.g, col.g, col.g, 0.0);
		COLOR.a = col.a;
	} else if (col.r == col.g && col.r > col.b && col.g > col.b) {
		COLOR = skin_color * col.r + vec4(col.b, col.b, col.b, 0.0);
		COLOR.a = col.a;
	} else if (col.r == col.b && col.r > col.g && col.b > col.g) {
		COLOR = hair_color * col.r + vec4(col.g, col.g, col.g, 0.0);
		COLOR.a = col.a;
	} else if (col.b == col.g && col.g > col.r && col.b > col.r) {
		COLOR = eye_color * col.b + vec4(col.r, col.r, col.r, 0.0);
		COLOR.a = col.a;
	} else {
		COLOR = col;
	}
	NORMALMAP = texture(NORMAL_TEXTURE, UV).rgb;
}