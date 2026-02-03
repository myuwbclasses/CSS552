Shader "MyShaders/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // this is the src of Blit
        _DepthTexture ("Texture", 2D) = "white" {}
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

            // Fog specifics
            float _extinctionCoefficient;   // extinction coefficient (or density)
            float4 _fogColor;
            float _fogScattering;  // scattering coefficient
            float _n, _f;
            sampler2D _DepthTexture;   // from our own DepthShader

            // hack to support longer distance
            float _fogHeight;

            // For fog modes and debugging
            uint _flag;
            static const uint kShowDebugOff = 0;
            static const uint kShowDebugHideFog = 1 << 1;
            static const uint kShowDebugDepth = 1 << 2;
            static const uint kShowDebugNearFar = 1 << 3;
            static const uint kShowDebugtransmittance = 1 << 4;
            static const int kShowDebugColorFromFog = 1 << 5;
            
            
            #define FLAG_IS_SET(FLAG) ((_flag & FLAG) != 0)

            #define CHECK_DEBUG(FLAG, DEBUG_ACTION) {   \
                if FLAG_IS_SET(FLAG)                    \
                    return DEBUG_ACTION;                \
            }

            // This is implemenation of Parker's Slide-17
            // Assuming: 
            //     sigma-t is extinctionCoefficient: a constant so can take out of the integral
            //     POTENTIAL ISSUE: we don't have units, so, instead of distance, we have a ratio
            float TransmittanceAtD(float d) {
                float delta = d - _n;  // delta of (8) with n == 1
                delta /= (_f - _n); 
                return exp(-delta*_extinctionCoefficient);
            }

            // 
            // Attempt to implement Slide-11 in eye space
            // 
            //    Lo is what we read from the texture map (color of visible object)
            //    Tr(c,p) is TransmittanceAtD(interval-in-volume)
            //            Take the distance from d (depth map) to the _n (near plane)
            //    Approximate for within the integral
            //      Tr(c,c-vt): assume to be simply 1-Tr(c,p)
            //      Lscat is assumed to be 1.0 for now 
            //   
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 x = tex2D(_DepthTexture, fromV.uv);

                CHECK_DEBUG(kShowDebugHideFog, c1)
                    
                if (x.y > _fogHeight)
                    return c1;      // this is NOT good because this will create hard edges
                                    // some form of gradual fading would be better

                float d = x.a;  //  remember our DepthShader records distance to camera in the alpha channel

                if (FLAG_IS_SET(kShowDebugDepth)) {    // normalize depth for display
                    if (d <= 0)      // this should not happen
                        return float4(0, 1, 0, 1);   // Green for alert
                    float depthNormalized = (d - _n) / (_f - _n);
                    if (depthNormalized < 1)
                        return float4(depthNormalized, depthNormalized, depthNormalized, 1);
                    else
                        return float4(1, 0, 0, 1);
                }
                                
                if (d < _n) {
                    CHECK_DEBUG(kShowDebugNearFar, float4(1, 0, 0, 1))
                    return c1;
                }

                if (d >= _f) {
                    CHECK_DEBUG(kShowDebugNearFar, float4(0, 1, 0, 1))
                }

                float Ls = 1.0; // Assuming a constant light

                float transmittance = 1;  // assume no fog
                float4 colorFromFog = float4(0, 0, 0, 0);
                if (d > _n) {
                    transmittance = TransmittanceAtD(d-_n);
                    colorFromFog = (1 - transmittance) * Ls * _fogScattering * _fogColor;
                    CHECK_DEBUG(kShowDebugColorFromFog, colorFromFog)
                }
                
                float4 colorFromObj = c1 * transmittance;
                    // !! BUT: the formulation DOES NOT have the one-minus?!!
                c1 = colorFromObj + colorFromFog;
                
                // debug
                if (kShowDebugtransmittance == _flag) {
                    if (transmittance > 1.0)
                        c1 = float4(0, 0, 1, 1);
                    if (transmittance < 0.0)
                        c1 = float4(0, 0, 0, 1);
                    return float4(transmittance, transmittance, transmittance, 1);
                }

                return c1;
            }
            ENDCG
        }
    }
}
