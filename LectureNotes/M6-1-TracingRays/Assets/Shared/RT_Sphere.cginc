#ifndef RT_SPHERE
#define RT_SPHERE

int InSphere(float3 p) {
    float d = 0.99 * length(p - _TheCenter.xyz);
            // Make sure it is slightly outside
    return (d < _TheRadius);
}

// returns color (rgb) of the sphere and
//         reflectivity (a)
// 
// Assumption: material of Sphere is ID=0
// 
float4 ProcessSphere(Ray r, float4 pixelColor) {
    Sphere s;
    s.center = _TheCenter.xyz;
    s.radius = _TheRadius;

    float4 result = pixelColor;

    SphereHit h = raySphereIntersect(r, s);
    if (h.hit) {
        DEBUG_SHOW(kShowAmbient, _RTKa[0])
        DEBUG_SHOW(kShowDiffuse, _RTKd[0])
        DEBUG_SHOW(kShowSpecular, _RTKs[0])
        DEBUG_SHOW(kShowReflectivity, _RTReflectivity[0])

        // Intersection with sphere
        // Sphere's ID is 0
        float3 hitPt = r.origin + kTravelNotAsFar * h.enter * r.direction;
                // What is the kTravelNotAsFar doing?
        
        float3 n = normalize(hitPt - r.origin);
        float4 c = ShadePoint(hitPt, n, float2(0,0), kSphereID);

        result.rgb = result.rgb * (1-result.a) + c.rgb * result.a;
            // result.a is the reflectivie at the pixel
        result.a = result.a * c.a; // reflectivity decreases
    }
    return result;
}

#endif // RT_SPHERE