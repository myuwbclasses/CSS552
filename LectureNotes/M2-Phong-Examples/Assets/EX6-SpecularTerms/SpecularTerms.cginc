#ifndef SPEC_TERM
#define SPEC_TERM

// Show flags ...
static const int kClassicPhong = 1 << 0;
static const int kBlinnPhong = 1 << 1;
static const int kNormalizedBlinnPhong = 1 << 2;
static const int kNormalD = 1 << 3;
static const int kGeom = 1 << 4;
static const int kFersnel = 1 << 5;
static const int kCT_NBlinnPhong = 1 << 6;
static const int kCT_D = 1 << 7;

uint _EX6_ShaderMode; // for encoding the above

float _Smoothness; // for CT_D: 1 is smooth (lambertian), 0 is highly glossed
float _Shinniness; // Specularity of the classical VdotR of NdotH
float _RefIndex;



inline int FlagIsOn(int flag) {
    return ((_EX6_ShaderMode & (flag)) != 0);
}

#define VdotR (max(0.0, dot(V, R)))
#define VdotH (max(0.0, dot(V, H)))
#define NdotH (max(0.0, dot(N, H)))
#define NdotV (max(0.0, dot(N, V)))
#define NdotL (max(0.0, dot(N, L)))
#define NdotH_NdotV (NdotH*NdotV)
#define NdotH_NdotL (NdotH*NdotL)

// G-term of classical Cook-Terrence
// Approximates microfacet normal direction distribution and self-shadowing of microfacets
// Simply copying from the paper: https://dl.acm.org/doi/10.1145/357290.357293
float Geom(float3 V, float3 H, float3 N, float3 L) {
    float denom = VdotH;
    if (denom == 0.0)
        return 1.0;
    denom = 1/denom;

    float r = min(NdotH_NdotV, NdotH_NdotL) * 2 * denom;

    return min(1, r);
}

// 
// F-term, the Fersnel term: https://en.wikipedia.org/wiki/Fresnel_equations
// Schlick’s Approximation
//      https://www.researchgate.net/publication/354065225_The_Schlick_Fresnel_Approximation
//      Assumption: 
//            n1 (_RefIndex) is refractive index of geometry
//            n2 is 1 (vacuum)
// Recall that: A material’s refractive index is the ratio of 
//              the speed of light in the vacuum to 
//              the speed of light in that material. 
//              Water's refractive index = 1.333
// Yes, opaque object can have a refractive index!
//         https://en.wikipedia.org/wiki/Refractive_index
//         plastic: around 1.x
//         metal: around 2.x
float Fersnel(float3 V, float3 N) {    
    float num = _RefIndex - 1;   // the 1 is vacuum's refractive index
    float den = _RefIndex + 1;
    float r = (num * num) / (den * den);
        // classical definition of reflectivity: normal incident of light
    float t = pow(1 - NdotV, 5);
    return r + (1-r) * t;
}

// Based on Cook-Torrence model, all of these are examples of D
// D: Is the distribution of microfacet's normal that oriented in the H direciton
// Classical Phong-term
float ClassicalPhong(float3 V, float3 H, float3 N, float3 L) {
    float3 R = reflect(-L, N);
    return pow(VdotR, _Shinniness);
}

float BlinnPhong(float3 V, float3 H, float3 N) {
    return pow(NdotH, _Shinniness);
}

// Ref: http://www.thetenthplanet.de/archives/255
float NormalizedBlinnPhong(float3 V, float3 H, float3 N) {
    float normalization = (_Shinniness+2) / (UNITY_PI * 2);
    return normalization * BlinnPhong(V, H, N);
}

// Simplified version of D from the paper
//   _Smoothness --> 0: p --> VERY large, highly gloss (shinny)
//   _Smoothness --> 1: p --> 0, flat (lambertian)
float NormalD(float3 V, float3 H, float3 N) {
    float a2 = _Smoothness * _Smoothness;
    float p = max(0.01, (2.0 / a2) - 2.0);
    float normalization = 1.0 / (UNITY_PI * a2);
    return normalization * pow(NdotH, p);
}

// The paper: https://dl.acm.org/doi/10.1145/357290.357293
float ShowSpecular(float3 V, float3 H, float3 N, float3 L) {
    float s = 0;
    if (FlagIsOn(kClassicPhong))
        s = ClassicalPhong(V, H, N, L);
    if (FlagIsOn(kBlinnPhong))
        s = BlinnPhong(V, H, N);
    if (FlagIsOn(kNormalizedBlinnPhong))
        s = NormalizedBlinnPhong(V, H, N);
    if (FlagIsOn(kNormalD))
        s = NormalD(V, H, N);
    if (FlagIsOn(kGeom))
        s = Geom(V, H, N, L);
    if (FlagIsOn(kFersnel))
        s = Fersnel(V, N);

    if (FlagIsOn(kCT_NBlinnPhong|kCT_D)) {
        float nv = NdotV;
        if (nv > 0.01) {
            // use the NormalizedBlinnPhong as D
            float D = 0;
            if (FlagIsOn(kCT_D))
                D = NormalD(V, H, N);
            else
                D = NormalizedBlinnPhong(V, H, N);
            
            s = Fersnel(V, N) * D * Geom(V, H, N, L) / (UNITY_PI * nv);
        } 
    }
    return s;
    
}

#endif // SPEC_TERM