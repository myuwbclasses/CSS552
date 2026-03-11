#ifndef MY_PHONG
#define MY_PHONG

// Must include:
//    MyLights
//    MyMaterial

#ifndef RT_SHADOW
// When no ray tracing is defined, all lights are always visible
    float PercentLightVisible(float3 wcPt, float3 n, int i) {
        return 1.0;
    }
#endif
float AngularDropOff(int lgt, float3 L) {
    float strength = 0.0;
    float cosL = dot(LightDirection[lgt], L);
    float num = cosL - SpotOuterCos[lgt];
    if (num > 0.0) {
        if (cosL > SpotInnerCos[lgt]) 
            strength = 1.0;
        else {
            float denom = SpotInnerCos[lgt] - SpotOuterCos[lgt];
            strength = smoothstep(0.0, 1.0, pow(num/denom, SpotDropOff[lgt]));
        }
    } 
    return strength;
}

float DistanceDropOff(int lgt, float dist) {
    float strength = 0.0;
    if (dist <= LightFarDist[lgt]) {
        if (dist <= LightNearDist[lgt])
            strength = 1.0;  //  no attenuation
        else {
            // simple quadratic drop off
            float n = dist - LightNearDist[lgt];
            float d = LightFarDist[lgt] - LightNearDist[lgt];
            strength = smoothstep(0.0, 1.0, 1.0-(n*n)/(d*d)); // square of distance blended attenuation
            // strength = smoothstep(0.0, 1.0, 1.0-(n)/(d)); // linear to distance 
            // strength = 1 - (n*n)/(d*d);  // simple linear
        }    
    }
    return strength;
}

float4 SpecularResult(float3 eyePos, float3 wpt, float3 N, float3 L) {
    float4 s = float4(0, 0, 0, 1);
    if (FlagIsOn(kSpecular)) {
        float3 V = normalize(eyePos - wpt);
        float3 H = (L + V) * 0.5;
        s = ((_Specularity+2)/(2 * UNITY_PI)) * pow(max(0.0, dot(N, H)), _Specularity);
        s *= float4(_Ks.xyz, 1);
    } 
    return s;
}

float4 DiffuseResult(float3 N, float3 L, float4 textureMapColor) {
    if (FlagIsOn(kDiffuse))
        return float4(_Kd.xyz, 1) * max(0.0, dot(N, L)) * textureMapColor;
    else 
        return float4(0, 0, 0, 1);
}

float4 PhongIlluminate(float3 eyePos, float3 wpt, int lgt, float3 N, float4 textureMapColor) {
    float aStrength = 1.0, dStrength = 1.0;
    float3 L; // light vector
    float dist = 0; // distance to light
    if (LightState[lgt] == eDirectionalLight) {
        L = LightDirection[lgt];
    } else {
        L = LightPosition[lgt] - wpt;
        dist = length(L);
        L = L / dist;  // normalization
    }
    if (LightState[lgt] == eSpotLight) {
        // spotlight: do angle dropoff
        if (FlagIsOn(kAngularAtten))
            aStrength = AngularDropOff(lgt, L);
    }
    if (LightState[lgt] != eDirectionalLight) {
        // both spot and point light has distance dropoff
        if (FlagIsOn(kDistanceAtten))
            dStrength = DistanceDropOff(lgt, dist);
    }
    float4  diffuse = DiffuseResult(N, L, textureMapColor);
    float4  specular = SpecularResult(eyePos, wpt, N, L);
    float4 result = PercentLightVisible(wpt, N, lgt) * aStrength * dStrength * LightIntensity[lgt] * LightColor[lgt] * (diffuse + specular);
    return result;
}

float4 PhongWithLights(DataForFragmentShader input) {
    float4 texColor = float4(1, 1, 1, 1);
    if (FlagIsOn(kTexture))
        texColor = tex2D(_MainTex, input.uv);

    float4 shadedResult = float4(0, 0, 0, 1);
    if (FlagIsOn(kAmbient))
        shadedResult = float4(_Ka.xyz, 1);

    for (int i = 0; i < kNumLights; i++) {
        if (LightState[i] != eLightOff)
            shadedResult += PhongIlluminate(_CameraPosition, input.worldPos, i, input.normal, texColor);
    }
    shadedResult.a = _Reflectivity;
        // Pass down to RT Post Process
    return shadedResult;
}

#endif //  MY_PHONG