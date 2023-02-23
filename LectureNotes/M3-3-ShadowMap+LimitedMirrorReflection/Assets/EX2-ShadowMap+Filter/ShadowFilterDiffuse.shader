Shader "Unlit/ShadowFilterDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 lightNDC : TEXCOORD2;  // uv in light space
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            sampler2D _ShadowMap;
            float _DepthBias;
            float _NormalBias;
            float4x4 _WorldToLightNDC;

            // These two are defined by the ShadowMap resolution and 
            //    should be pushed from the editor-script
            static const float kInvWidth = 1.0/2048.0;      // 2048x2048 is the shadow map resolution
            static const float kInvHeight = 1.0/2048.0;
            
            // For debugging
            uint _MapFlag;
            float _DebugDistScale;  // to scale down distance for drawing
            static const int kShowMapDistance = 0x01;
            static const int kShowMapDistanceWithBias = 0x02;
            static const int kShowLightDistance = 0x04;
            static const int kFilter3 = 0x40;
            static const int kFilter5 = 0x80;
            static const int kFilter9 = 0x100;
            static const int kFilter15 = 0x200;

            #define V_TO_F4(V) float4(V,V,V,1)

            #define DEBUG_SHOW(FLAG, VALUE, SCALE) {        \
                if (_MapFlag & FLAG) {                      \
                    return (VALUE * SCALE);                 \
                }                                           \
            }

            float4 _LightPos;

            v2f vert (appdata v)
            {
                v2f o;
                float4 p = mul(unity_ObjectToWorld, v.vertex);  // objcet to world

                // For ShadowMap
                p.xyz = p.xyz + _NormalBias * v.normal; // push the position out of the surface a little

                o.worldPos = p.xyz;  // p.w is 1.0 at this poit

                p = mul(UNITY_MATRIX_V, p);  // To view space
                o.vertex = mul(UNITY_MATRIX_P, p);  // Projection 
                            
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                o.uv = v.uv;

                // compute for shadow
                float4 lNDC = mul(_WorldToLightNDC, float4(o.worldPos, 1));
                o.lightNDC = lNDC.xy / lNDC.w; // light NDC, -1 to 1
                o.lightNDC = (o.lightNDC + 1) * 0.5; // conver to 0 to 1
                return o;
            }

            // d - distance to light
            // uv - uv locaiton to read from
            bool InShadow(float d, float2 uv) {
                return (d > (tex2D(_ShadowMap, uv).a + _DepthBias));
            }

            #include "./ShadowKernel.cginc"
            INSHADOW_SIZE(3)
            INSHADOW_SIZE(5)
            INSHADOW_SIZE(9)
            INSHADOW_SIZE(15)

            float LightStrength(float d, float2 uv) {
                float blocked = 0;
                if (_MapFlag & kFilter3) blocked = InShadow_3(d, uv);
                else if (_MapFlag & kFilter5) blocked = InShadow_5(d, uv);
                else if (_MapFlag & kFilter9) blocked = InShadow_9(d, uv);
                else if (_MapFlag & kFilter15) blocked = InShadow_15(d, uv);
                else blocked = InShadow(d, uv) ? 1 : 0;
                return 1-blocked;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = float4(0.9, 0.7, 0.7, 1.0);
                if ((i.uv.x != 0) && (i.uv.y != 0))
                    col = tex2D(_MainTex, i.uv);
                float3 L = _LightPos - i.worldPos;
                float distToLight = length(L);
                L = L / distToLight;  // normalize L
                float NdotL = max(dot(i.normal, L), 0);

                // now, we are being illuminated by the light ... 
                DEBUG_SHOW(kShowLightDistance, V_TO_F4(distToLight), _DebugDistScale)
                // now, let's do shadow compuration
                float4 wcPt = tex2D(_ShadowMap, i.lightNDC);
                float distFromMap = wcPt.a;  // this is distance
                DEBUG_SHOW(kShowMapDistance, V_TO_F4(distFromMap), _DebugDistScale)          
                
                distFromMap += _DepthBias;  // push slightly outward to avoid self-shadowing
                DEBUG_SHOW(kShowMapDistanceWithBias, V_TO_F4(distFromMap), _DebugDistScale)
                                
                NdotL *= LightStrength(distToLight, i.lightNDC);            

                return float4(0.1, 0.1, 0.1, 0) + (col * NdotL);  // so will not be completely black
            }
           
            ENDCG
        }
    }
}
