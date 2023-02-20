Shader "552/TwoLight-Diffuse-Shader"
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
            #define MAX_LIGHTS 2            // only supports 2 for now
            #define LIGHT_OFF 0
            #define LIGHT_ON  1

            float4 _MyLightPosition[MAX_LIGHTS];   // MUST be float4 as this is set by VectorArray
            float4 _MyLightColor[MAX_LIGHTS];
            float _MyLightFlag[MAX_LIGHTS];  // for now, 0 is off 1 is on, this can also be used to represent light type           
            
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

            // lgtIndex: index into the light arrays
            // n: normal at visible point (in WC)
            // wpt: pt to be shaded (in WC)
            float4 ComputeDiffuse(int lgtIndex, float3 n, float3 wpt) {
                float4 r = float4(0, 0, 0, 1);
                if (_MyLightFlag[lgtIndex] == LIGHT_ON) {  // light is on
                    float3 L = normalize(_MyLightPosition[lgtIndex].xyz - wpt);
                    float nDotl = max(0.0, dot(n, L));
                    r = _MyLightColor[lgtIndex] * nDotl;
                }
                return r;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = float4(0, 0, 0, 1);
                for (int lgt = 0; lgt < MAX_LIGHTS; lgt++) {
                    col += ComputeDiffuse(lgt, i.normal, i.worldPt);
                }

                col *= _Kd;
                
                if (FLAG_IS_SET(FLAG_SHOW_TEX))
                    col *= tex2D(_MyTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
