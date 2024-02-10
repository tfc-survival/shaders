#version 400 compatibility
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

#define WAVING_LEAVES
#define WAVING_VINES
#define WAVING_GRASS
#define WAVING_WHEAT
#define WAVING_FLOWERS
#define WAVING_FIRE
#define WAVING_LAVA
#define WAVING_LILYPAD

#define ENTITY_LEAVES        18.0
#define ENTITY_VINES        106.0
#define ENTITY_TALLGRASS     31.0
#define ENTITY_DANDELION     37.0
#define ENTITY_ROSE          38.0
#define ENTITY_WHEAT         59.0
#define ENTITY_LILYPAD      111.0
#define ENTITY_FIRE          51.0
#define ENTITY_LAVAFLOWING   10.0
#define ENTITY_LAVASTILL     11.0


#define SHADOW_MAP_BIAS 0.8
const float PI = 3.1415927;
out vec4 texcoord;

attribute vec4 mc_midTexCoord;
attribute vec4 mc_Entity;

uniform mat4 shadowProjectionInverse;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;
uniform int worldTime;
uniform float rainStrength;
uniform vec3 cameraPosition;
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

float pi2wt = PI*2*(frameTimeCounter*24);

vec3 calcWave(in vec3 pos, in float fm, in float mm, in float ma, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5) {

    float magnitude = sin(dot(vec4(pi2wt*fm, pos.x, pos.z, pos.y),vec4(0.5))) * mm + ma;
	vec3 d012 = sin(pi2wt*vec3(f0,f1,f2));
	vec3 ret = sin(pi2wt*vec3(f3,f4,f5) + vec3(d012.x + d012.y,d012.y + d012.z,d012.z + d012.x) - pos) * magnitude;
	
    return ret;
}

vec3 calcMove(in vec3 pos, in float f0, in float f1, in float f2, in float f3, in float f4, in float f5, in vec3 amp1, in vec3 amp2) {
    vec3 move1 = calcWave(pos      , 0.0054, 0.0400, 0.0400, 0.0127, 0.0089, 0.0114, 0.0063, 0.0224, 0.0015) * amp1;
	vec3 move2 = calcWave(pos+move1, 0.07, 0.0400, 0.0400, f0, f1, f2, f3, f4, f5) * amp2;
    return move1+move2;
}
vec3 calcWaterMove(in vec3 pos)
{
	float fy = fract(pos.y + 0.001);
	if (fy > 0.002)
	{
		float wave = 0.05 * sin(2*PI/4*frameTimeCounter + 2*PI*2/16*pos.x + 2*PI*5/16*pos.z)
				   + 0.05 * sin(2*PI/3*frameTimeCounter - 2*PI*3/16*pos.x + 2*PI*4/16*pos.z);
		return vec3(0, clamp(wave, -fy, 1.0-fy), 0);
	}
	else
	{
		return vec3(0);
	}
}
vec4 BiasShadowProjection(in vec4 projectedShadowSpacePosition, in vec3 normal) {

	vec2 pos = abs(projectedShadowSpacePosition.xy * 1.165);
	float dist = pow(pow(pos.x, 12.) + pow(pos.y, 12.), 1.0 / 12.0);

	float distortFactor = (1.0 - SHADOW_MAP_BIAS) + dist * SHADOW_MAP_BIAS;

	projectedShadowSpacePosition.xy /= distortFactor*0.97;

	projectedShadowSpacePosition.z /= 2.5;


	return projectedShadowSpacePosition;
}
void main() {
	vec4 position = ftransform();
	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;
	position = shadowProjectionInverse * position;
	position = shadowModelViewInverse * position;
	vec3 worldpos = position.xyz + cameraPosition;
	bool wavy1 = false;
	bool wavy2 = false;
	switch(int(mc_Entity.x)){
		case 31 : wavy1=true; break;
		case 18 : wavy2=true; break;
		case 161 : wavy2=true; break;
		case 37 : wavy1=true; break;
		case 59 : wavy1=true; break;
		case 6 : wavy1=true; break;
		case 32 : wavy1=true; break;
		case 38 : wavy1=true; break;
		case 115 : wavy1=true; break;

	}
	vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
	if ((istopv && wavy1)|| wavy2) position.xyz += calcMove(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(1.0,0.2,1.0), vec3(0.5,0.1,0.5))*1.4;
	position = shadowModelView * position;
	position = shadowProjection * position;
	gl_Position = BiasShadowProjection(position,normal);


	texcoord = gl_MultiTexCoord0;


	texcoord.z = 1.0;
	if(mc_Entity.x == 8 || mc_Entity.x == 9) texcoord.z = 0.0;
}
