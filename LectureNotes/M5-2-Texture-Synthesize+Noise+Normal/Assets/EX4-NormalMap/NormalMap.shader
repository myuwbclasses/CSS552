Shader "Unlit/NormalMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Bumpiness("Bumpiness", Range(-2, 2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // Blend SrcAlpha OneMinusSrcAlpha

        Cull off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                
                float3 nInOC : TEXCOORD1;  // position in object space
                float3 pInWC : TEXCOORD2;
                float3 nInWC : TEXCOORD3;
                float3 tInOC : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            float _Bumpiness;
            
            int _LightType;
            float3 _LightPosition;
            float3 _LightDirection;
            float  _LightStrength;
            float4 _LightColor;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pInWC = mul(unity_ObjectToWorld, v.vertex);
                o.nInWC = normalize(mul(v.normal, (float3x3) unity_WorldToObject));

                o.nInOC = v.normal;
                o.tInOC = v.tangent;
                return o;
            }

            int _ShowFlag;  // 0 is off,
            
            const static int kShowNAsColorInOC = 0x01 << 0;
            const static int kShowNdotL = 0x01 << 1;
            const static int kShowUnShadedColor = 0x01 << 2;
            const static int kShowShadedColor = 0x01 << 3;
            
            const static int kUseNormalMap = 0x01 << 10;
            const static int kUseNTB = 0x01 << 11;

            #define MAPPED      (kUseNormalMap & _ShowFlag)
            #define APPLY_NTB   (kUseNTB & _ShowFlag)

            #define SHOW_ACTION(FLAG, ACTN, ACTNTB, ACT) {  \
                if (FLAG&_ShowFlag)                         \
                    if (MAPPED) {                           \
                        if (APPLY_NTB)                      \
                            return ACTNTB;                  \
                        else                                \
                            return ACTN;                    \
                    } else                                  \
                        return ACT;                         \
            }

            #define NORM_AS_COLOR(n) float4(((0.5*n)+0.5).xyz, 1.0)
            #define FLT_AS_COLOR(f) float4(f, f, f, 1.0)

            float4 frag (v2f i) : SV_Target
            {                
                float3 L;
                if (_LightType == 0)
                    L = normalize(_LightPosition - i.pInWC);
                else
                    L = _LightDirection;      
                
                float4 col = tex2D(_MainTex, i.uv);
                SHOW_ACTION(kShowUnShadedColor, col, col, col)

                float4 nTex = tex2D(_NormalMap, i.uv);

                nTex = (2.0 * nTex) - 1.0;  // color (0 to 1) to vector (-1 to +1)
                nTex.xyz = nTex.xzy;
                    // In many normal map assumption is Z is up in object space
                nTex.xz = nTex.xz * _Bumpiness;
                nTex = normalize(nTex);

                float3 biN = cross(i.tInOC, i.nInOC);  
                // nTex is in oc, with the assumotion that normal is (0, 0, 1) in oc
                float3 ntb = normalize(nTex.x * i.tInOC + nTex.y * i.nInOC + nTex.z * biN);
                    // In reality, the signs (direciton) of tangent and bi-normal can be 
                    // tricky, in this case, I rotate the directionaly light and examined the
                    // slopped surfaces on the plane
                SHOW_ACTION(kShowNAsColorInOC, NORM_AS_COLOR(nTex), NORM_AS_COLOR(ntb), NORM_AS_COLOR(i.nInWC))

                ntb = normalize(mul(ntb, (float3x3) unity_WorldToObject));
                float3 n = normalize(mul(nTex, (float3x3) unity_WorldToObject));
                
                float nDotL = clamp(dot(i.nInWC, L), 0, 1) * _LightColor * _LightStrength;
                float nTexDotL = clamp(dot(nTex, L), 0, 1) * _LightColor * _LightStrength;
                float ntbDotL = clamp(dot(ntb, L), 0, 1) * _LightColor * _LightStrength;
                
                SHOW_ACTION(kShowNdotL, FLT_AS_COLOR(nTexDotL), FLT_AS_COLOR(ntbDotL), FLT_AS_COLOR(nDotL))

                SHOW_ACTION(kShowShadedColor, col*nTexDotL, col*ntbDotL, col*nDotL)
                return col;
            }
            ENDHLSL
        }
    }
}
