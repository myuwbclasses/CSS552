Shader "Unlit/EX2_Shader"
{
    Properties
    {
        _MaxHeight("Clamp Value", Range(0, 1)) = 0.8
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

                float _MaxHeight; // defined in the proper of the shader

                v2f vert (appdata v)
                {
                    v2f o;
                    float4 p;
                    p = v.vertex;  // this is position in object space
                    
                    // Clamp to the user specified height
                    p.y = clamp(p.y, -1, _MaxHeight);  // clamp is a cg function

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
            ENDCG
        }

    }
}
