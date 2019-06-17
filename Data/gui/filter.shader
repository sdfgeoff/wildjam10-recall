/* This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>. */
shader_type canvas_item;

// Lens parameters
uniform vec3 lens_vignette = vec3(0.0);
uniform vec3 lens_chromatic_aberation = vec3(0.0);
uniform vec3 lens_radial_distortion = vec3(0.0);
uniform float lens_zoom_factor = 1.0;
uniform float hue_shift_probability = 0.01;

// Sensor parameters
uniform vec3 sensor_pixel_noise = vec3(0.0);

// arrgh, you can't access constants in functions. Fortunately you can access
// varyings, so we set this in the vertex shader to make it accessable everywhere
varying float time;

float rand(vec2 co){
	// Generate a random number. This is the well known magic random number generator
	// that seems to appear everywhere in GLSL code. In this case, from stack overflow
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 center_coords(vec2 uv){
	// It's much nicer to work with the center of the screen being 0,0
	// rather than the edge of the screen.
	return (uv - vec2(0.5)) * 2.0;
}
vec2 uncenter_coords(vec2 uv){
	// Undo center coords
	return (uv * 0.5) + vec2(0.5);
}


vec2 lens_distort_coords(vec2 input_coords){
	// Radial distortion. See https://docs.opencv.org/3.4.3/dc/dbb/tutorial_py_calibration.html
	// This code is based on modules/calib3d/src/undistort.cpp in the function
	// cvUndistortPointsInternal where they do an iterative undistort that compares the
	// real values with computed distorted ones. The changes are mostly to try make
	// it obvious to the GLSL compiler what we are doing in the hope it can optimize the
	// multiplies more effectively. This should be disassembled/tested at some point.
	float x = input_coords.x;
	float y = input_coords.y;
	
	float r2 = dot(input_coords, input_coords);  // u.u = |u|^2
	float r4 = r2 * r2;
	float r6 = r2 * r4;
	
	float cdist = 1.0 + dot(lens_radial_distortion, vec3(r2, r4, r6));
	vec2 distort_amt = vec2(cdist);

	return input_coords * distort_amt * lens_zoom_factor;
}


vec4 sample_photons(sampler2D tex, vec2 coords){
	/* Samples the photons as they arrive at the enterance
	to the lens. Not quite true because we don't use a 
	real lens model, but close enough.... */
	vec2 texture_coords = uncenter_coords(coords);
	return texture(tex, texture_coords, 1.0);
}

vec4 sample_lens(sampler2D tex, vec2 coords){
	/* Sample the light at a particular point inside the lens
	This includes all lens artifacts such as vignetting, 
	chromatic aberation, lens distortion, and in the future jello. */
	vec4 output;
	float r2 = dot(coords, coords);  // u.u = |u|^2
	float r4 = r2 * r2;
	float r6 = r4 * r2;
	vec3 r2r4r6 = vec3(r2, r4, r6);
	
	float vignette_factor = dot(lens_vignette, r2r4r6);
	
	// TODO: add jello
	
	if (length(lens_chromatic_aberation) == 0.0){
		output = sample_photons(tex, lens_distort_coords(coords));
	} else {
		float abr = dot(lens_chromatic_aberation, r2r4r6);// * rand(UV);
		output = vec4(
			sample_photons(tex, lens_distort_coords(coords*(1.0 - abr*3.0))).r,
			sample_photons(tex, lens_distort_coords(coords*(1.0 - abr*2.0))).g,
			sample_photons(tex, lens_distort_coords(coords*(1.0 - abr*1.0))).b,
			1.0
		);
	}
	output.rgb *= (1.0 + vignette_factor);
	return output;
}

vec4 sample_sensor(sampler2D tex, vec2 coords){
	
	// TODO: improve noise type and include hue variation in noise
	vec4 raw_sample = sample_lens(tex, coords);
	raw_sample += dot(sensor_pixel_noise.xy, vec2(
		rand(coords) - 0.5,  // Static Noise
		rand(coords+vec2(0.0, time*sensor_pixel_noise.z)) - 0.5 // Dynamic noise
	));

	return raw_sample;
}


void vertex(){
	time = TIME;
}



void fragment(){
	vec2 coords = center_coords(UV);
	COLOR = sample_sensor(TEXTURE, coords);
	COLOR.a = 1.0;
	
	float ran = rand(vec2(coords.y - mod(coords.y, 0.01) - TIME, coords.x - mod(coords.x, 0.01) + TIME));
	if (hue_shift_probability > ran){
		ran = ran / hue_shift_probability * 3.14159;
		vec3 col = vec3(1.0) - vec3(sin(ran), sin(ran+1.0), sin(ran+2.0));
		COLOR.rgb += col * 0.1;
	}
}