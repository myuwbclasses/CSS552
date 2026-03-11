#include "Phong/MyInclude/PhongDataStruct.cginc"

TriangleHit rayTriangleIntersect(Ray r) {
    TriangleHit h;
    h.hit = 0;
    h.dist = 0;
    h.uv = float2(0, 0);
    h.bc = float3(0, 0, 0); 

    // Ray intersect at:
    //   t = (D - (n dot ray.origin))  /  (( n dot ray.direction))
    float3 n = _TriNormal.xyz;
    float nDotd = dot(n, r.direction);
    if (abs(nDotd) > 0.01) {  // not very small
        float t = (_TriD - (dot(n, r.origin))) / nDotd;
        if (t > 0) {
            float3 pt = r.origin + t * r.direction;
            float3 bc = ComputeBarycentric(pt);
        
            if (bcInTriangle(bc)) {
                // Intersect!
                float2 uv = bc.x * float2(0, 0) + bc.y * float2(1, 1) + bc.z * float2(1, 0);
                h.hit = kTriangleID;
                h.dist = t;
                h.uv = uv;
                h.bc = bc;
            }
        }
    }
    return h;
}

#ifdef RT_SHADOW
float PercentLightVisible(float3 wpt, float3 n, int lgt) {
    float visible = 1.0; // assume all visible
    if (IsActive(kRayTraceShadow)) {
        Ray r;
        r.origin = wpt + kPushInNormal * n;
        if (LightState[lgt] == eDirectionalLight) {
            r.direction = LightDirection[lgt];
        } else {
            r.direction = normalize(LightPosition[lgt] - wpt);
        }
        
        Sphere s;
        s.center = _TheCenter.xyz;
        s.radius = _TheRadius;
        SphereHit sh = raySphereIntersect(r, s);
        if (!sh.hit) {
            TriangleHit th = rayTriangleIntersect(r);
            if (th.hit) {
                visible = _RT_ShadowStrength;
            }
        } else {
            visible = _RT_ShadowStrength;
        }
    }
    return visible;
}
#endif

// Find the closest intersection position and the details
// This is the single most expensive function:
//      must intersect the ray with every single 
//      primitives out there!
ClosestHit ClosestHitPoint(Ray r) {
    // supposedly, iterate through every single object
    //   in the world and test for the closest intersection!
    // 
    ClosestHit h; 
    h.hit = 0;
    h.index = -1;
    h.pt = float3(0, 0, 0);
    h.n = float3(0, 1, 0);
    h.uv = float2(0, 0);
    float dist = kVeryFar;

    Sphere s;
    s.center = _TheCenter.xyz;
    s.radius = _TheRadius;
    SphereHit sh = raySphereIntersect(r, s);

    // Assume sphere hit is the closest
    if (sh.hit) {
        dist = sh.enter;
        h.hit = true;
        h.index = kSphereID;  // Triangle Index
        h.pt = r.origin + kTravelNotAsFar * dist * r.direction;
        h.uv = float2(0, 0);  // for now
        h.n = normalize(h.pt - s.center);
    }

    // Now work on triangle
    TriangleHit th = rayTriangleIntersect(r);
    if (th.hit) {
        if (th.dist < dist) {
            dist = th.dist;
            // Triangle is closer
            h.hit = true;
            h.index = kTriangleID;
            h.pt = r.origin + kTravelNotAsFar * dist * r.direction;
            h.n = _TriNormal;
            h.uv = th.uv;
        }
    }

    return h;
}