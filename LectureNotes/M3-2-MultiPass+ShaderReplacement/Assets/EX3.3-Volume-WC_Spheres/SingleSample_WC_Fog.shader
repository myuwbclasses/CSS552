Shader "MyShaders/SingleSampleWC_Fog"
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

        // Look at Parker's project: https://github.com/CRCS-Graphics/2024_Parker_CloudRenderingProject/tree/master/Assets/Shaders
        //      this is forked under CRCS_Graphics/2024.Parker.CloudRenderingProject
        // look at DimensionalProfile.shader: Lines: 76 to 96}
        Pass
        {   
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../CommonShaderCode/RayFunctions.cginc"
                // Defines CameraFOV+Aspect

            #include "FogInclude.cginc"
                // Defines DEBUG macros"

            float TrInSphere(float interval, float r) {  // Slide-17
                // interval: length of visible interval in the volume    
                // r: is the radius of the sphere
                //
                // Refer to slide-17: 
                //      assume sigma-t is a constant: _extinctionCoefficient
                //      delta is the length of the interval (in this case, a ratio)
                float delta = interval/r; 
                float tau = delta * _extinctionCoefficient;
                return exp(-tau);
                    // tau increases: transmittance drops off slower (more transparent fog)
                    // tau decreases: transmittance drops off faster (denser fog)
            }

            // from point p through the sphere, each position to lightPos, 
            // how much transmittance is there?
            // This is trying to approximate the Lscat of Slide-15
            float ComputeTrToLight(float3 p, Sphere s, float3 lightPos) {
                // from point p to lightPos, how much transmittance is there?
                Ray lightRay;
                lightRay.origin = p;
                lightRay.direction = normalize(lightPos - p);

                SphereHit h = raySphereIntersect(lightRay, s);
                if (h.hit) {
                    float interval = h.exit; // assume light is outside of the sphere
                    return TrInSphere(interval, s.radius);
                            // This TrToLight should be used to illuminate and compute c1 geometric objects
                            // This is assuming TrToLight does not change along the lightRay direction
                            //      The correct way is to sample multiple points along the light ray
                } else {
                    return 0;   // This is an error?! Should not happen!
                }
            }

            // Attempt to implement Slide-11 in this time in WC
            // 
            //    Lo is what we read from the texture map (color of visible object)
            //    Tr(c,p) is TrAlongRay: assumed to be constant, taking at a simple point: VisiblePoint
            //          If object is visible: VisiblePoint = point on object
            //          Else: VisiblePoint = mid-point of the volume interval
            //    Lscat is TrToLight
            //          The integral is approximated by taking one sample in the volume interval
            //          Taken at the VisiblePoint
            //    Tr(c,c-vt): assume to be simply 1-Tr(c,p)
            //   
            //   
            float4 frag (v2f fromV) : SV_Target
            {   
                float4 c1 = tex2D(_MainTex, fromV.uv);
                float4 x = tex2D(_DepthTexture, fromV.uv);
                float d = x.a;  // alpha channel is view distance (in WC) of the pixel from the camera 

                CHECK_DEBUG(kShowDebugNoVolume, c1)

                DEBUG_DEPTH

                if (d <= 0) 
                    d = kVeryFar;  // background depth
            
                float2 normalizedPixelCoord = (fromV.uv - 0.5) * 2.0;

                Ray r;
                r.origin = getCameraOriginInWorld();
                r.direction = getPixelRayDirInWorld(normalizedPixelCoord);

                Sphere s;
                // How much of eye-ray is in volume V1
                s.center = V1_center;
                s.radius = V1_radius;
                SphereHit h = raySphereIntersect(r, s);

                float TrToLight = 1; // transmittance along light ray, assumed fully visible
                float TrAlongRay = 1;  //  transmittance along eye ray, assume fully visible (no volume)
                if (h.hit) {  // ray can see the volume, now, determine if the visible point is in front or behind the sphere
                    float3 visiblePtInVolume;
                    if ((h.enter < d)) {  // enter the volume first
                        float interval = h.exit - h.enter; // assume the entire volume is in front of the visible point
                        if (h.exit > d) { 
                            // visible point is within the volume
                            interval = d - h.enter;
                            visiblePtInVolume = r.origin + d * r.direction;  // seeing a pt inside the volume
                        } else {
                            visiblePtInVolume = r.origin + (h.enter + (0.5 * interval)) * r.direction;  
                                // for illumination use center point of the volume interval
                        }

                        {
                            float g = 0.5 * interval / s.radius;
                            CHECK_DEBUG(kShowVisibleVolumeDepth, float4(g, g, g, 1))
                        }

                        TrAlongRay = TrInSphere(interval, s.radius);

                        // Now do light
                        // Transmitttance from visiblePtInVolume to light
                        TrToLight = ComputeTrToLight(visiblePtInVolume, s, _FogLightPos);
                        
                    } // else of if (h.enter < d)
                        // volume blocked by geometry, cannot see volume
                        // TrAlongRay = 1; // nothing is blocking the object
                    
                }  // if (h.hit)                
                CHECK_DEBUG(kShowDebugTrAlongRay, float4(TrAlongRay, TrAlongRay, TrAlongRay, 1))             

                CHECK_DEBUG(kShowDebugTrToLight, float4(TrToLight, TrToLight, TrToLight, 1))

                // Taking one sample in the volume, 
                // The integral of Slide-15: colorOfFog
                //    Sigma-S = _fogColor * _fogScattering
                float4 colorOfFog = (1-TrAlongRay) * TrToLight *_fogScattering * _fogColor;

                CHECK_DEBUG(kShowFogColor, colorOfFog)

                float4 objColorInFog = TrAlongRay * c1;
                CHECK_DEBUG(kShowObjColorWithFogTr, objColorInFog)
                
                // At this point c1 (from the texture) is Lo of Eqn 3.3 (Page 11)
                c1 = objColorInFog + colorOfFog;
                
                // finally
                return c1;
            }
            ENDCG
        }
     }
}