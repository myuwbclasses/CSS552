Shader "Unlit/EX3_Shader"
{
    // for fun or whatever ... defines
    //
    //   y = _Blend * (Ax^2 + Bx + C) + (1-Blend) * (Dz^2 + Ez + F)
    // 
    Properties
    {
        // X parameters
        _A("A (for X): ", Range(-5, 5)) = 1
        _B("B (for X): ", Range(-5, 5)) = 1
        _C("C (for X): ", Range(-5, 5)) = 0

        // Z parameters
        _D("D (for Z): ", Range(-5, 5)) = 1
        _E("E (for Z): ", Range(-5, 5)) = 1
        _F("F (for Z): ", Range(-5, 5)) = 0
        
        _Blend("Blending X and Z", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

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

                float _A, _B, _C, _D, _E, _F, _Blend; 

                v2f vert (appdata v)
                {
                    v2f o;
                    float4 p;
                    p = v.vertex;  // this is position in object space
                    
                    p = mul(unity_ObjectToWorld, p);  // objcet to world

                    // Now we are in WC, let's compute
                    
                    // Clampping: this is not efficient, but, the point is we can do this
                    p.y =       _Blend * (_A * p.x * p.x + _B * p.x + _C) + 
                          (1 - _Blend) * (_D * p.z * p.z + _E * p.z + _F);

                    
                    p = mul(UNITY_MATRIX_V, p);  // To view space
                    p = mul(UNITY_MATRIX_P, p);  // to Projection 
                    o.vertex = p;
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    return float4(0.9, 0.5, 0.6, 1);
                }
            ENDCG
        }

    }
}
