#version 330

layout(location = 0) out vec4 colorOut;
 
uniform sampler2D blurSampler;
uniform sampler2D maskSampler;

uniform ivec2 screenSize;


in vec2 blurUV;
in vec2 maskUV;

vec3 l = vec3(0.2126, 0.7152, 0.0722); 

float lum(vec4 col)
{
	return dot(l,col.rgb);
}

void main() 
{ 
	vec4 blur = texture(blurSampler,blurUV);
	//blured*=lum(blured);
	//vec4 mask= texture(maskSampler,maskUV);
	colorOut = blur;// * mask;
	//colorOut.xy = blurUV;
}