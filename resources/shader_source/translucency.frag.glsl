//FRAGMENT SHADER
#version 400

//*** Uniform block definitions ************************************************

//*** Input ********************************************************************
in vec3 m_normal;   // set
in vec3 m_position; // set
in vec2 vsUV;       // set

//*** Output *******************************************************************
layout (location = 0) out vec4 fragcolor;

//*** Uniforms *****************************************************************
uniform sampler2D   diffuse_tex;        // set
uniform sampler2D   translucency_tex;   // set
uniform sampler2D   specular_tex;       // set
uniform sampler2D   normal_tex;         // set
uniform vec4        LightPosition;      // set
uniform float       Shininess;          // set
uniform float       tScale;             // set
uniform vec3        tAmbient;          // Ambient value, visible from all angles


//*** Functions ****************************************************************
// Normal mapping: calculate cotangents
// @source: http://www.thetenthplanet.de/archives/1180
mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv)
{
    // get edge vectors of the pixel triangle
    vec3 dp1 = dFdx( p );
    vec3 dp2 = dFdy( p );
    vec2 duv1 = dFdx( uv );
    vec2 duv2 = dFdy( uv );

    // solve the linear system
    vec3 dp2perp = cross( dp2, N );
    vec3 dp1perp = cross( N, dp1 );
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

    // construct a scale-invariant frame
    float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
    return mat3( T * invmax, B * invmax, 1.5 * N );
}

// Normal mapping:
// @source: http://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
vec3 perturb_normal( vec3 N, vec3 V, vec2 texcoord )
{
    // assume N, the interpolated vertex normal and
    // V, the view vector (vertex to eye)
    vec3 map = texture(normal_tex, vsUV).xyz;
    map = map * 255./127. - 128./127.;
    mat3 TBN = cotangent_frame(N, V, vsUV);
    return normalize(TBN * map);
}


vec3 ads(vec3 normal_comp)
{
    vec3 n = normalize( normal_comp );
    vec3 s = normalize( vec3( LightPosition ) - m_position );
    vec3 v = normalize( vec3( -m_position ) );
    vec3 h = normalize( v + s );

    return 1.0 * (texture(diffuse_tex, vsUV).rgb * max( dot(s, n), 0.0 )
               + texture(specular_tex, vsUV).rgb * pow( max( dot(h,n), 0.0 ),
                 Shininess ) );
}

// @source: http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
float lightAttenuation()
{
    float result, minLight, radius, a, b;
    minLight = 0.01;
    a = 0.8;
    b = 0.6;

//    Computing distance from light to fragment
    float dist = distance( vec3( LightPosition ), m_position );

//    https://www.desmos.com/calculator/nmnaud1hrw
    radius  = sqrt(1.0 / (b * minLight));
    result  = clamp(1.0 - dist/radius, 0.0, 1.0);
    result *= result;

    return result;
}

//@ source: http://de.slideshare.net/colinbb/colin-barrebrisebois-gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurfacescattering-look-7170855
vec3 translucencyFac(vec3 normal_comp, vec3 tEye)
{

    vec3  tFac;
    float lightAtt;     // Distance of Light influences the light-strenght
    float tPower;       // Value for direct translucency ( lightsource behind )
    float tDistortion;  // Subsurface Distortion ( shift the light vector )
    vec3  tThickness;   // Thickness Texturer

    lightAtt    =   lightAttenuation();
    tPower      =   4.0;
    tDistortion =   0.2;
    tThickness  =   texture(translucency_tex, vsUV).rgb;

    vec3 tLight = vec3( LightPosition ) + normal_comp * tDistortion;

//    Originally here is used saturate(), with glsl it will only work on NVIDIA
//    GPUs. So we rewrite this using clamp()
    float tDot  = pow( clamp( dot( tEye, -tLight ), 0.0, 1.0 ),tPower )
                    * tScale;
    vec3 tLT    = lightAtt * ( tDot + tAmbient ) * tThickness;

    return tLT;
}

//*** Main *********************************************************************
void main(void)
{
//    calculating the normal
    vec3 vsN    =   normalize(m_normal);
    vec3 vsV    =   normalize(m_position);
    vec3 vsPN   =   perturb_normal(vsN, vsV, vsUV);
    vec3 normal =   vsPN;

//    calculating eye-vector
    vec3 tEye   =   -m_position;

//    vec3 ambientColor = 1.0 * texture(translucency_tex, vsUV).rgb;

//    I.    Calculate the fragcolor with the shading model your coice
    vec3 pre_color = ads( normal );

//    II.   Derive the translucency factor by the translucency map
    vec3 transFac = translucencyFac( normal, tEye );

//    III.  Use this factor to brighten up (also change) the fragcolor
    pre_color += transFac;

//    IV.   Push it back to the pipeline
    fragcolor = vec4( pre_color, 1.0 );
}
