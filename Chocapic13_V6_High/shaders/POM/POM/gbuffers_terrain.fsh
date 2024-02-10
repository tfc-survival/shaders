#version 400 compatibility
#extension GL_ARB_shader_texture_lod : enable 
/*
!! DO NOT REMOVE !!
This code is from Chocapic13' shaders
Read the terms of modification and sharing before changing something below please !
!! DO NOT REMOVE !!
*/
#define NORMAL_MAP_MAX_ANGLE 1.
#define POM
#define POM_MAP_RES 128.0
#define POM_DEPTH (1.0/10.0)
const float mincoord = 1.0/4096.0;
const float maxcoord = 1.0-mincoord;
const vec3 intervalMult = vec3(1.0, 1.0, 1.0/POM_DEPTH)/POM_MAP_RES * 1.0; 

const float MAX_OCCLUSION_DISTANCE = 22.0;
const float MIX_OCCLUSION_DISTANCE = 18.0;
const int   MAX_OCCLUSION_POINTS   = 50;
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

in vec4 normal;
varying float dist;
varying vec4 texcoord;
varying vec4 vtexcoordam; // .st for add, .pq for mul
varying vec4 vtexcoord;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 viewVector;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelView;



uniform sampler2D texture;
uniform sampler2D normals;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;
uniform int fogMode;
uniform int worldTime;
uniform float wetness;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;
vec2 dcdx = dFdx(vtexcoord.st*vtexcoordam.pq);
vec2 dcdy = dFdy(vtexcoord.st*vtexcoordam.pq);

vec4 readTexture(in vec2 coord)
{
	return texture2DGradARB(texture,fract(coord)*vtexcoordam.pq+vtexcoordam.st,dcdx,dcdy);
}

vec4 readNormal(in vec2 coord)
{
	return texture2DGradARB(normals,fract(coord)*vtexcoordam.pq+vtexcoordam.st,dcdx,dcdy);
}

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
	vec2 adjustedTexCoord = fract(vtexcoord.st)*vtexcoordam.pq+vtexcoordam.st;

	
	


if (dist < MAX_OCCLUSION_DISTANCE) {
		if ( viewVector.z < 0.0 && readNormal(vtexcoord.st).a < 0.99 && readNormal(vtexcoord.st).a > 0.01) 
	{
		vec3 interval = viewVector.xyz * intervalMult;
		vec3 coord = vec3(vtexcoord.st, 1.0);
		for (int loopCount = 0; 
				(loopCount < MAX_OCCLUSION_POINTS) && (readNormal(coord.st).a < coord.p);
				++loopCount) {
			coord = coord+interval;

		}
		if (coord.t < mincoord) {
			if (readTexture(vec2(coord.s,mincoord)).a == 0.0) {
				coord.t = mincoord;
				discard;
			}
		}		
		adjustedTexCoord = mix(fract(coord.st)*vtexcoordam.pq+vtexcoordam.st , adjustedTexCoord , max(dist-MIX_OCCLUSION_DISTANCE,0.0)/(MAX_OCCLUSION_DISTANCE-MIX_OCCLUSION_DISTANCE));
	}
	
	}
	
	vec3 frag2 = normal.xyz;
	
		vec3 bump = texture2DGradARB(normals, adjustedTexCoord, dcdx, dcdy).rgb*2.0-1.0;

		
		float bumpmult = NORMAL_MAP_MAX_ANGLE;
	
		bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);
		mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
								  tangent.y, binormal.y, normal.y,
						     	  tangent.z, binormal.z, normal.z);
			
			frag2 = normalize(bump * tbnMatrix)	;
	
vec4 albedo = texture2DGradARB(texture, adjustedTexCoord, dcdx, dcdy)*color;
vec4 cAlbedo = vec4(RGB2YCoCg(albedo.rgb),albedo.a);

bool pattern = (mod(gl_FragCoord.x,2.0)==mod(gl_FragCoord.y,2.0));
cAlbedo.g = (pattern)?cAlbedo.b: cAlbedo.g;
cAlbedo.b = normal.a;
/* DRAWBUFFERS:01 */

	gl_FragData[0] = cAlbedo;
	gl_FragData[1] = encode(frag2);
}