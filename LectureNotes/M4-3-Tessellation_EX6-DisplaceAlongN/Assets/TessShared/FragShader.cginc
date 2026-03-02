#ifndef FRAG_SHADER
#define FRAG_SHADER

#include "TessControlFlags.cginc"
// Assume: Defined else where
//          kUseDirectionalLight and 
//          kUsePointLight 
//          _MainTex

// Fragment Shader
float4 Frag(Geom2Frag i) : SV_Target
{
    // directional light direction
    float3 lightDir = normalize(_LightInfo - i.wcPos); // in WC, and point light
    if (ModeIsSet(kUseDirectionalLight)) {
        lightDir = normalize(_LightInfo); // in WC, and directional light
    }
    // conpute diffuse
    float diff = max(dot(i.wcNormal, lightDir), 0.0);
    float4 texColor = tex2D(_MainTex, i.uv);
    if (ModeIsSet(kShowShadedTexture))
        return texColor * diff;
    if (ModeIsSet(kShowUV))
        return float4(i.uv, 0.0, 1.0);
    if (ModeIsSet(kShowNormal))
        return float4(i.wcNormal, 1.0);
    if (ModeIsSet(kShowLightDir))
        return float4(lightDir, 1.0);
    if (ModeIsSet(kShowNdotL))
        return float4(diff, diff, diff, 1.0);
    if (ModeIsSet(kShowVertexColor))
        return i.color;
    if (ModeIsSet(kShowUnshadedTexture))
        return texColor;
    
    return float4(1.0, 0.0, 0.0, 1.0); // What is going on?
}

#endif // FRAG_SHADER