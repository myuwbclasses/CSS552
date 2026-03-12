#ifndef PHONG_DATA_STRUCT
#define PHONG_DATA_STRUCT

struct DataFromVertex
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct DataForFragmentShader
{
    float4 vertex : SV_POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
};

int _ShaderMode;
static const int kTexture = 1;
static const int kAmbient = 2;
static const int kDiffuse = 4;
static const int kSpecular = 8;
static const int kDistanceAtten = 16;
static const int kAngularAtten = 32;

static const int kIsReflective = 0x01 << 10;

inline int FlagIsOn(int flag) {
    return ((_ShaderMode & flag) != 0);
}

static const float eLightOff = 0.0;
static const float eDirectionalLight = 1.0;
static const float ePointLight = 2.0;
static const float eSpotLight = 3.0;

#endif // PHONG_DATA_STRUCT