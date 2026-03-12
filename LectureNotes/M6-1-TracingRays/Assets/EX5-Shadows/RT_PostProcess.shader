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

            #include "../Shared/RT_MacrosAndConst.cginc"
            #include "../Shared/Phong/MyInclude/PhongDataStruct.cginc"
            #include "../Shared/Phong/MyInclude/MyMaterial.cginc"
            #include "../Shared/Phong/MyInclude/MyLights.cginc"

            #include "../Shared/RayFunctions.cginc"
            
            #define RT_SHADOW
            #include "../Shared/RT_Intersect.cginc"
            #include "../Shared/Phong/MyInclude/MyPhong.cginc"
            
            #include "../Shared/RT_Shade.cginc"
            #include "../Shared/RT_Sphere.cginc"
            #include "../Shared/RT_Triangle.cginc"

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
                    c = ShadeHitPoint(h);
                } 
                  
                if (IsActive(kRayTraceShadow)) {
                    // get some sense of shadow
                    // let's adjust the color by how much light source this object can see ...
                    // this is HACK, not real (as adjusting one light's intensity will not change the illuminatation
                    // properly ... but, it is better than nothing, and it is a good way to verify shadow ray is working)
                    // get some sense of shadow
                    float visible = 0;
                    float count = 0;
                    for (int i = 0; i < kNumLights; i++) {
                        if (LightState[i] != eLightOff) {
                            visible += PercentLightVisible(p, n, i);
                            count += 1;
                        }
                    }
                    pixelColor.rgb *= (visible/count);
                }
                pixelColor.rgb = pixelColor.rgb * (1 - pixelColor.a) + c.rgb * pixelColor.a;

                return pixelColor;
            }
            ENDHLSL
        }
    }
}