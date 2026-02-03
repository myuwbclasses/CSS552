#ifndef FogInclude
#define FogInclude

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
};

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    return o;
}

sampler2D _MainTex;
sampler2D _DepthTexture;   // from our own DepthShader

// Fog specifics
float _extinctionCoefficient;   // extinction coefficient (or density)
float4 _fogColor;
float _fogScattering;  // scattering coefficient

float3 V1_center; // The spherical volumes
float  V1_radius;

float3 _FogLightPos; // Position of light source

// For fog modes and debugging
uint _flag;
static const uint kShowDebugNoVolume = 1;
static const uint kShowDebugDepth = 2;
static const uint kShowVisibleVolumeDepth = 3;
static const uint kShowDebugTrAlongRay = 4;
static const uint kShowDebugTrToLight = 5;
static const uint kShowObjColorWithFogTr = 6;
static const uint kShowFogColor = 7;

static const uint kVeryFar = 200;  // when sees background through volume, assume far

static const float kDepthScale = 0.05; // for visualizing depth
#define DEBUG_DEPTH {                                                   \
    if (_flag == kShowDebugDepth)   {                                   \
        if (d <= 0) /* background  */                                   \
            return float4(0, 1, 0, 1);                                  \
        return float4(kDepthScale*d, kDepthScale*d, kDepthScale*d, 1);  \
    }                                                                   \
}
    

#define CHECK_DEBUG(FLAG, DEBUG_ACTION) {    \
    if (_flag == FLAG) {                     \
        return  DEBUG_ACTION;                \
    }                                        \
}

#endif