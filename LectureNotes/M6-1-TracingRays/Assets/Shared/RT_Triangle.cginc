#ifndef RT_TRIANGLE
#define RT_TRIANGLE

bool InTriangle(float3 p) {
    float3 bc = ComputeBarycentric(p);
    return bcInTriangle(bc);
}

// returns color (rgb) of the Triangle
//         reflectivity (a)
// 
// Assumption: material of Triangle is ID=1
// 
// Triangle UV:
//    uv[0] = new Vector2(0, 0);
//    uv[1] = new Vector2(1, 1);
//    uv[2] = new Vector2(1, 0);
// 
float4 ProcessTriangle(Ray r, float4 pixelColor) {
    float4 result = pixelColor;

    // Ray intersect at:
    //
    //   t = (D - (n dot ray.origin))  /  (( n dot ray.direction))
    float nDotd = dot(_TriNormal.xyz, r.direction);
    if (abs(nDotd) > 0.01) {  // not very small
        float t = (_TriD - (dot(_TriNormal.xyz, r.origin))) / nDotd;
        if (t > 0) {
            float3 pt = r.origin + kTravelNotAsFar * t * r.direction;
            float3 bc = ComputeBarycentric(pt);
        
            if (bcInTriangle(bc)) {
                DEBUG_SHOW(kShowAmbient, _RTKa[1])
                DEBUG_SHOW(kShowDiffuse, _RTKd[1])
                DEBUG_SHOW(kShowSpecular, _RTKs[1])
                DEBUG_SHOW(kShowReflectivity, _RTReflectivity[1])

                // Intersect!
                float2 uv = bc.x * float2(0, 0) + bc.y * float2(1, 1) + bc.z * float2(1, 0);
                float4 c = ShadePoint(pt, _TriNormal.xyz, uv, 1);
                c.a = _RTReflectivity[1];

                result.rgb = result.rgb * (1-result.a) + c.rgb * result.a;
                // result.a is the reflectivie at the pixel
                result.a = result.a * c.a; // reflectivity decreases
            }
        }
    }
    
    return result;
}

#endif // RT_TRIANGLE