Shader "Unlit/BumpShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // Blend SrcAlpha OneMinusSrcAlpha

        Cull off

        Pass
        {
            CGPROGRAM
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 pInWC : TEXCOORD1;
                float3 nInWC : TEXCOORD2;
                float3 tInWC : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float _BumpinessU;
            float _BumpinessV;
            
            int _ShowFlag;  // 0 is off, 
            const static int kShowNormalAsColor = 0x01;
            const static int kShowTangentAsColor = 0x02;
            const static int kShowNormalMapAsColor = 0x04;
            const static int kUseOrgNormalNoColor = 0x08;
            const static int kUseOrgNormalWithColor = 0x10;
            const static int kUsePerturbedNormalNoColor = 0x20;
            const static int kUsePerturbedNormalWithColor = 0x40;
            const static int kReplaceNormalByMap = 0x80;

            #define SHOW_ACTION(FLAG, ACT) {    \
                if (FLAG&_ShowFlag)             \
                    return ACT;                 \
            }

            int _LightType;
            float3 _LightPosition;
            float3 _LightDirection;
            float3 _LightColor;
            float  _LightStrength;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.pInWC = mul(unity_ObjectToWorld, v.vertex);

                // This is normal
                o.nInWC = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
                
                // Turns out, there is something known as Tangent
                o.tInWC = normalize(mul(v.tangent, (float3x3) unity_WorldToObject));

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                SHOW_ACTION(kShowTangentAsColor, float4(((0.5*i.tInWC)+0.5).xyz, 1.0))
                
                float4 nTex = tex2D(_NormalMap, i.uv);

                // Remember, in our normal map (and many)
                // assumption is Z is up in object space
                nTex.x = nTex.x * _BumpinessU;
                nTex.y = nTex.y * _BumpinessV;
                SHOW_ACTION(kShowNormalMapAsColor, float4(((0.5*nTex)+0.5).xzy, 1.0))
                                                    // Note: zy switched  ^^^^
                
                float3 n = normalize(i.nInWC);
                SHOW_ACTION(kShowNormalAsColor, float4(((0.5*n)+0.5).xyz, 1.0))

                float3 L;
                if (_LightType == 0)
                    L = normalize(_LightPosition - i.pInWC);
                else
                    L = _LightDirection;
                    
                float nDotL = clamp(dot(n, L), 0, 1) * _LightColor * _LightStrength; // Original normal
                SHOW_ACTION(kUseOrgNormalNoColor, float4(nDotL, nDotL, nDotL, 1))

                float4 col = tex2D(_MainTex, i.uv);
                SHOW_ACTION(kUseOrgNormalWithColor, col*nDotL) 

                if (_ShowFlag & kReplaceNormalByMap) {
                    nTex = (2.0 * nTex) - 1.0;  // color (0 to 1) to vector (-1 to +1)
                    n = normalize(mul(nTex, (float3x3) unity_WorldToObject));
                        // use nTex as the actual normal
                        // nTex is assumed to be in object space
                    // swap y and z: most unity objects assume y is up
                    float t = n.y;
                    n.y = n.z;
                    n.z = t;
                } else  {
                    float3 b = normalize(cross(i.nInWC, i.tInWC));  // bi-normal perpendicular to both normal and tangent
                    n = normalize(-nTex.x * i.tInWC + nTex.z * i.nInWC - nTex.y * b);  // new normal
                                // notice, y is used for bi-Normal
                                //         z is used as up
                }
                nDotL = clamp(dot(n, L), 0, 1) * _LightColor * _LightStrength;
                
                SHOW_ACTION(kUsePerturbedNormalNoColor, float4(nDotL, nDotL, nDotL, 1));
                
                // last option: kUsePerturbedNormalWithColor
                return nDotL * col;
            }
            ENDCG
        }
    }
}
