#version 400 compatibility
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/

	const float shadowMapResolution = 2048;		//shadowmap resolution
	
	
#define UNDERWATERFIX //fixes shadows and other stuff underwater
#define SHADOW_MAP_BIAS 0.80
in vec4 color;
in vec2 texcoord;
in vec2 lmcoord;
in vec4 ambientNdotL;
in vec4 sunlightMat;

in vec3 binormal;
in vec3 normal;
in vec3 tangent;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;

uniform sampler2D noisetex;
uniform sampler2D texture;
uniform sampler2DShadow shadow;

uniform int isEyeInWater;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 cameraPosition;
uniform vec3 upPosition;
uniform int fogMode;
uniform int worldTime;
uniform float wetness;
uniform float rainStrength;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
uniform int heldBlockLightValue;


vec3 sunlight = sunlightMat.rgb;
float mat = sunlightMat.a;
	const vec2 shadow_offsets[60] = vec2[60]  (  vec2(0.06120777f, -0.8370339f),
vec2(0.09790099f, -0.5829314f),
vec2(0.247741f, -0.7406831f),
vec2(-0.09391049f, -0.9929391f),
vec2(0.4241214f, -0.8359816f),
vec2(-0.2032944f, -0.70053f),
vec2(0.2894208f, -0.5542058f),
vec2(0.2610383f, -0.957112f),
vec2(0.4597653f, -0.4111754f),
vec2(0.1003582f, -0.2941186f),
vec2(0.3248212f, -0.2205462f),
vec2(0.4968775f, -0.6096044f),
vec2(0.770794f, -0.5416877f),
vec2(0.6429226f, -0.261653f),
vec2(0.6138752f, -0.7684944f),
vec2(-0.06001971f, -0.4079638f),
vec2(0.08106154f, -0.07295965f),
vec2(-0.1657472f, -0.2334092f),
vec2(-0.321569f, -0.4737087f),
vec2(-0.3698382f, -0.2639024f),
vec2(-0.2490126f, -0.02925519f),
vec2(-0.4394466f, -0.06632736f),
vec2(-0.6763983f, -0.1978866f),
vec2(-0.5428631f, -0.3784158f),
vec2(-0.3475675f, -0.9118061f),
vec2(-0.1321516f, 0.2153706f),
vec2(-0.3601919f, 0.2372792f),
vec2(-0.604758f, 0.07382818f),
vec2(-0.4872904f, 0.4500539f),
vec2(-0.149702f, 0.5208581f),
vec2(-0.6243932f, 0.2776862f),
vec2(0.4688022f, 0.04856517f),
vec2(0.2485694f, 0.07422727f),
vec2(0.08987152f, 0.4031576f),
vec2(-0.353086f, 0.7864715f),
vec2(-0.6643087f, 0.5534591f),
vec2(-0.8378839f, 0.335448f),
vec2(-0.5260508f, -0.7477183f),
vec2(0.4387909f, 0.3283032f),
vec2(-0.9115909f, -0.3228836f),
vec2(-0.7318214f, -0.5675083f),
vec2(-0.9060445f, -0.09217478f),
vec2(0.9074517f, -0.2449507f),
vec2(0.7957709f, -0.05181496f),
vec2(-0.1518791f, 0.8637156f),
vec2(0.03656881f, 0.8387206f),
vec2(0.02989202f, 0.6311651f),
vec2(0.7933047f, 0.4345242f),
vec2(0.3411767f, 0.5917205f),
vec2(0.7432346f, 0.204537f),
vec2(0.5403291f, 0.6852565f),
vec2(0.6021095f, 0.4647908f),
vec2(-0.5826641f, 0.7287358f),
vec2(-0.9144157f, 0.1417691f),
vec2(0.08989539f, 0.2006399f),
vec2(0.2432684f, 0.8076362f),
vec2(0.4476317f, 0.8603768f),
vec2(0.9842657f, 0.03520538f),
vec2(0.9567313f, 0.280978f),
vec2(0.755792f, 0.6508092f));
const vec2 check_offsets[25] = vec2[25](vec2(-0.4894566f,-0.3586783f),
									vec2(-0.1717194f,0.6272162f),
									vec2(-0.4709477f,-0.01774091f),
									vec2(-0.9910634f,0.03831699f),
									vec2(-0.2101292f,0.2034733f),
									vec2(-0.7889516f,-0.5671548f),
									vec2(-0.1037751f,-0.1583221f),
									vec2(-0.5728408f,0.3416965f),
									vec2(-0.1863332f,0.5697952f),
									vec2(0.3561834f,0.007138769f),
									vec2(0.2868255f,-0.5463203f),
									vec2(-0.4640967f,-0.8804076f),
									vec2(0.1969438f,0.6236954f),
									vec2(0.6999109f,0.6357007f),
									vec2(-0.3462536f,0.8966291f),
									vec2(0.172607f,0.2832828f),
									vec2(0.4149241f,0.8816f),
									vec2(0.136898f,-0.9716249f),
									vec2(-0.6272043f,0.6721309f),
									vec2(-0.8974028f,0.4271871f),
									vec2(0.5551881f,0.324069f),
									vec2(0.9487136f,0.2605085f),
									vec2(0.7140148f,-0.312601f),
									vec2(0.0440252f,0.9363738f),
									vec2(0.620311f,-0.6673451f)
									);	

float waterH(vec3 worldPos,float time) {

	float waveSpeed = 0.6;

	vec2 coord = fract(vec2(worldPos.xz / 2000.0));
	float ft2 = time/3.;
	float noise =  texture2D(noisetex, coord * 1.5 + vec2(ft2 / 1000.0 * waveSpeed,ft2 / 2000.0 * waveSpeed)).x / 1.5;
		  noise += texture2D(noisetex, coord * 1.5 + vec2(ft2 / 2500.0 * waveSpeed,ft2 / 800.0 * waveSpeed)).x / 1.5;
		  noise += texture2D(noisetex, coord * 3.5 + vec2(ft2 / 600.0 * waveSpeed,ft2 / 1200.0 * waveSpeed)).x / 3.5;
		  noise += texture2D(noisetex, coord * 3.5 + vec2(ft2 / 1500.0 * waveSpeed,ft2 / 500.0 * waveSpeed)).x / 3.5;
		  noise += texture2D(noisetex, coord * 7.0 + vec2(ft2 / 300.0 * waveSpeed,ft2 / 600.0 * waveSpeed)).x / 7.0;
		  noise += texture2D(noisetex, coord * 7.0 + vec2(ft2 / 750.0 * waveSpeed,ft2 / 250.0 * waveSpeed)).x / 7.0;
float wave = 0.0;



const float amplitude = 0.2;

vec4 waveXYZW = vec4(worldPos.xz,worldPos.xz)/vec4(250.,50.,-250.,-150.)+vec4(50.,250.,50.,-250.);
vec2 fpxy = abs(fract(waveXYZW.xy*20.0)-0.5)*2.0;

float d = amplitude*length(fpxy);

wave = cos(waveXYZW.x*waveXYZW.y+time) + 0.5 * cos(2.0*waveXYZW.x*waveXYZW.y+time) + 0.25 * cos(4.0*waveXYZW.x*waveXYZW.y+time);

	return noise*0.55+(d*wave + d*(cos(waveXYZW.z*waveXYZW.w+time) + 0.5 * cos(2.0*waveXYZW.z*waveXYZW.w+time) + 0.25 * cos(4.0*waveXYZW.z*waveXYZW.w+time)));

}
/*
float waterH(vec3 posxz,float time) {

float wave = 0.0;



const float amplitude = 0.2;

vec4 waveXYZW = vec4(posxz.xz,posxz.xz)/vec4(250.,50.,-250.,-150.)+vec4(50.,250.,50.,-250.);
vec2 fpxy = abs(fract(waveXYZW.xy*20.0)-0.5)*2.0;

float d = amplitude*length(fpxy);

wave = cos(waveXYZW.x*waveXYZW.y+time) + 0.5 * cos(2.0*waveXYZW.x*waveXYZW.y+time) + 0.25 * cos(4.0*waveXYZW.x*waveXYZW.y+time);

return d*wave + d*(cos(waveXYZW.z*waveXYZW.w+time) + 0.5 * cos(2.0*waveXYZW.z*waveXYZW.w+time) + 0.25 * cos(4.0*waveXYZW.z*waveXYZW.w+time));

}
*/

vec4 encode (vec3 n,float dif)
{
    float p = sqrt(n.z*8+8);
	
	float vis = lmcoord.t;
	if (ambientNdotL.a > 0.9) vis = vis / 4.0;
	if (ambientNdotL.a > 0.4 && ambientNdotL.a < 0.6) vis = vis/4.0+0.25;
	if (ambientNdotL.a < 0.1) vis = vis/4.0+0.5;
		
	
    return vec4(n.xy/p + 0.5,vis,1.0);
}


//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////

void main() {
	
	float iswater = ambientNdotL.a;
	float diffuse = dot(normalize(sunPosition),normal);
	diffuse = (worldTime > 12700 && worldTime < 23250)? -diffuse : diffuse;
		
#ifdef UNDERWATERFIX
float mulfov = 1.0;
if (isEyeInWater>0.1){
float fov = atan(1./gbufferProjection[1][1]);
float fovUnderWater = fov*0.85;
mulfov = gbufferProjection[1][1]*tan(fovUnderWater); 
}
#endif
#ifndef UNDERWATERFIX
const float mulfov = 1.0;
#endif	


	
	vec4 albedo = texture2D(texture, texcoord.xy)*color;
	albedo.rgb = pow(albedo.rgb,vec3(2.2));
	if (iswater > 0.9) albedo.rgb = mix(albedo.rgb,vec3(0.35,0.67,0.72),0.8);
	vec3 colorrgb = albedo.rgb;
	

	vec4 fragposition = gbufferProjectionInverse*(vec4(gl_FragCoord.xy/vec2(viewWidth,viewHeight),gl_FragCoord.z,1.0)*2.0-1.0);
	fragposition /= fragposition.w;
	fragposition *= mulfov;

	
	vec4 worldposition = gbufferModelViewInverse * fragposition;
	vec3 wpos = worldposition.xyz;

	if (diffuse > 0. && iswater < 0.9){
	worldposition = shadowModelView * worldposition;
	worldposition = shadowProjection * worldposition;
	worldposition /= worldposition.w;
	vec2 pos = abs(worldposition.xy * 1.165);
	float distb = pow(pow(pos.x, 12.) + pow(pos.y, 12.), 1.0 / 12.0);
	float distortFactor = (1.0 - SHADOW_MAP_BIAS) + distb * SHADOW_MAP_BIAS;
	worldposition.xy /= distortFactor*0.97; 
	


	
	
	if (max(abs(worldposition.x),abs(worldposition.y)) < 0.99) {
		float diffthresh = distortFactor*distortFactor*(0.008*tan(acos(diffuse)) + 0.025)*0.08;
				const float halfres = (0.25/shadowMapResolution);
				float offset = rainStrength*2.0*halfres+halfres;

				worldposition = worldposition * vec4(0.5f,0.5,0.5/2.5,0.5) + vec4(0.5,0.5,0.5,0.5);
				float comparedepth = worldposition.z;

				float shading = 0.0;
				for(int i = 0; i < 25; i++){
					vec2 offsetS = check_offsets[i];
					float w1 = dot(offsetS,offsetS);
					float weight = 1.0+sqrt(w1*(1.0+rainStrength*8.0))*1.412/distortFactor*0.2;

					shading += shadow2D(shadow,vec3(worldposition.st +  1.412*offsetS/shadowMapResolution*(rainStrength*8.0+1.0), worldposition.z-diffthresh*weight)).x;
				}
				diffuse = shading*diffuse/25.;
					
	}
	
	}

	vec3 sunlight = (1.0-iswater)*sunlight*clamp(diffuse,0.,1.);
	
	vec4 frag2 = vec4((normal), 1.0f);
	
	if (iswater > 0.45) {

			vec3 posxz = wpos+cameraPosition;
			float ft = iswater > 0.9? frameTimeCounter*4.0:0.0;
			
			posxz.x += sin(posxz.z+ft)*0.25;
			posxz.z += cos(posxz.x+ft*0.5)*0.25;
			posxz.xz += sin(-posxz.y);
			
			const float deltaPos = 0.4;
			float h0 = waterH(posxz,ft);
			float h1 = waterH(posxz - vec3(deltaPos,0.0,0.0),ft);
			float h2 = waterH(posxz - vec3(0.0,0.0,deltaPos),ft);
			
			vec2 dXY = h0-vec2(h1,h2);
			
			
			vec3 bump = normalize(vec3(dXY/deltaPos,1.0));
			
		
		float bumpmult = 0.06*(iswater+0.0);	
		
		bump = bump * vec3(bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);
		mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
							tangent.y, binormal.y, normal.y,
							tangent.z, binormal.z, normal.z);
		
		frag2 = vec4(normalize(bump * tbnMatrix), 1.0);
}

		

	vec3 fColor = colorrgb*(sunlight*2.15+ambientNdotL.rgb*1.4)*0.63;

	
	
	float alpha = mix(albedo.a,0.11,max(iswater*2.0-1.0,0.0));

/* DRAWBUFFERS:526 */
	gl_FragData[0] = vec4(fColor,alpha);
	gl_FragData[1] = encode(frag2.rgb,diffuse);
	gl_FragData[2] = vec4(normalize(albedo.rgb+0.00001),alpha);
}