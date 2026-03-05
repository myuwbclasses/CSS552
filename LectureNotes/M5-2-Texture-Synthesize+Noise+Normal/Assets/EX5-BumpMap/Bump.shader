Shader "Unlit/BumpShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShowFlag("Show Flag", Int) = 0
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
                
                float3 pInWC : TEXCOORD1;
                float3 nInWC : TEXCOORD2;

                float3 oInOC : TEXCOORD3;  // position in object space
                float3 tInOC : TEXCOORD4;
                float3 nInOC : TEXCOORD5;  // normal in object space
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _DuDistance;
            float _DvDistance;
            float _BumpinessU;
            float _BumpinessV;
            
            int _ShowFlag;  // 0 is off, 
            const static int kShowNormalAsColor = 0x01 << 0;
            const static int kShowNdotL = 0x01 << 1;
            const static int kShowUnShadedColor = 0x01 << 2;
            const static int kShowShadedColor = 0x01 << 3;

            const static int kUseBumppedNormal = 0x01 << 10; 
            
            #define BUMPPED     (kUseBumppedNormal & _ShowFlag)

            #define SHOW_ACTION(FLAG, ACTN, ACT) {          \
                if (FLAG&_ShowFlag)                         \
                    if (BUMPPED)                            \
                        return ACTN;                        \
                     else                                   \
                        return ACT;                         \
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
                
                // forward tangent and normal in object space to fragment shader, for later use
                o.oInOC = v.vertex.xyz;
                o.tInOC = v.tangent;
                o.nInOC = v.normal;

                return o;
            }

            float ColorToHeight(float4 c) {
                return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b; // Convert to grayscale using luminosity method
                // https://en.wikipedia.org/wiki/Grayscale#:~:text=Grayscale%20images%2C%20are%20black%2Dand%2Dwhite%20or,to%20white%20at%20the%20strongest.
            }

            #define NORM_AS_COLOR(n) float4(((0.5*n)+0.5).xyz, 1.0)
            #define FLT_AS_COLOR(f) float4(f, f, f, 1.0)

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                SHOW_ACTION(kShowUnShadedColor, col, col)
                float myHeight = ColorToHeight(col);

                // https://dl.acm.org/doi/epdf/10.1145/965139.507101
                //
                // for now _BumpinessU and _BumpinessV are percentage of UV map used
                // 1 is 1%, or 0.01 in UV space
                float3 biNormal = normalize(cross(i.nInOC, i.tInOC));  // bi-normal perpendicular to both normal and tangent
                float du = _DuDistance * 0.01;
                float dv = _DvDistance * 0.01;
                float l = ColorToHeight(tex2D(_MainTex, i.uv + float2(du, 0)));
                float r = ColorToHeight(tex2D(_MainTex, i.uv - float2(du, 0)));
                float u = ColorToHeight(tex2D(_MainTex, i.uv + float2(0, dv)));
                float d = ColorToHeight(tex2D(_MainTex, i.uv - float2(0, dv)));

                float3 center = i.oInOC + i.nInOC * myHeight;  // position of center in object space
                float3 Pl = i.oInOC + du * i.tInOC + _BumpinessU * l * i.nInOC;  // position of right neighbor in object space
                float3 Pr = i.oInOC - du * i.tInOC + _BumpinessU * r * i.nInOC;  // position of left neighbor in object space
                float3 Pu = i.oInOC + dv * biNormal + _BumpinessV * u * i.nInOC;  // position of up neighbor in object space
                float3 Pv = i.oInOC - dv * biNormal + _BumpinessV * d * i.nInOC;  // position of down neighbor in object space
                float3 n = normalize(cross(Pl - Pr, Pu - Pv));  // new normal in object space, using cross product of two vectors on the surface

                float3 L;
                if (_LightType == 0)
                    L = normalize(_LightPosition - i.pInWC);
                else
                    L = _LightDirection;
                
                SHOW_ACTION(kShowNormalAsColor, NORM_AS_COLOR(n), NORM_AS_COLOR(i.nInOC))

                // Transform from OC to WC
                n = normalize(mul(n, (float3x3) unity_WorldToObject));

                float nDotL = clamp(dot(i.nInWC, L), 0, 1) * _LightColor * _LightStrength; // Original normal
                float nbDotL = clamp(dot(n, L), 0, 1) * _LightColor * _LightStrength; // Bumped normal
                SHOW_ACTION(kShowNdotL, FLT_AS_COLOR(nbDotL), FLT_AS_COLOR(nDotL))

                // this is last: kShowShadedColor
                SHOW_ACTION(kShowShadedColor, col*nbDotL, col*nDotL)

                return col;
            }
            ENDHLSL
        }
    }
}
