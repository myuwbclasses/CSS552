Shader "552/Diffuse-Shader"
{
    Properties
    {
        _MyTex ("MyText", 2D) = "white" {}
        _Kd("Kd", Color) = (1, 1, 1, 1)
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

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;   // in OC
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPt : TEXCOORD1;  // in WC
                float3 normal : NORMAL;      // in WC
            };

            sampler2D _MyTex;
            float4 _MyTex_ST;  // decleared by default by Unity 
            
            float4 _Kd;     // Diffuse constant for the object

            // Per-Scene information: set by SceneControl.cs (only one of this in the Scene)
            //    CNANOT be in "Properties"
            //    Individual object should NOT set this
            float3 _MyLightPos;
            int _Flag;  // control of what to render and what not

            #define FLAG_IS_SET(f)  (_Flag & f)
            #define FLAG_NONE       0x00    // nothing
            #define FLAG_SHOW_TEX   0x01    // switch on texture

            v2f vert (appdata v) {
                v2f o;
                float4 p = v.vertex;
                p = mul(unity_ObjectToWorld, p);
                o.worldPt = p.xyz;  // world point for computing illumination
                p = mul(UNITY_MATRIX_V, p);
                p = mul(UNITY_MATRIX_P, p);

                o.uv = TRANSFORM_TEX(v.uv, _MyTex);  // for texture placement
                o.vertex = p;

                // now work on the normal
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                // compute diffuse term
                float3 L = normalize(_MyLightPos - i.worldPt); // from worldPt towards the light
                float nDotl = max(0.0, dot(i.normal, L));

                float4 col = _Kd * nDotl;  // one term in the phone illumination

                if (FLAG_IS_SET(FLAG_SHOW_TEX))
                    col *= tex2D(_MyTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
