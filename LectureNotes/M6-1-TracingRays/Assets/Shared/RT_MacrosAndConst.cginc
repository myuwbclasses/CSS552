#ifndef RT_MACROS
#define RT_MACROS

// uint _ShaderMode; defined in MyPhone.cginc
static const uint kShowRTObjectInRed = 0x01 << 10;
static const uint kShowRTNormal = 0x01 << 11;
static const uint kShowSphereInBlue = 0x01 << 12;
static const uint kShowOnlySphereReflect = 0x01 << 13;
static const uint kShowTriangleInGreen = 0x01 << 14;
static const uint kShowOnlyTriangleReflect = 0x01 << 15;
static const uint kShowAmbient = 0x01 << 16;
static const uint kShowDiffuse = 0x01 << 17;
static const uint kShowSpecular = 0x01 << 18;
static const uint kShowReflectivity = 0x01 << 19;

static const uint kRayTraceShadow = 0x01 << 20;

static const float kReflectiveCode = 1.0;

static const int kSphereID = 0;
static const int kTriangleID = 1;

static const float kVeryFar = 9999999.0;

static const float kPushInNormal = 0.5;
static const float kTravelNotAsFar = 0.99;

#define IsActive(flag) (flag & _ShaderMode)

#define DEBUG_SHOW(flag, color) {   \
    if (IsActive(flag))             \
        return color;               \
}

#define CONDITION_DEBUG(cond, flag, color) {    \
    if (cond)                                   \
        DEBUG_SHOW(flag, color)                 \
}

#define IsReflective(p) (p.a == kReflectiveCode)

#endif // RT_MACROS