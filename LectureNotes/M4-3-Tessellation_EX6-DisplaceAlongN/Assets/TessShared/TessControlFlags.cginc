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

static const uint kXShowHeight = 0x01 << 1;
static const uint kZShowHeight = 0x01 << 2;

// X/Z function control
static const uint kXAxisIsSine = 0x01 << 3;
static const uint kZAxisIsSine = 0x01 << 4;

static const uint kDebugShowXHeightChange = 0x01 << 5;
static const uint kDebugShowZHeightChange = 0x01 << 6;

static const uint kApplyScreenSpace = 0x01 << 7;
static const uint kApplyOC = 0x01 << 8;

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