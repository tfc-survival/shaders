#version 400 compatibility
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

/*
const int compositeFormat = RGBA16;
const int gaux2Format = RGBA16;
const int gaux3Format = RGBA16;		
const int gaux4Format = RGBA16;	
*/

/*
const int gcolorFormat = RGBA8;
const int gdepthFormat = RGBA16;
const int gnormalFormat = RGBA16;
const int compositeFormat = R11F_G11F_B10F;
const int gaux1Format = RGBA16;
const int gaux2Format = R11F_G11F_B10F;
const int gaux3Format = R11F_G11F_B10F;		
const int gaux4Format = R11F_G11F_B10F;	
*/

in vec4 color;

in vec4 texcoord;
in vec4 normal;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;



uniform sampler2D texture;


uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform int fogMode;
uniform int worldTime;
uniform float wetness;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;

//encode normal in two channel (xy),torch and material(z) and sky lightmap (w)
vec4 encode (vec3 n)
{
	
    float p = sqrt(n.z*8+8);
    return vec4(n.xy/p + 0.5,texcoord.z,texcoord.w);
}

vec3 RGB2YCoCg(vec3 c){
		return vec3( 0.25*c.r+0.5*c.g+0.25*c.b, 0.5*c.r-0.5*c.b +0.5, -0.25*c.r+0.5*c.g-0.25*c.b +0.5);
	}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {


vec4 albedo = texture2D(texture,texcoord.xy)*color;
vec4 cAlbedo = vec4(RGB2YCoCg(albedo.rgb),albedo.a);

bool pattern = (mod(gl_FragCoord.x,2.0)==mod(gl_FragCoord.y,2.0));
cAlbedo.g = (pattern)?cAlbedo.b: cAlbedo.g;
cAlbedo.b = normal.a;
/* DRAWBUFFERS:01 */

	gl_FragData[0] = cAlbedo;
	gl_FragData[1] = encode(normal.xyz);
}