Shader "MyShaders/MultiSample_WC_Fog"
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
            float _vSampleStepSize;  // step size for volume sampling
            int _NoiseFrequency;   // frequency for perlin noise
            float _NoiseOffset;    // offset for perlin noise
            float _NoiseRange;     // range for perlin noise


            #include "./PerlinNoise.cginc"
                // For perline noises

            // Perline noise function remapped to [NoiseOffset, NoiseOffset+NoiseRange]
            // This noise is used to create varying density within the volume (by modulating extinction coefficient)
            // a zero of modulating extinction coefficient will create fully transparent region, looks bad
            // so we remap the noise to a user defined range
            float MyNoise(float3 p) {
                float n = 1;
                if (_NoiseFrequency > 0) {
                    n = perlinNoise(p);
                    if (_NoiseFrequency > 1) {
                        float n2 = perlinNoise(p * 2.0);
                        n += n2 * 0.5;
                        if (_NoiseFrequency > 2) {
                            float n3 = perlinNoise(p * 4.0);
                            n += n3 * 0.25;
                        }
                    }
                }
                return  (_NoiseRange * n) + _NoiseOffset;  
            }

            // Exactly the same as previous TrInSphere, but with noise modulation of extinction coefficient
            float TrForInterval(float3 p, float interval, float totalSize) {  // Slide-17
                // p: is provided for sampling noise
                // interval: length of visible interval in the volume
                // r: is the radius of the sphere
                //
                // Refer to slide-17: 
                //      assume sigma-t is a constant: _extinctionCoefficient
                //      delta is the length of the interval (in this case, a ratio)
                float delta = interval/totalSize; 
                float tau = delta * MyNoise(p) * _extinctionCoefficient; 

                return exp(-tau);
                    // tau increases: transmittance drops off slower (more transparent fog)
                    // tau decreases: transmittance drops off faster (denser fog)
            }

            // This function approximates the integral of Slide-15
            // the intrervalLen is the length of the volume segment along the eye ray
            // entry is the entry point into the volume
            // samples are taken at every _vSampleStepSize along the eye ray
            // only one samnple is taken along the light ray for each sample point in the volume
            // return color.a is the accumulated transmittance
            float4 ColorOfVolume(float3 entry, float intervalLen, float3 dir, Sphere volume) {
                float sampledLen = _vSampleStepSize/2;
                float3 p = entry + 0.001 * dir; 
                    // *** p should be randomly positioned within the sampledLen
                    // For now, always perform first point to be right inside
                    
                float accumTrAlongRay = 1; // along the eye ray
                        // For accumulating effective transmittance through the volume
                         
                float accumTrToLight = 0;  
                    // this is to record the integration term Slide-21

                float n = 0;    // total number of samples taken
                Ray lightRay;
                do { 
                    float3 trNoisePt = p; // - volume.center; // this anchors the noice to the sphere
                            // otherwise, when the sphere moves, the noise pattern will change
                    float tr = TrForInterval(trNoisePt, _vSampleStepSize, volume.radius); 
                            // transmittance for this small segment along eye ray
                            // This is Tr(c,c-vt) of Slide-15

                    lightRay.origin = p;
                    lightRay.direction = normalize(_FogLightPos - p);
                    SphereHit h = raySphereIntersect(lightRay, volume);
                    
                    // h can be false when the sample position is just outside
                    if ( (h.hit) && (h.inside) ) {    
                        accumTrAlongRay *= tr;  // accumulating the transmittance along visible ray
                            // Note: exp(a+b) = exp(a)*exp(b)
                            // we are sampling one volume interval at a time, so multiply the transmittance

                        float interval = h.exit; 
                                    // Remember light is assumed to be outside of the sphere
                                    // And, current visible point is inside the sphere
                                    // So, distance to exist the sphere is simply the interval
                        float3 lgtNoisePt = trNoisePt + 
                                            lightRay.direction * 0.5 * interval;
                                    // Assume light sample point is in the middle of the interval
                        float trToLight = TrForInterval(lgtNoisePt, interval, volume.radius);
                                    // trToLight is Lcast of slide-15

                        accumTrToLight += (accumTrAlongRay * trToLight);  
                                // This is: Tr(c, c-vt) * Lscat
                        n = n + 1.0;
                    }
                    sampledLen += _vSampleStepSize;
                    p = entry + sampledLen * dir;   // next sample point
                } while (sampledLen < intervalLen);

                accumTrToLight /= n;    
                    // we are approximating the integral with finite samples
                    // so we normalize it by the number of samples taken
                    // this is a rough approximation, the normalization factor
                    // is probably not a linear function of n
                CHECK_DEBUG(kShowDebugTrToLight, float4(accumTrToLight, accumTrToLight, accumTrToLight, 0))

                float4 c;
                 c.rgb = (1 - accumTrAlongRay) * accumTrToLight * _fogColor * _fogScattering;
                 c.a = accumTrAlongRay;
                return c;
            }
            
            // Attempt to implement Slide-11 with multiple samples along the eye ray
            // 
            //    Lo is what we read from the texture map (color of visible object)
            //    Tr(c,p) is TrAlongRay: assumed to be constant, going to accumulate with multiple samples
            //    FogColor: is going to be approximated from multiple samples
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

                // 
                float TrAlongRay = 1;
                float4 colorOfFog = float4(0, 0, 0, 1);
                if (h.hit) {  // ray can see the volume, now, determine if the visible point is in front or behind the sphere
                    float3 entryPt = r.origin + h.enter * r.direction;
                    if ((h.enter < d)) {  // enter the volume first
                        float interval = h.exit - h.enter; // assume the entire volume is in front of the visible point
                        if (h.exit > d) { 
                            // visible point is within the volume
                            interval = d - h.enter;
                        } 

                        {
                            float g = 0.5 * interval / s.radius;
                            CHECK_DEBUG(kShowVisibleVolumeDepth, float4(g, g, g, 1))
                        }

                        colorOfFog = ColorOfVolume(entryPt, interval, r.direction, s);
                        TrAlongRay = colorOfFog.a; 
                        
                    } else { // else of if (h.enter < d)
                        // volume blocked by geometry, cannot see volume
                    }
                    // TrAlongRay = 1;  For debugging 
                }  

                CHECK_DEBUG(kShowDebugTrAlongRay, float4(TrAlongRay, TrAlongRay, TrAlongRay, 1))
                
                CHECK_DEBUG(kShowFogColor, colorOfFog)

                float4 objColorInFog = c1 * TrAlongRay;
                CHECK_DEBUG(kShowObjColorWithFogTr, objColorInFog)
                
                // At this point c1 (from the texture) is Lo of Eqn 3.3 (Page 11)
                c1 = objColorInFog + colorOfFog;
                
                return c1;
            }

            ENDCG
        }
     }
}