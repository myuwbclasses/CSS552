#ifndef P1_INC
#define P1_INC
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

v2f vert (appdata v)
{
    v2f o;
    float4 p;
    p = v.vertex;  // this is position in object space
    p = mul(unity_ObjectToWorld, p);  // objcet to world
    p = mul(UNITY_MATRIX_V, p);  // To view space
    p = mul(UNITY_MATRIX_P, p);  // to Projection 
    o.vertex = p;
    return o;
}

float4 frag (v2f i) : SV_Target
{
    return float4(1, 0, 0, 1);
}

#endif //  P1_INC