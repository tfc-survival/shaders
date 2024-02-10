#version 400 compatibility
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
const bool gaux1MipmapEnabled = true;
#define UNDERWATERFIX //fixes shadows and other stuff underwater
//#define BANDINGFIX //enable this only if you are using minecraft 1.8.9 and lower
	//#define GODRAYS			//in this step previous godrays result is blurred
		const float exposure = 1.05;			//godrays intensity
		const float density = 1.0;
		const float grnoise = 0.0;		//amount of noise


//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES
//////////////////////////////END OF ADJUSTABLE VARIABLES

const int maxf = 6;				//number of refinements
const float stp = 1.0;			//size of one step for raytracing algorithm
const float ref = 0.07;			//refinement multiplier
const float inc = 2.2;			//increasement factor at each step

/*--------------------------------*/
in vec2 texcoord;

in vec3 avgAmbient;
in vec3 sunVec;
in vec3 moonVec;
in vec3 upVec;
in vec3 lightColor;

in vec3 sky1;
in vec3 sky2;
in float skyMult;
in vec3 nsunlight;

in float fading;

in vec2 lightPos;

in vec3 sunlight;
const vec3 moonlight = vec3(0.5, 0.9, 1.4) * 0.005;
const vec3 moonlightS = vec3(0.5, 0.9, 1.4) * 0.001;
in vec3 ambient_c;
in float tr;

in vec3 rawAvg;

in float handItemLight;
in float eyeAdapt;
in float SdotU;
in float MdotU;
in float sunVisibility;
in float moonVisibility;
in vec3 avgAmbient2;
in vec3 cloudColor;
in vec2 rainPos1;
in vec2 rainPos2;
in vec2 rainPos3;
in vec2 rainPos4;
in vec4 weights;
in vec3 cloudc;

uniform sampler2D composite;
uniform sampler2D gaux1;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D gnormal;
uniform sampler2D gdepth;
uniform sampler2D noisetex;
uniform sampler2D gaux3;
uniform sampler2D gaux2;
uniform sampler2D gaux4;



uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferPreviousModelView;
uniform ivec2 eyeBrightnessSmooth;
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
float comp = 1.0-near/far/far;
vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}
/*--------------------------------*/
vec4 nvec4(vec3 pos) {
    return vec4(pos.xyz, 1.0);
}

float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}
	float distratio(vec2 pos, vec2 pos2) {

		return distance(pos*vec2(aspectRatio,1.0),pos2*vec2(aspectRatio,1.0));
	}



	float yDistAxis (in float degrees) {
		vec4 dVector = vec4(lightPos,texcoord);
		float ydistAxis = dot(dVector,vec4(-degrees,1.0,degrees,-1.0));
		return abs(ydistAxis);

	}
vec3 drawSun(vec3 fposition,vec3 color,float vis) {
vec3 sVector = normalize(fposition);

float angle = (1.0-max(dot(sVector,sunVec),0.0))*300;
float sun = exp(-angle*angle*angle);
sun *= (1.0-rainStrength*0.9925)*sunVisibility;
vec3 sunlightB = mix(pow(sunlight,vec3(1.0))*2.2*20.*1.7,vec3(0.25,0.3,0.4),rainStrength*0.8)*(1.0+SdotU*2.0);

return mix(color,sunlightB,sun*vis);

}
	float smoothCircleDist (in float lensDist) {

	vec2 lP = (lightPos*lensDist)-0.5*lensDist+0.5;

	return distratio(lP, texcoord);

	}

	float cirlceDist (float lensDist, float size) {
	vec2 lP = (lightPos*lensDist)-(0.5*lensDist-0.5);
		return pow(min(distratio(lP, texcoord),size)/size,10.);
	}

float getAirDensity (float h) {
return max(h/10.,6.0);
}

float FogF(vec3 fposition) {
	float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),1.0,rainStrength);
	float density = 600./1.6*(1.0-rainStrength*0.5);

	vec3 worldpos = (gbufferModelViewInverse*vec4(fposition,1.0)).rgb+cameraPosition;
	float height = mix(getAirDensity (worldpos.y),6.,rainStrength);
	float d = length(fposition);

	return pow(clamp((2.625+rainStrength*3.4)/exp(-60/10./density)*exp(-getAirDensity (cameraPosition.y)/density) * (1.0-exp( -pow(d,2.712)*height/density/(6000.-tmult*tmult*2000.)/13))/height,0.0,1.),1.0-rainStrength*0.63)*clamp((eyeBrightnessSmooth.y/255.-2/16.)*4.,0.0,1.0);
}


vec3 calcFog(vec3 fposition, vec3 color, vec3 fogclr,float yPosition,float d) {
	float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),1.0,rainStrength);
	float density = 600./2.;

	vec3 worldpos = (gbufferModelViewInverse*vec4(fposition,1.0)).rgb+cameraPosition;
	float height = mix(getAirDensity (worldpos.y),6.,rainStrength);

	float fog = clamp(0.75*4.0/exp(-60/10./density)*exp(-getAirDensity (cameraPosition.y)/density) * (1.0-exp( -pow(d,2.712)*height/density/(6000.-tmult*tmult*2000.)/13*(1.0+rainStrength*0.)))/height,0.0,1.);
	vec3 fogC = fogclr*(0.7+0.3*tmult);
return mix(color,vec3(0.2)*(1.0-isEyeInWater),fog);
}


float gen_circular_lens(vec2 center, float size) {
	float dist=distratio(center,texcoord.xy)/size;
	return exp(-dist*dist);
}

float invRain07 = 1.0-rainStrength*0.6;

vec3 getSkyc(vec3 fposition) {
/*--------------------------------*/
vec3 sVector = normalize(fposition);
/*--------------------------------*/

float cosT = dot(sVector,upVec);
float mCosT = max(cosT,0.0);
float absCosT = 1.0-max(cosT*0.82+0.26,0.2);
float cosS = SdotU;
float cosY = dot(sunVec,sVector);
float Y = acos(cosY);
/*--------------------------------*/
const float a = -1.;
const float b = -0.22;
const float c = 8.0;
const float d = -3.5;
const float e = 0.3;
/*--------------------------------*/
//luminance
float L =  (1.0+a*exp(b/(mCosT)));
float A = 1.0+e*cosY*cosY;

//gradient
vec3 grad1 = mix(sky1,sky2,absCosT*absCosT);
float sunscat = max(cosY,0.0);
vec3 grad3 = mix(grad1,nsunlight,sunscat*sunscat*(1.0-mCosT)*(0.9-rainStrength*0.5*0.9)*(clamp(-(cosS)*4.0+3.0,0.0,1.0)*0.65+0.35)+0.1);
//if (clamp(-(cosS)*4.0+3.0,0.0,1.0) > 0.2) return vec3(1.0);
//return vec3(sunscat*sunscat*(1.0-sqrt(mCosT*0.9+0.1))*(1.0-rainStrength*0.5)*(clamp(-(cosS)*4.0+3.0,0.0,1.0)*0.8+0.2)*0.9+0.1)*0.1;

float Y2 = 3.14159265359-Y;
float L2 = L * (8.0*exp(d*Y2)+A);

const vec3 moonlight2 = pow(normalize(moonlight),vec3(3.0))*length(moonlight);
const vec3 moonlightRain = normalize(vec3(0.25,0.3,0.4))*length(moonlight);


vec3 gradN = mix(moonlight,moonlight2,1.-L2/2.0);
gradN = mix(gradN,moonlightRain,rainStrength);
return pow(L*(c*exp(d*Y)+A),invRain07)*sunVisibility *length(rawAvg) * (0.85+rainStrength*0.425)*grad3+ 0.2*pow(L2*1.2+1.2,invRain07)*moonVisibility*gradN;

}

float ld(float depth) {
    return (2.0 * near) / (far + near - depth * (far - near));		// (-depth * (far - near)) = (2.0 * near)/ld - far - near
}



vec4 raytrace(vec3 fragpos, vec3 normal,vec3 fogclr,vec3 rvector, float mulfov) {
    vec4 color = vec4(0.0);
    vec3 start = fragpos;
		float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),1.0,rainStrength);

    vec3 vector = stp * rvector;
    vec3 oldpos = fragpos;
    fragpos += vector;
	vec3 tvector = vector;
    int sr = 0;
	/*--------------------------------*/
    for(int i=0;i<25;i++){
        vec3 pos = nvec3(gbufferProjection * nvec4(fragpos)) * 0.5/vec3(mulfov,mulfov,1.0) + 0.5;
		//pos.xy = floor(pos.xy*vec2(viewWidth,viewHeight))/vec2(viewWidth,viewHeight)+0.5/vec2(viewWidth,viewHeight);  //correct coordinates
        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0) break;
        vec3 spos = vec3(pos.st, texture2D(depthtex1, pos.st).r);
        spos = nvec3(gbufferProjectionInverse * nvec4(spos * 2.0 - 1.0));
		spos.xy *= mulfov;
        float err = distance(fragpos,spos);
		if(err < pow(length(vector)*1.85,1.15)){
                sr++;
                if(sr >= maxf){
					bool land = texture2D(depthtex1, pos.st).r < comp;
                    float border = clamp(1.0 - pow(cdist(pos.st), 20.0), 0.0, 1.0);
                    color = pow(texture2DLod(gaux1, pos.st,1),vec4(2.2))*257.0;
					if (isEyeInWater == 0) color.rgb = land ? mix(color.rgb,fogclr*(0.7+0.3*tmult)*(1.33-rainStrength*0.8),FogF(spos.xyz)) : drawSun(rvector,fogclr,1.0);
					else color.rgb = land? color.rgb = mix(color.rgb*0.4,vec3(0.25,0.5,0.72)*rawAvg*0.07,1.-exp(-length(spos.xyz)*0.5/40)) : vec3(0.25,0.5,0.72)*rawAvg*0.07*clamp((eyeBrightnessSmooth.y/255.-2/16.)*4.,0.0,1.0);
					color.a = border;
					break;
                }
				tvector -=vector;
                vector *=ref;


}
/*--------------------------------*/
        vector *= inc;
        oldpos = fragpos;
        tvector += vector;
		fragpos = start + tvector;
/*--------------------------------*/
    }
    return color;
}


vec3 drawCloud(vec3 fposition,vec3 color,vec3 vH) {
//const vec4 noiseWeights = 1.0/vec4(1.0,3.5,12.25,42.87)/1.4472;
const float r = 4.0;
const vec3 noiseC = vec3(1.0,r,r*r);
const vec3 noiseWeights = 1.0/vec3(1.0,r,r*r)/dot(1.0/vec3(1.0,r,r*r),vec3(1.0));
/*--------------------------------*/
vec3 sVector = normalize(fposition);
float cosT = max(dot(normalize(sVector),upVec),0.0);
float McosY = MdotU;
float cosY = SdotU;
vec3 tpos = vec3(gbufferModelViewInverse * vec4(sVector,0.0));
vec3 wvec = normalize(tpos);
vec3 wVector = normalize(tpos);
/*--------------------------------*/
float totalcloud = 0.0;
/*--------------------------------*/


vec2 wind = vec2(abs(frameTimeCounter/1000.-0.5),abs(frameTimeCounter/1000.-0.5))+vec2(0.5);
float iMult = 10.0*(0.5+0.4*(3.0-sqrt(cosT)*2.8)*(3.0-sqrt(cosT)*2.8));
float heightA = (400.0+300.0*sqrt(cosT))/(wVector.y);
/*--------------------------------*/
for (int i = 0;i<7;i++) {
	vec3 intersection = wVector*(heightA-i*iMult); 			//curved cloud plane
	vec2 coord1 = (intersection.xz+abs(3.0-i)*normalize(wind)*3.5)/200000.+wind*0.07;
	vec2 coord = fract(coord1/2.0);
	/*--------------------------------*/
	vec3 noiseSample = vec3(texture2D(noisetex,coord).x,texture2D(noisetex,coord*noiseC.y).x,texture2D(noisetex,coord*noiseC.z).x);


	float noise = dot(noiseSample,noiseWeights);
	/*--------------------------------*/
	float cl = noise;
	float d1 = max(1.0-cl*(1.6-rainStrength*0.6),0.);
	float density = d1*d1*(abs(i-3.0)+1.0)/19.0;
	/*--------------------------------*/

	/*--------------------------------*/
	totalcloud += density;

	/*--------------------------------*/
	if (totalcloud > 0.999) break;
}
totalcloud = min(totalcloud,1.0);
return mix(color.rgb,cloudColor,totalcloud*cosT);

}
float waterH(vec3 posxz,float time) {

float wave = 0.0;



const float amplitude = 0.2;

vec4 waveXYZW = vec4(posxz.xz,posxz.xz)/vec4(250.,50.,-250.,-150.)+vec4(50.,250.,50.,-250.);
vec2 fpxy = abs(fract(waveXYZW.xy*20.0)-0.5)*2.0;

float d = amplitude*length(fpxy);

wave = cos(waveXYZW.x*waveXYZW.y+time) + 0.5 * cos(2.0*waveXYZW.x*waveXYZW.y+time) + 0.25 * cos(4.0*waveXYZW.x*waveXYZW.y+time);

return d*wave + d*(cos(waveXYZW.z*waveXYZW.w+time) + 0.5 * cos(2.0*waveXYZW.z*waveXYZW.w+time) + 0.25 * cos(4.0*waveXYZW.z*waveXYZW.w+time));

}
vec3 decode (vec2 enc)
{
    vec2 fenc = enc*4-2;
    float f = dot(fenc,fenc);
    float g = sqrt(1-f/4.0);
    vec3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}
float A = 0.22;
float B = 0.25;
float C = 0.10;
	float D = 0.3;
	float E = 0.03;
	float F = 0.4;

vec3 Uncharted2Tonemap(vec3 x) {

	/*--------------------------------*/
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void RotateDirection(inout vec2 Dir, in vec2 CosSin) {
    Dir = vec2(Dir.x * CosSin.x - Dir.y * CosSin.y,
                Dir.x * CosSin.y + Dir.y * CosSin.x);
}

//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
//////////////////////////////VOID MAIN//////////////////////////////
void main() {


	vec3 c = pow(texture2DLod(gaux1,texcoord,0).xyz,vec3(2.2))*257.;

	vec3 hr = texture2D(composite,(floor(texcoord*vec2(viewWidth,viewHeight)/2.)*2+1.0)/vec2(viewWidth,viewHeight)/2.0).rgb;

	float Depth2 = texture2D(depthtex0, texcoord).x;
	bool land2 = Depth2 < comp;

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
	vec4 sPos = gbufferProjectionInverse * (vec4(texcoord,Depth2,1.0) * 2.0 - 1.0);
	sPos /= sPos.w;
	sPos.xy *= mulfov;
#ifdef BANDINGFIX 
	hr.rgb = pow(hr.rgb,vec3(2.))*25.;
#else
	hr.rgb = hr.rgb*30.;
#endif
	
	if (!land2) c = hr.rgb;
	if (!land2 && isEyeInWater == 1) c = vec3(0.25,0.5,0.72)*rawAvg*0.1;
	if (land2){

	vec4 trp = texture2D(gaux3,texcoord.xy);
	bool transparency = dot(trp.xyz,trp.xyz) > 0.000001;

	float tmult = mix(min(abs(worldTime-6000.0)/6000.0,1.0),1.0,rainStrength);
	vec3 fogC = hr.rgb*(0.7+0.3*tmult)*(1.33-rainStrength*0.67);


	float fogF = FogF(sPos.xyz);
	
	if (transparency) {
	if (!land2) c = hr.rgb;
	vec3 normal = texture2D(gnormal,texcoord).xyz;
	float sky = normal.z;
	float sunVis = 1.0;

	bool iswater = sky < 0.2499;
	bool isice = sky > 0.2499 && sky < 0.4999;

	if (iswater) sky *= 4.0;
	if (isice) sky = (sky - 0.25)*4.0;

	if (!iswater && !isice) sky = (sky - 0.5)*4.0;

	sky = clamp(sky*1.2-2./16.0*1.2,0.,1.0);
	sky *= sky;

	normal = decode(normal.xy);

	bool reflective = dot(normal.xyz,normal.xyz) > 0.0;

	normal = normalize(normal);
	vec2 newtc = texcoord;

		if (iswater || isice) {
			vec3 wpos = (gbufferModelViewInverse*sPos).rgb;

			vec3 posxz = wpos+cameraPosition;
			float ft = iswater? frameTimeCounter*4.0:0.0;

			posxz.x += sin(posxz.z+ft)*0.25;
			posxz.z += cos(posxz.x+ft*0.5)*0.25;

			const float deltaPos = 0.4;
			float h0 = waterH(posxz,ft);
			float h1 = waterH(posxz - vec3(deltaPos,0.0,0.0),ft);
			float h2 = waterH(posxz - vec3(0.0,0.0,deltaPos),ft);

			float dX = ((h0-h1))/deltaPos;
			float dY = ((h0-h2))/deltaPos;



			vec3 refract = normalize(vec3(dX,dY,1.0));
			float refMult = sqrt(1.0-dot(normal,normalize(sPos.xyz))*dot(normal,normalize(sPos.xyz)))*0.005;

			newtc = texcoord.xy + refract.xy*refMult;
			vec3 mask = texture2D(gnormal,newtc).xyz;
			bool watermask = mask.z > 0.0;
			newtc = watermask? newtc : texcoord;
			c = pow(texture2DLod(gaux1,newtc,0).xyz,vec3(2.2))*257.;

		}
		#ifdef BANDINGFIX 
			vec3 samplehr = pow(texture2D(composite,(floor(newtc*vec2(viewWidth,viewHeight)/2.)*2+1.0)/vec2(viewWidth,viewHeight)/2.0).rgb,vec3(2.))*25.;
		#else
			vec3 samplehr = texture2D(composite,(floor(newtc*vec2(viewWidth,viewHeight)/2.)*2+1.0)/vec2(viewWidth,viewHeight)/2.0).rgb*30.;	
		#endif
			bool skyM = dot(c,vec3(1.0))<0.000001;
			if (skyM) c = samplehr.rgb;


		float Depth = texture2D(depthtex1, texcoord).x;
		vec4 fragpos = gbufferProjectionInverse * (vec4(texcoord,Depth,1.0) * 2.0 - 1.0);
		fragpos /= fragpos.w;
		fragpos.xy *= mulfov;
		
		float fogF2 = FogF(fragpos.xyz);


		 c = mix(c,fogC,fogF2-fogF);

		vec4 finalAc = texture2D(gaux2,texcoord.xy);
		vec4 rawAlbedo = trp;
		float alphaT = clamp(length(rawAlbedo.rgb)*1.02,0.0,1.0);
		rawAlbedo = rawAlbedo;


		c = mix(c,c*(rawAlbedo.rgb*0.9999+0.0001)*sqrt(3.0),alphaT)*(1.0-alphaT) + finalAc.rgb;




	if (reflective) {

		vec3 reflectedVector = reflect(normalize(fragpos.xyz), normal);
		vec3 hV= normalize(normalize(reflectedVector) + normalize(-fragpos.xyz));

		float normalDotEye = dot(hV, normalize(fragpos.xyz));

		float F0 = iswater? 0.2 : 0.1;
		//F0 *= !iswater? 1.5 : 0.0;



		float fresnel = pow(clamp(1.0 + normalDotEye,0.0,1.0), 4.0) ;
		fresnel = fresnel+F0*(1.0-fresnel);

		//vec3 reflectedVector = reflect(normalize(sPos.xyz), normal);
		vec3 sky_c = getSkyc(reflectedVector*620.)*1.7;


		vec4 reflection = raytrace(sPos.xyz, normal,sky_c,reflectedVector,mulfov);
		sky_c = (isEyeInWater == 0)? drawSun(reflectedVector,sky_c,sunVis)*sky : pow(vec3(0.25,0.5,0.72),vec3(2.2))*rawAvg*0.1;
		reflection.rgb = mix(sky_c, reflection.rgb, reflection.a);

		fresnel *= !iswater? 0.5 : 1.0;
		//fresnel*= !(iswater|| isice)? pow(max(1.0-alphaT,0.01),0.8) : 1.0;

		vec3 reflC = vec3(1.0);
		//reflC = (isice)? mix(normalize(rawAlbedo.xyz)*sqrt(3.0),reflC,0.7) : (!(iswater|| isice)? mix(normalize(rawAlbedo.xyz)*sqrt(3.0),reflC,0.75):reflC);

		c = mix(c,reflection.rgb,fresnel);

	}
	}
	
	c = mix(c,fogC*(1.0-isEyeInWater),fogF);
	if (isEyeInWater > 0.9) c = mix(c*0.4,vec3(0.25,0.5,0.72)*rawAvg*0.07,1.-exp(-length(sPos.xyz)/40));
	//c = vec3(fogF);
	}


	if (rainStrength > 0.01){
	vec4 rain = texture2D(gaux4,texcoord);
		if (rain.r > 0.0001) {
	float rainRGB = 0.25;
	float rainA = rain.r;

	float torch_lightmap 		= 6.4 - min(rain.g/rain.r * 6.16,5.6);
	torch_lightmap 		= 0.1 / torch_lightmap / torch_lightmap - 0.002595;

	vec3 rainC = rainRGB*(pow(max(dot(normalize(sPos.xyz),sunVec)*0.1+0.9,0.0),6.0)*(0.1+tr*0.9)*pow(sunlight,vec3(0.25))*sunVisibility+pow(max(dot(normalize(sPos.xyz),-sunVec)*0.05+0.95,0.0),6.0)*48.0*moonlight*moonVisibility)*0.04 + 0.05*rainRGB*length(avgAmbient2);
	rainC += torch_lightmap*vec3(1.0,0.4,0.04)*2.05/2.4;
	c = c*(1.0-rainA*0.3)+rainC*1.5*rainA;

	}

}

	float gr = 0.0;

	float illuminationDecay = pow(abs(dot(normalize(sPos.xyz),normalize(sunPosition.xyz))),30.0)+pow(abs(dot(normalize(sPos.xyz),normalize(sunPosition.xyz))),16.0)*0.8+pow(abs(dot(normalize(sPos.xyz),normalize(sunPosition.xyz))),2.0)*0.125;

	const float blurScale = 0.01;
	vec2 deltaTextCoord = (lightPos-texcoord)*blurScale;
	vec2 textCoord = texcoord/2.0+0.5;


			gr += texture2DLod(gaux1, textCoord + deltaTextCoord,1).a;
			gr += texture2DLod(gaux1, textCoord + 2.0 * deltaTextCoord,1).a;
			gr += texture2DLod(gaux1, textCoord + 3.0 * deltaTextCoord,1).a;
			gr += texture2DLod(gaux1, textCoord + 4.0 * deltaTextCoord,1).a;
			gr += texture2DLod(gaux1, textCoord + 5.0 * deltaTextCoord,1).a;
			gr += texture2DLod(gaux1, textCoord + 6.0 * deltaTextCoord,1).a;
			gr += texture2DLod(gaux1, textCoord + 7.0 * deltaTextCoord,1).a;

	vec3 grC = lightColor*exposure;
	c += grC*gr/7.*illuminationDecay*(1.0-isEyeInWater);

#ifdef BANDINGFIX 
c += pow(texture2D(composite,texcoord.xy*0.5+0.5+1.0/vec2(viewWidth,viewHeight)).rgb,vec3(2.))*fading*30*30/100*pow(dot(textureGather(gaux1,vec2(1.0)/vec2(viewWidth,viewHeight),3),vec4(0.25)),2.);
#else
c += texture2D(composite,texcoord.xy*0.5+0.5+1.0/vec2(viewWidth,viewHeight)).rgb*fading*30*30/100*pow(dot(textureGather(gaux1,vec2(1.0)/vec2(viewWidth,viewHeight),3),vec4(0.25)),2.);
#endif
//	color += rainlens*avgAmbient*0.01;
/*
	//c = vec3(texture2DLod(composite,texcoord,0).rgb);
	vec3 curr = Uncharted2Tonemap(c*(pow(eyeAdapt,0.4)*6.));

	c = pow(curr/Uncharted2Tonemap(vec3(20.)),vec3(1.0/2.2));
	*/
/* DRAWBUFFERS:3 */
#ifdef BANDINGFIX 
		c = pow(c/50.*pow(eyeAdapt,0.88),vec3(1./2.0));
#else
		c = c/50.*pow(eyeAdapt,0.88);
#endif

	gl_FragData[0] = vec4(c,1.0);
}
