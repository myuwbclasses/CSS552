Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            float _Bumpiness;
            
            int _ShowFlag;  // 0 is off, 
            const static int kShowNormalAsColor = 0x01;
            const static int kShowTangentAsColor = 0x02;
            const static int kShowNormalMapAsColor = 0x04;
            const static int kUseOrgNormalNoColor = 0x08;
            const static int kUseOrgNormalWithColor = 0x10;
            const static int kUsePerturbedNormalNoColor = 0x20;
            const static int kUsePerturbedNormalWithColor = 0x40;

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
                o.nInWC = normalize(mul(v.normal, (float3x3) unity_WorldToObject)); // WC subtraction to get n direction in WC
                
                // Turns out, there is something known as Tangent
                o.tInWC = normalize(mul(v.tangent, (float3x3) unity_WorldToObject));

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                SHOW_ACTION(kShowNormalAsColor, float4(((0.5*i.nInWC)+0.5).xyz, 1.0))
                SHOW_ACTION(kShowTangentAsColor, float4(((0.5*i.tInWC)+0.5).xyz, 1.0))
                
                float4 nTex = tex2D(_NormalMap, i.uv);
                SHOW_ACTION(kShowNormalMapAsColor, float4(nTex.x*_Bumpiness, nTex.y*_Bumpiness, nTex.z, 1.0))
                
                nTex = (2.0 * nTex) - 1.0;  // color (0 to 1) to vector (-1 to +1)
                
                float3 n;
                float3 L;
                float nDotL;
                if (_LightType == 0)
                    L = normalize(_LightPosition - i.pInWC);
                else
                    L = _LightDirection;
                    
                float4 col = tex2D(_MainTex, i.uv);
                n = normalize(i.nInWC);
                nDotL = clamp(dot(n, L), 0, 1) * _LightColor * _LightStrength; // Original normal
                SHOW_ACTION(kUseOrgNormalNoColor, float4(nDotL, nDotL, nDotL, 1))
                SHOW_ACTION(kUseOrgNormalWithColor, col*nDotL) 

                float3 b = normalize(cross(i.nInWC, i.tInWC));  // bi-normal perpendicular to both normal and tangent
                n = normalize(nTex.x * i.tInWC * _Bumpiness + nTex.y * b * _Bumpiness + nTex.z * i.nInWC);  // new normal
                nDotL = clamp(dot(n, L), 0, 1) * _LightColor * _LightStrength;
                
                SHOW_ACTION(kUsePerturbedNormalNoColor, float4(nDotL, nDotL, nDotL, 1));
                
                // last option: kUsePerturbedNormalWithColor
                return nDotL * col;
            }
            ENDCG
        }
    }
}
