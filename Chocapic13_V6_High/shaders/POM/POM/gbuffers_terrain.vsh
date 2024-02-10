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

#define ENTITY_LEAVES        18
#define ENTITY_VINES        106
#define ENTITY_TALLGRASS     31
#define ENTITY_DANDELION     37
#define ENTITY_ROSE          38
#define ENTITY_WHEAT         59
#define ENTITY_LILYPAD      111
#define ENTITY_FIRE          51
#define ENTITY_LAVAFLOWING   10
#define ENTITY_LAVASTILL     11

out vec4 color;
varying float dist;
varying vec4 texcoord;
varying vec4 vtexcoordam; // .st for add, .pq for mul
varying vec4 vtexcoord;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 viewVector;

out vec4 normal;

attribute vec4 mc_Entity;
attribute vec4 mc_midTexCoord;

uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec3 upPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;
const float PI48 = 150.796447372;
float pi2wt = PI48*frameTimeCounter;


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



								
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	normal.xyz = gl_NormalMatrix * gl_Normal;
	texcoord = vec4((gl_MultiTexCoord0).xy,(gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
	vec2 midcoord = (gl_TextureMatrix[0] *  mc_midTexCoord).st;
	vec2 texcoordminusmid = texcoord.xy-midcoord;
	vtexcoordam.pq  = abs(texcoordminusmid)*2;
	vtexcoordam.st  = min(texcoord.xy,midcoord-texcoordminusmid);
	vtexcoord.xy    = sign(texcoordminusmid)*0.5+0.5;

	

	bool istopv = gl_MultiTexCoord0.t < mc_midTexCoord.t;
	
	
	//optimisation to get only one comparison to do per waving move
	//(a-x)*(b-x)*(c-x)*(d-x)
	bool wavy1 = false;
	bool wavy2 = false;
	bool emissive = false;
	color = gl_Color;
	normal.a = 0.02;
	switch(int(mc_Entity.x)){
		case 31 : wavy1=true; break;
		case 30 : normal.a = 0.7; break;
		case ENTITY_LEAVES : wavy2=true; break;
		case 161 : wavy2=true; break;
		case 37 : wavy1=true; break;
		case 59 : wavy1=true; break;
		case 6 : wavy1=true; break;
		case 32 : wavy1=true; break;
		case 38 : wavy1=true; break;
		case 39 : normal.a = 0.7; break;
		case 40 : normal.a = 0.7; break;
		case 83 : normal.a = 0.7; break;
		case 104 : normal.a = 0.7; break;
		case 105 : normal.a = 0.7; break;
		case 106 : normal.a = 0.7; break;
		case 111 : normal.a = 0.7; break;
		case 141 : normal.a = 0.7; break;
		case 142 : normal.a = 0.7; break;
		case 175 : normal.a = 0.7; break;
		case 115 : wavy1=true; break;
		case 10 : emissive = true; break;
		case 11 : emissive = true; break;
		case 50 : emissive = true; break;
		case 51 : emissive = true; break;
		case 76 : emissive = true; break;
		case 89 : emissive = true; break;
		case 124 : emissive = true; break;
	}



	if (emissive){
		color = vec4(1.0);
		normal.a = 0.6;
	}
	
	gl_Position = ftransform();
	if ((istopv && wavy1)|| wavy2) {
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	position = gbufferModelViewInverse * position;
	vec3 worldpos = position.xyz + cameraPosition;
	position.xyz += calcMove(worldpos.xyz, 0.0040, 0.0064, 0.0043, 0.0035, 0.0037, 0.0041, vec3(1.0,0.2,1.0), vec3(0.5,0.1,0.5))*1.4;
	position = gbufferModelView * position;	
	gl_Position = gl_ProjectionMatrix * position;
	}


			normal.a = (wavy1 || wavy2)? 0.7 : normal.a;

			color.rgb *= vec3(1.0+float(wavy1 || wavy2)*0.1);	





	if (gl_Normal.y > 0.5) {
		//  0.0,  1.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	} else if (gl_Normal.x > 0.5) {
		//  1.0,  0.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, -1.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.x < -0.5) {
		// -1.0,  0.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.z > 0.5) {
		//  0.0,  0.0,  1.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.z < -0.5) {
		//  0.0,  0.0, -1.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3(-1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
	} else if (gl_Normal.y < -0.5) {
		//  0.0, -1.0,  0.0
		tangent.xyz  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
		binormal.xyz = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  -1.0));
	}
/* */
mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
								  tangent.y, binormal.y, normal.y,
						     	  tangent.z, binormal.z, normal.z);
	
	
	viewVector = ( gl_ModelViewMatrix * gl_Vertex).xyz;
	
	viewVector = normalize(tbnMatrix * viewVector);
	
	
	dist = 0.0;
	dist = length(gl_ModelViewMatrix * gl_Vertex);
	
	







}