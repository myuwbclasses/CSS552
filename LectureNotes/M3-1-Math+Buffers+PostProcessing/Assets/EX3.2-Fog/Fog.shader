Shader "Unlit/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // this is the src of Blit
    }
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

           struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _wcScale;   // approximated mapping from NDC to WC

            // Fog specifics
            float _fogDensity;   // extinction coefficient (or density)
            float4 _fogColor;
            float _n, _f;
            sampler2D _CameraDepthTexture;   // assume Camera.depthTextureMode is DepthTextureMode.Depth

            // For fog modes and debugging
            uint _flag;
            static const int kShowDebugNear = 1;
            static const int kShowDebugDistance = 2;
            static const int kShowDebugBlend = 4;

            #define CHECK_DEBUG(FLAG, DEBUG_ACTION) {   \
                if (_flag & FLAG)                       \
                    c1 = DEBUG_ACTION;                  \
            }
            
            // https://learn.microsoft.com/en-us/windows/win32/direct3d9/fog-formulas
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 x = tex2D(_CameraDepthTexture, fromV.uv);

                float nd = _f - _n;
                float d = (1-x.r) * _wcScale;

                if (d < _n) {
                    CHECK_DEBUG(kShowDebugNear, float4(1, 0, 0, 1))
                    return c1;  
                }

                d = (d - _n) / nd;
                float blend = exp(-_fogDensity * d);
                c1 = c1 * blend + _fogColor * (1-blend);

                CHECK_DEBUG(kShowDebugDistance, float4(d, d, d, 1))
                CHECK_DEBUG(kShowDebugBlend, float4(blend, blend, blend, 1))

                return c1;
            }
            ENDCG
        }
    }
}
