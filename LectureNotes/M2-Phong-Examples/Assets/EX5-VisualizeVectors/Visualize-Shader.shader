Shader "552/Visualize-Shader"
{
    Properties
    {
        _Boost("Boost", Range(0.5, 2.0)) = 1.0
        _Shift("Shift", Range(-1.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;   // in OC
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 worldPt : TEXCOORD1;  // in WC
                float3 normal : NORMAL;      // in WC
            };

            float _Boost;
            float _Shift;

            // Per-Scene information: set by SceneControl.cs (only one of this in the Scene)
            //    CNANOT be in "Properties"
            //    Individual object should NOT set this
            float3 _MyLightPos;
            float3 _CameraPos;   // main camera position
            int _Flag;  // control of what to render and what not

            #define FLAG_IS_SET(f)  (_Flag & f)
            static const int kShow_V = 1 << 0; // 1 shift left by 0
            static const int kShow_L = 1 << 1;
            static const int kShow_N = 1 << 2;
            static const int kShow_H = 1 << 3;
            static const int kShow_NL = 1 << 4;
            static const int kShow_NH = 1 << 5;
            static const int kShow_VH = 1 << 6;             
            static const int kShow_NV = 1 << 7;
            static const int kShow_NHNV= 1 << 8;
            static const int kShow_NHNL = 1 << 9;

            v2f vert (appdata v) {
                v2f o;
                float4 p = v.vertex;
                p = mul(unity_ObjectToWorld, p);
                o.worldPt = p.xyz;  // world point for computing illumination
                p = mul(UNITY_MATRIX_V, p);
                p = mul(UNITY_MATRIX_P, p);
                o.vertex = p;

                // now work on the normal
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                return o;
            }

            #define DotNL   (max(0.0, dot(N, L)))
            #define DotNH   (max(0.0, dot(N, H)))
            #define DotVH   (max(0.0, dot(V, H)))
            #define DotNV   (max(0.0, dot(N, V)))
            #define DotNHNV (DotNH*DotNV)
            #define DotNHNL (DotNH*DotNL)

            #define ShowVector(flag)                \
                if (FLAG_IS_SET(kShow_##flag))      \
                    r = flag;                   

            #define ShowDot(flag)                           \
                if (FLAG_IS_SET(kShow_##flag)) {            \
                    float v = _Shift + _Boost * Dot##flag;  \
                    r = float3(v, v, v);                    \
                }

            float4 frag (v2f i) : SV_Target
            {
                
                // compute diffuse term
                float3 L = normalize(_MyLightPos - i.worldPt); // from worldPt towards the light
                float3 V = normalize(_CameraPos - i.worldPt);
                float3 N = i.normal;
                float3 H = (L + V) * 0.5;

                float3 r = float3(0, 0, 0);

                ShowVector(V)
                ShowVector(L)
                ShowVector(N)
                ShowVector(H)

                ShowDot(NL)
                ShowDot(NH)
                ShowDot(VH)
                ShowDot(NV)
                ShowDot(NHNV)
                ShowDot(NHNL)

                return float4(r, 1);
            }
            ENDHLSL
        }
    }
}
