
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

float3 _Offset; // defined in the proper of the shader
int _ShowInOC;

v2f vert (appdata v)
{
    v2f o;
    float4 p;
    p = v.vertex;  // this is position in object space
    p.xyz += _Offset;

    if (_ShowInOC == 0)  // show in WC
        p = mul(unity_ObjectToWorld, p);  // objcet to world
    p = mul(UNITY_MATRIX_V, p);  // To view space
    p = mul(UNITY_MATRIX_P, p);  // to Projection 
    o.vertex = p;
    return o;
}

float4 frag (v2f i) : SV_Target
{
    return float4(0, 1, 0, 1);
}

#endif //  P2_INC