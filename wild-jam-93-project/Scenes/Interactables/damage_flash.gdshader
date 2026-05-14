shader_type canvas_item;

uniform bool flashing = false;
uniform bool white = false;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = texture(TEXTURE, UV);
	if(flashing == true) {
		COLOR.r = 1.0;
		if(white == true){
			COLOR.b = 1.0;
			COLOR.g = 1.0;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
