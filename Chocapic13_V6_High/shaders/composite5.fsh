#version 400 compatibility
#extension GL_ARB_shader_texture_lod : enable

/*






!! DO NOT REMOVE !! !! DO NOT REMOVE !!

This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !! !! DO NOT REMOVE !!


Sharing and modification rules

Sharing a modified version of my shaders:
-You are not allowed to claim any of the code included in "Chocapic13' shaders" as your own
-You can share a modified version of my shaders if you respect the following title scheme : " -Name of the shaderpack- (Chocapic13' Shaders edit) "
-You cannot use any monetizing links
-The rules of modification and sharing have to be same as the one here (copy paste all these rules in your post), you cannot make your own rules
-I have to be clearly credited
-You cannot use any version older than "Chocapic13' Shaders V4" as a base, however you can modify older versions for personal use
-Common sense : if you want a feature from another shaderpack or want to use a piece of code found on the web, make sure the code is open source. In doubt ask the creator.
-Common sense #2 : share your modification only if you think it adds something really useful to the shaderpack(not only 2-3 constants changed)


Special level of permission; with written permission from Chocapic13, if you think your shaderpack is an huge modification from the original (code wise, the look/performance is not taken in account):
-Allows to use monetizing links
-Allows to create your own sharing rules
-Shaderpack name can be chosen
-Listed on Chocapic13' shaders official thread
-Chocapic13 still have to be clearly credited


Using this shaderpack in a video or a picture:
-You are allowed to use this shaderpack for screenshots and videos if you give the shaderpack name in the description/message
-You are allowed to use this shaderpack in monetized videos if you respect the rule above.


Minecraft website:
-The download link must redirect to the link given in the shaderpack's official thread
-You are not allowed to add any monetizing link to the shaderpack download

If you are not sure about what you are allowed to do or not, PM Chocapic13 on http://www.minecraftforum.net/
Not respecting these rules can and will result in a request of thread/download shutdown to the host/administrator, with or without warning. Intellectual property stealing is punished by law.











*/

//disabling is done by adding "//" to the beginning of a line.
/*--------------------------------*/
/*--------------------------------*/
//#define BANDINGFIX //enable this only if you are using minecraft 1.8.9 and lower
/*--------------------------------*/
in vec2 texcoord;
in vec3 sunlight;
in vec3 ambient_color;
in float eyeAdapt;

uniform sampler2D noisetex;
uniform sampler2D gaux4;

uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform ivec2 eyeBrightness;
uniform int isEyeInWater;
uniform int worldTime;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
uniform float wetness;
uniform float frameTimeCounter;
uniform int fogMode;
float pw = 1.0/ 1920.;
float ph = 1.0/ 1920.*aspectRatio;
float timefract = worldTime;
/*--------------------------------*/

float luma(vec3 color) {
	return dot(color,vec3(0.299, 0.587, 0.114));
}
	float hash( float n ) {
		return fract(sin(n)*43758.5453);
	}
 
	float noise( in vec2 x ) {
	return texture2D(noisetex,x/1000.).x;
	}
 
 
	float fbm( vec2 p ) {
	const vec4 w = vec4(0.5,0.25,0.125,0.0625)/0.953125;
    	float f = dot(vec4(noise( p ),noise( p*2.02 ),noise( p *4.1006),noise( p *8.242206)),w);


		
    	return f;
	}
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
		gl_FragData[0] = vec4(0.);
if(texcoord.x<0.25 && texcoord.y<0.25){
//Bloom



const int nSteps = 51;
int center = (nSteps-1)/2;
float sigma = 0.14;

/*--------------------------------*/
//huge gaussian blur for glare
vec3 blur = vec3(0.0);
float tw = 0.0;
for (int i = 0; i < nSteps; i++) {

	float dist = abs(i-float(center))/center;
	
	float weight = (exp(-(dist*dist)/(2.0*sigma)));
	
#ifdef BANDINGFIX 
	vec3 bsample= pow(texture2D(gaux4,clamp(texcoord.xy + vec2(pw,ph)*vec2(0.0,i-center*1.),0.,1.)).rgb,vec3(2.))*3.;
#else
	vec3 bsample= texture2D(gaux4,clamp(texcoord.xy + vec2(pw,ph)*vec2(0.0,i-center*1.),0.,1.)).rgb*3.;
#endif
	blur += bsample*weight;
	tw += weight;

}
blur /= tw;

	
	

vec3 glow = blur;
vec3 overglow = glow*pow(length(glow)*2.,2.8)*2.35;


	
/* DRAWBUFFERS:7 */
#ifdef BANDINGFIX 
vec3 finalC = pow((overglow+glow*1.15)*(1+isEyeInWater*5.+(pow(rainStrength,3.)*7./pow(eyeAdapt,1.0)))*3.*0.4,vec3(1./2.));
#else
vec3 finalC = (overglow+glow*1.15)*(1+isEyeInWater*5.+(pow(rainStrength,3.)*7./pow(eyeAdapt,1.0)))*3.*0.4;
#endif

	gl_FragData[0] = vec4(finalC,1.0);
	}

}
