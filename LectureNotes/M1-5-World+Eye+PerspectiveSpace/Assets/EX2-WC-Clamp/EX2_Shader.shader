Shader "Unlit/EX2_Shader"
{
    Properties
    {
        _ClampFlag("Clamp Flag (0-no 1-x 2-y 4-z)", Integer) = 0      
            // 0x00 no clamp
            // 0x01 is Clamp X
            // 0x02 is Clamp Y
            // 0x04 is Clamp Z
        _ClampValue("Clamp Value", Range(-15, 15)) = 15
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
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

                float _ClampValue; 
                int _ClampFlag;

                #define NO_CLAMP    0x00
                #define CLAMP_X     0x01
                #define CLAMP_Y     0x02
                #define CLAMP_Z     0x04

                #define FLAG_IS_SET(f) (_ClampFlag & f)

                    // backslash says macro continues
                    // AVOID putting anything other than code in a Macro
                    // e.g., I would avoid putting comments in the macro
                #define CLAMP_THIS(v, flag)             \ 
                    if (FLAG_IS_SET(flag))              \
                        v = clamp(v, -_ClampValue, _ClampValue);

                v2f vert (appdata v)
                {
                    v2f o;
                    float4 p;
                    p = v.vertex;  // this is position in object space

                    p = mul(unity_ObjectToWorld, p);  // objcet to world

                    // Clampping: this is not efficient, but, the point is we can do this
                    CLAMP_THIS(p.x, CLAMP_X)  
                    CLAMP_THIS(p.y, CLAMP_Y)  
                    CLAMP_THIS(p.z, CLAMP_Z)

                    p = mul(UNITY_MATRIX_V, p);  // To view space
                    p = mul(UNITY_MATRIX_P, p);  // to Projection 
                    o.vertex = p;
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    return float4(0, 0, 1, 1);
                }
            ENDCG
        }

    }
}
