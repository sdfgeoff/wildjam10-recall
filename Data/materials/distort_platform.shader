shader_type spatial;

uniform float distort_amount = 0.0;
uniform vec4 highlight : hint_color = vec4(1.0);
uniform sampler2D normalmap;

varying float factor;

uniform float PHI = 1.61803398874989484820459e-1;// * 00000.1; // Golden Ratio   
uniform float PI  = 3.14159265358979323846264e-1;// * 00000.1; // PI
uniform float SQ2 = 1.41421356237309504880169e5;// * 10000.0; // Square Root of Two

float gold_noise(in vec2 coordinate, in float seed){
    return fract(tan(distance(coordinate*(seed+PHI), vec2(PHI, PI)))*SQ2);
}


void vertex(){
	if (distort_amount > 0.01){
		vec3 noise = vec3(
			gold_noise(COLOR.xy, TIME),
			gold_noise(COLOR.xy, TIME+COLOR.x),
			gold_noise(COLOR.xy, TIME+COLOR.z)
		);

		float noise_scale = distort_amount;
	
		VERTEX += (noise - vec3(0.5)) * noise_scale;
	}
}

void fragment(){
	vec4 sample = texture(normalmap, UV);
	vec3 normal_map_sample = normalize(sample.rgb * 2.0 - 1.0);
	
	vec3 world_vect_norm = NORMAL;
	vec3 world_vect_tangent = TANGENT;
	vec3 bitan = cross(world_vect_norm, world_vect_tangent);
	mat3 tbn = mat3(world_vect_tangent, bitan, world_vect_norm);
	NORMAL = tbn * normal_map_sample;
	ALBEDO = vec3((normal_map_sample.b * 0.5 + 0.5) * 0.5 * (pow(sample.a, 0.3) + 0.5));
	
	float highlight_strength = pow(1.0 - NORMAL.z, 2.0) * highlight.a;
	EMISSION = highlight.rgb * highlight_strength + pow(highlight_strength, 2.0);
}