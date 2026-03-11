Shader "Unlit/RT_PostProcess"
{
    Properties
    {
    }
    
    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {   
            ColorMask RGB
                // .a us highjacked for reflectivity
                //    don't use it
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

            // The Triangle
            float4 _TheTriangle[3];
            float4 _TriNormal;  // Triangle Normal (normalized)
            float _TriD; // n . p - D = 0
            float _TriA2Inv;   // Inverse of 2x Triangle Area

            // The Sphere
            float4 _TheCenter;
            float  _TheRadius;    

            sampler2D _MainTex;
            sampler2D _RT_Position;
            sampler2D _RT_Normal;

            float _RT_ShadowStrength;
            float4 _RT_BackgroundColor;

            float3 _CameraPosition;

            // For fog modes and debugging
            // uint _ShaderMode; defined in MyPhone.cginc
            static const uint kShowRTObjectInRed = 0x01 << 10;
            static const uint kShowRTNormal = 0x01 << 11;
            static const uint kShowSphereInBlue = 0x01 << 12;
            static const uint kShowOnlySphereReflect = 0x01 << 13;
            static const uint kShowTriangleInGreen = 0x01 << 14;
            static const uint kShowOnlyTriangleReflect = 0x01 << 15;
            static const uint kShowAmbient = 0x01 << 16;
            static const uint kShowDiffuse = 0x01 << 17;
            static const uint kShowSpecular = 0x01 << 18;

            static const uint kRayTraceShadow = 0x01 << 20;

            static const float kReflectiveCode = 1.0;

            static const int kSphereID = 0;
            static const int kTriangleID = 1;
            
            static const float kVeryFar = 9999999.0;

            static const float kPushInNormal = 0.5;
            static const float kTravelNotAsFar = 0.99;

            #include "Phong/MyInclude/PhongDataStruct.cginc"
            #include "Phong/MyInclude/MyMaterial.cginc"
            #include "Phong/MyInclude/MyLights.cginc"

            #include "./RayFunctions.cginc"
            #include "RT_Macros.cginc"
            
            #define RT_SHADOW
            #include "RT_Intersect.cginc"

            #include "Phong/MyInclude/MyPhong.cginc"
            
            #include "RT_Shade.cginc"
            #include "RT_Sphere.cginc"
            #include "RT_Triangle.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // https://learn.microsoft.com/en-us/windows/win32/direct3d9/fog-formulas
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 pixelColor = tex2D(_MainTex, fromV.uv);
                float4 p = tex2D(_RT_Position, fromV.uv);
                
                if (!IsReflective(p)) 
                    return pixelColor;
                
                DEBUG_SHOW(kShowRTObjectInRed, float4(1, 0, 0, 1))
                                    
                float3 n = normalize(tex2D(_RT_Normal, fromV.uv).xyz);
                DEBUG_SHOW(kShowRTNormal, (0.5*float4(n,1.0)+0.5))

                CONDITION_DEBUG(InSphere(p), kShowSphereInBlue, float4(0,0,1,1))
                    // Verify Circle info is properly passed, and InSphere logic is correct

                CONDITION_DEBUG(InTriangle(p), kShowTriangleInGreen, float4(0, 1, 0, 1))
                    // Verify triangle info is passed correctly, and, BC is working
                
                float2 normalizedPixelCoord = (fromV.uv - 0.5) * 2.0;
                float3 viewRayDir = getPixelRayDirInWorld(normalizedPixelCoord);
                float3 refDir = reflect(viewRayDir, n);
                
                Ray r;
                r.origin = p.xyz + kPushInNormal * n; // what is kPushInNormal, why?
                r.direction = normalize(refDir);
                
                DEBUG_SHOW(kShowOnlySphereReflect, ProcessSphere(r, pixelColor))
                            // Verify sphere by itself is ok
                DEBUG_SHOW(kShowOnlyTriangleReflect, ProcessTriangle(r, pixelColor))
                            // Verify triangle by itself is ok

                ClosestHit h = ClosestHitPoint(r);
                float4 c = _RT_BackgroundColor;
                if (h.hit) {
                    float4 c = ShadeHitPoint(h);
                    pixelColor.rgb = pixelColor.rgb * (1 - pixelColor.a) + c.rgb * pixelColor.a;
                } else {
                    // get some sense of shadow
                    float visible = 0;
                    for (int i = 0; i < kNumLights; i++) {
                        if (LightState[i] != eLightOff)
                            visible += PercentLightVisible(p, n, i);
                    }
                    pixelColor.rgb *= visible;
                }
                
                return pixelColor;
            }
            ENDHLSL
        }
    }
}