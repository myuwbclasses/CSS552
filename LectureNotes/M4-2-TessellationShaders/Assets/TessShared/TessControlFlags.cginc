#ifndef TESS_CONTROL_FLAGS
#define TESS_CONTROL_FLAGS

// Info on the Camera and the display
float3 _CameraPos;
float3 _CameraDir;
float _ScreenWidth;
float _ScreenHeight;
float _FovY;

float3 _LightInfo; // in world space, and can be used as directional or point light depending on the flag
uint _Flag;
   
#define ModeIsSet(flag) ((_Flag & flag) != 0)

static const uint kDomainComputeHeight = 0x01 << 0;
static const uint kGeomComputeHeight = 0x01 << 1;

static const uint kNormalWithBC = 0x01 << 2; // Alternative is with slope approximation when doing height map
static const uint kNormalWithFormula = 0x01 << 3; // Normal is computed with the formula based on the height difference in u and v direction

// Hull shader control flags
static const uint kHullNormalOffset = 0x01 << 5; // OFfset by  world normal


static const uint kShowUnshadedTexture = 0x01 << 10;
static const uint kShowShadedTexture = 0x01 << 11;
static const uint kShowUV = 0x01 << 12;
static const uint kShowNormal = 0x01 << 13;
static const uint kShowLightDir = 0x01 << 14;
static const uint kShowNdotL = 0x01 << 15;
static const uint kShowVertexColor = 0x01 << 16;

static const uint kUseDirectionalLight = 0x01 << 20;
static const uint kUsePointLight = 0x01 << 21;

#endif // TESS_CONTROL_FLAGS