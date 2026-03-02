#ifndef SUPPORT_FUNC
#define SUPPORT_FUNC


// Barycentric interpolation for different datatypes
float4 BCInterpolate(float4 p0, float4 p1, float4 p2, float3 bc) {
    return  p0 * bc.x + p1 * bc.y + p2 * bc.z;
}

float3 BCInterpolate(float3 p0, float3 p1, float3 p2, float3 bc) {
    return  p0 * bc.x + p1 * bc.y + p2 * bc.z;
}

float2 BCInterpolate(float2 p0, float2 p1, float2 p2, float3 bc) {
    return  p0 * bc.x + p1 * bc.y + p2 * bc.z;
}

float BCInterpolate(float p0, float p1, float p2, float3 bc) {
    return  p0 * bc.x + p1 * bc.y + p2 * bc.z;
}

// Assume front is CW
float3 TriangleNormal(float3 v0, float3 v1, float3 v2) {
    return normalize(cross(v1 - v0, v2 - v0));
}

#endif // SUPPORT_FUNC