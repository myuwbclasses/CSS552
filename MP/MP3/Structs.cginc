struct DataFromVertex
{
    float4 vertex : POSITION;
};

struct DataForFragmentShader
{
    float4 vertex : SV_POSITION;
};

struct OutputFromFragmentShader {
    float4 color : SV_Target;
};

#ifndef CONTROL_FLAGS
#define CONTROL_FLAGS
// MUST! Agree with the Enums in UserMatControl.cs

#define FLAG_IS_ON(f) (_UserControl & f)

// OC flags
#define OC_SHOW         0x01
#define OC_ANIMATED     0x02
#define OC_USE_VPOINT   0x04

// WC Flags
#define WC_SHOW         0x10
#define WC_ANIMATED     0x20
#define WC_USE_OCVPOINT 0x40

// EC Flags
#define EC_SHOW         0x100
#define EC_ANIMATED     0x200
#define EC_USE_OCVPOINT 0x400
#define EC_USE_WCVPOINT 0x080   // WATCH OUT!! this is stealing WC flag position!
#define EC_ONLY_Z       0x800

#define PC_SHOW         0x1000
#define PC_ANIMATED     0x2000
#define PC_USE_OCVPOINT 0x4000
#define PC_USE_WCVPOINT 0x8000

#define SHOW_ORIGINAL   0x100000
#endif //  CONTROL_FLAGS