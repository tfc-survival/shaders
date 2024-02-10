#version 400 compatibility
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/


out vec4 color;
out vec4 texcoord;

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


								
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {



	

	gl_Position = ftransform();	
	color = gl_Color;
	/*--------------------------------*/
	
	texcoord = vec4((gl_MultiTexCoord0).xy,(gl_TextureMatrix[1] * gl_MultiTexCoord1).xy);
	normal.xyz = normalize(gl_NormalMatrix * gl_Normal);

}