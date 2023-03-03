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
            float _fogDensity;   // extinction coefficient (or density)
            float4 _fogColor;
            float _n, _f;
            sampler2D _DepthTexture;   // from our own DepthShader

            // For fog modes and debugging
            uint _flag;
            static const int kShowDebugNear = 1;
            static const int kShowDebugBlend = 2;
            
            static const int kFlipBlend = 4;

            static const int kSamplesInVol = 0x800;
            static const int kSampleCountMask = 0x7F0;

            static const int kMaxVolSamples = 20;
            static const int kFogTypeUniform = 0x10000;
            static const int kFogTypePerlin =  0x20000;
            static const int kFogTypeFractal = 0x40000;

            #define CHECK_DEBUG(FLAG, DEBUG_ACTION) {   \
                if (_flag & FLAG)                       \
                    c1 = DEBUG_ACTION;                  \
            }

            int GetSamplesInVol() {
                return ((kSampleCountMask & _flag) >> 4);
            }

            #include "../EX3-NoiseFunction/PerlinNoise.cginc"

            float Uniform_FogDensity(float3 p, float d) {
                return exp(-_fogDensity * d);
            }

            float Perlin_FogDensity(float3 p, float d) {
                return exp(-(0.5*(perlinNoise(p)+1)) * _fogDensity * d);
            }

            float Fractal_FogDensity(float3 p, float d) {
                return exp(-FractalNoise(p, 6) * _fogDensity * d);
            }

            #define COMPUTE_FOG(TYPE) {                         \
                for (int i = 0; i < kMaxVolSamples; i++ ) {     \
                    if (i < s) {                                \
                        p1 += dir;                              \
                        blend *= TYPE##_FogDensity(p1, w);      \
                    }                                           \
                }                                               \
            }

            float4 frag (v2f fromV) : SV_Target
            {   
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 x = tex2D(_DepthTexture, fromV.uv);

                float d = x.a;  //  remember our DepthShader records distance to camera in the alpha channel

                if (d <= 0) {    // this is background
                    return _fogColor;
                }
                                
                if (d <= _n) {
                    CHECK_DEBUG(kShowDebugNear, float4(1, 0, 0, 1))
                    return c1;  
                }

                if (d > _f)
                    d = _f;
                
                int s = GetSamplesInVol();
                // split the distance d into s segments
                float seg = (d-_n) / (float) s;  // size of each segment
                float w = seg/(_f - _n);  // weight for each integration segment

                float3 dir = normalize(x.xyz - _WorldSpaceCameraPos);              
                float3 p1 = _WorldSpaceCameraPos + _n * dir;  // this is at _n

                dir *= seg;  // vector of each segment
                // now, scale the position and size according to (_f - _n) <-- assume this is the world size
                p1 *= 1/(_f - _n);

                p1 += dir;  // seg-length along view direction into the fog

                float blend = 1;
                if (_flag & kFogTypePerlin)
                    COMPUTE_FOG(Perlin)
                else if (_flag & kFogTypeFractal)
                        COMPUTE_FOG(Fractal)
                    else
                        COMPUTE_FOG(Uniform)

                if (_flag&kFlipBlend) 
                    c1 = c1 * blend + _fogColor * (1-blend);
                else
                    c1 = c1 * (1-blend) + _fogColor * blend;
                
                CHECK_DEBUG(kShowDebugBlend, float4(blend, blend, blend, 1))

                return c1;
            }
            ENDCG
        }
    }
}
