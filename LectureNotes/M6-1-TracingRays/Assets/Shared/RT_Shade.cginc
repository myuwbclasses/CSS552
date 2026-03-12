#ifndef RT_SHADE
#define RT_SHADE

#include "Phong/MyInclude/PhongDataStruct.cginc"
// 
float4 ShadeHitPoint(ClosestHit h) {
    DEBUG_SHOW(kShowAmbient, _RTKa[h.index])
    DEBUG_SHOW(kShowDiffuse, _RTKd[h.index])
    DEBUG_SHOW(kShowSpecular, _RTKs[h.index])
    DEBUG_SHOW(kShowReflectivity, _RTReflectivity[h.index])

    DataForFragmentShader data;
    data.vertex = float4(0, 0, 0, 1);  // not used
    data.uv = h.uv;  // for now, cannot do this!
    data.normal = h.n;
    data.worldPos = h.pt;

    _Ka = _RTKa[h.index];
    _Kd = _RTKd[h.index];
    _Ks = _RTKs[h.index];
    _Specularity = _RTSpecularity[h.index];

    float4 c = PhongWithLights(data);
    c.a = _RTReflectivity[h.index];

    return c;
}

// 
float4 ShadePoint(float3 pt, float3 n, float2 uv, int index) {
    ClosestHit h;
    h.hit = true;
    h.index = index;
    h.pt = pt;
    h.n = n;
    h.uv = uv;
    
    return ShadeHitPoint(h);
}

#endif // RT_SHADE