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