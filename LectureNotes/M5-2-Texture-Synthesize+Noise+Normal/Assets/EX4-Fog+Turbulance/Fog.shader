// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Unlit/Fog"
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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
             float3 _CameraPosition;

            float _invWidth;    // in Normalized space
            float _invHeight;   // width and height of each pixel

            float3 _fogPosition;
            float _fogRadius;

            float4 _fogColor;
            float _fogExtinction;
            float _fogDropOff;
            float _fogScattering;

            sampler2D _DepthTexture;   // from our own DepthShader

            // For fog modes and debugging
            uint _flag;

            static const uint kShowDebugTau = 0x01 << 1;
            static const uint kShowDebugInterval = 0x01 << 2;
            static const uint kShowDebugTransmittance = 0x01 << 3;
            static const uint kShowDebugFogColor = 0x01 << 4;

            static const int kFogTypeUniform = 0x01 << 10;
            static const int kFogTypePerlin =  0x01 << 11;
            static const int kFogTypeFractal = 0x01 << 12;

            static const float kVeryFar = 99999;

            #define FLAG_IS_ON(FLAG) (_flag & FLAG)

            #define CONDITION_DEBUG(COND, FLAG, D_COLOR) {  \
                if (FLAG_IS_ON(FLAG)) {                     \
                    if (COND) {                             \
                        return D_COLOR;                     \
                    }                                       \
                }                                           \
            }

            #define CHECK_DEBUG(FLAG, DEBUG_COLOR) {        \
                if (FLAG_IS_ON(FLAG)) {                    \
                    return DEBUG_COLOR;                     \
                }                                           \
            }

            #include "./RayFunctions.cginc"
            #include "../EX3-NoiseFunction/PerlinNoise.cginc"

            // uv: for pixel color lookup, must be transformed into NDC: [-1 to 1]
            // distToEye: distance from the visible object to the fog
            float4 ComputeFogColor(float2 uv, float distToEye) {
                float2 pixelCoord = (uv - 0.5) * 2.0;

                Ray viewRay;
                viewRay.origin = getCameraOriginInWorld();
                viewRay.direction = getPixelRayDirInWorld(pixelCoord);

                Sphere fogVolume;
                fogVolume.center = _fogPosition;
                fogVolume.radius = _fogRadius;

                float4 fogColor = float4(0, 0, 0, 1);
                SphereHit h = raySphereIntersect(viewRay, fogVolume);
                if (h.hit) {                    
                    if (h.enter < distToEye) { // ray entered torch before hitting visible object
                        float transmittance = 1;
                        float tau = 0;
                        // Assuming eye is outside of torch
                        float volInterval = h.exit - h.enter;  // assume nothing in the torch
                        if (h.exit > distToEye) { // object inside the torch
                            volInterval = distToEye - h.enter;
                        }
                        tau = _fogExtinction * (volInterval / (0.5 * _fogRadius)); // normalize by max possible interval (when ray goes through center of torch)

                        // Mudulate Tau
                        // Assumption: accumulated Tau for the entire interval is ...
                        float3 samplePt = viewRay.origin + h.enter * viewRay.direction; // the point where ray enters the fog volume
                        samplePt -= fogVolume.center; // transform to local space of the torch for noise sampling
                        
                        if (FLAG_IS_ON(kFogTypeUniform)) {
                            tau = smoothstep(0, 1, pow(tau, _fogDropOff)); // smooth step to avoid harsh boundary when ray just touches the torch
                        } else if (FLAG_IS_ON(kFogTypePerlin)) {
                            tau *= 0.8 * (perlinNoise(samplePt) + 1) * 0.2; // map perlin noise from [-1, 1] to [0, 1]
                        } else if (FLAG_IS_ON(kFogTypeFractal)) {
                            tau *= FractalNoise(samplePt, 6);
                        }

                        transmittance = exp(-tau);  // Beer-Lambert Law
                        fogColor.rgb = (1-transmittance) * _fogScattering * _fogColor; // simple model for in-scattering
                        fogColor.a = transmittance;
                        
                        CHECK_DEBUG(kShowDebugTau, float4(tau, tau, tau, 1))
                        CHECK_DEBUG(kShowDebugInterval, float4(volInterval/(2*_fogRadius), volInterval/(2*_fogRadius), volInterval/(2*_fogRadius), 1))
                        CHECK_DEBUG(kShowDebugTransmittance, float4(transmittance, transmittance, transmittance, 1))
                        CHECK_DEBUG(kShowDebugFogColor, fogColor)
                    }
                }
                return fogColor;
            }

            float4 frag (v2f fromV) : SV_Target
            {   
                float4 x = tex2D(_DepthTexture, fromV.uv);
                float distToEye = x.a;  // x.a is distance of obj from camera
                if (distToEye <= 0.0) // seeing background
                    distToEye = kVeryFar;

                float4 fogColor = ComputeFogColor(fromV.uv, distToEye);
                float transmittance = fogColor.a;

                float4 c1 = tex2D(_MainTex, fromV.uv);
                c1 = c1 * transmittance + fogColor;
                return c1;
            }
            ENDHLSL
        }
    }
}
