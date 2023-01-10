Shader "Unlit/EX5_Shader"
{
    Properties
    {
        _ShowFlag("Show Original: 0(None) 1(WC)", Integer) = 1
        _Offset("Offset (EC): ", Vector) = (0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // Cull off
        // Try setting this on/off to observe near plane clipping
    
        Pass
        {
            CGPROGRAM
                #include "../EX1-WC-ShowOC/P1-DrawInWC.cginc"
            ENDCG
        }
        Pass  // Examine the EC Space
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

                float3 _Offset;

                v2f vert (appdata v)
                {
                    v2f o;
                    float4 p;
                    p = v.vertex;  // this is position in object space
                    
                    p = mul(unity_ObjectToWorld, p);  // objcet to world
                    p = mul(UNITY_MATRIX_V, p);  // To view space

                    // now, we are in EC Space
                    p.xyz += _Offset.xyz;

                    p = mul(UNITY_MATRIX_P, p);  // to Projection 
                    o.vertex = p;
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    return float4(0, 1, 0, 1);
                }
            ENDCG
        }

    }
}
