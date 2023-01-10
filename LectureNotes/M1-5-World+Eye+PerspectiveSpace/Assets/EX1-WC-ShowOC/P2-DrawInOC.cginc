
#ifndef P2_INC
#define P2_INC
#pragma vertex vert
#pragma fragment frag

#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
};

struct v2f
{
    float4 vertex : SV_POSITION;
};

int _ShowFlag;

v2f vert (appdata v)
{
    v2f o;
    float4 p;
    p = v.vertex;  // this is position in object space
    
    // p = mul(unity_ObjectToWorld, p);  // objcet to world
         // skipping the ObjectToWorld transform means 
         // p is still in OC, so, we are observing the 
         // object in OC space
         // 
    p = mul(UNITY_MATRIX_V, p);  // To view space
    p = mul(UNITY_MATRIX_P, p);  // to Projection 
    o.vertex = p;
    return o;
}

float4 frag (v2f i) : SV_Target
{
    if (!(_ShowFlag & 0x02))  // the 0x01 is BAD style!
        discard;

    return float4(0, 1, 0, 1);
}

#endif //  P2_INC