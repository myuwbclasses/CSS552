#ifndef _RAYCAST_CGINC_
#define _RAYCAST_CGINC_

// Copied and modified from Parker's Thesis work

// Must be supplied by our own script (WC_FogControl.cs)
float _CameraFOV;     
float _CameraAspect;  // assuming FOV is in the vertical direction


//Struct Definitions
struct Ray {
    float3 origin;
    float3 direction;
};

struct Sphere {
    float3 center;
    float radius;
};

struct SphereHit {
    int hit;
    int inside;
    float enter;    // distance along thes ray
    float exit;
};

struct Cube {
    float3 center;
    float3 size;
};

struct CubeHit {
    int hit;
    float enter;
    float exit;
};


// we know the view position origin is the camera position in world space
// divide by w to get the 3D position
float3 getCameraOriginInWorld(){
    //Transform Camera Position to world space;
    float3 camOrigin = float3(0,0,0);
    float4 camWorldHomog = mul(unity_CameraToWorld, float4(camOrigin, 1.0));
    float3 camWorld = camWorldHomog.xyz / camWorldHomog.w;
            // size of the world comes from the w-component
    return camWorld;
}

// uv is pixel position in normalized space
float3 getPixelRayDirInWorld(float2 uv) {
    //Move uv to center
    // uv += float2((1.0 / _ScreenParams.x) * 0.5 , (1.0 / _ScreenParams.y) * 0.5);
    // Here, we assume uv is in NDC ranging from -1 to +1

    //Account for aspect ratio and FOV
    uv *= tan(_CameraFOV * 0.5);
    uv.x *= _CameraAspect;

    //Get diretion 
    float3 dir = normalize(float3(uv.x, uv.y, 1.0));

    // Transform dir from persepctive to world space
    // Since we care about direction only, we can ignore translation
    // Dir transformation, is transpose-of-inverse
    //      Inverse of CameraToWorld is WorldToCamera
    //      Transpose is to multiply the dir on the left-side of the matrix
    float3 dirWorldHomog = mul(dir, (float3x3) unity_WorldToCamera);
    float3 dirWorld = normalize(dirWorldHomog.xyz);

    return dirWorld;
}

// https://en.wikipedia.org/wiki/Line%E2%80%93sphere_intersection
SphereHit raySphereIntersect(Ray ray, Sphere sphere){
    SphereHit hit = {0, 0, 0.0, 0.0};
    float3 oc = ray.origin - sphere.center;
    float b = 2. * dot(oc, ray.direction);
    float c = dot(oc, oc) - sphere.radius * sphere.radius;
    float d = b * b - 4. * c;

    if(d >= 0.0){
        float sqrtD = sqrt(d);
        float t0 = (-b - sqrtD) * 0.5;
        float t1 = (-b + sqrtD) * 0.5;
        if(t0 >= 0.0){
            hit.hit = 1;
            hit.inside = 0;
            hit.enter = t0;
            hit.exit = t1;
        }
        else if (t1 >= 0.0){
            hit.hit = 1;
            hit.inside = 1;
            hit.enter = 0;
            hit.exit = t1;
        }
    }
    return hit;
}

// https://en.wikipedia.org/wiki/Slab_method
CubeHit rayCubeIntersect(Ray ray, Cube cube){
    CubeHit hit = {0, 0.0, 0.0};
    float3 tMin = (cube.center - cube.size * 0.5 - ray.origin) / ray.direction;
    float3 tMax = (cube.center + cube.size * 0.5 - ray.origin) / ray.direction;

    if (tMin.x > tMax.x) { float tmp = tMin.x; tMin.x = tMax.x; tMax.x = tmp; }
    if (tMin.y > tMax.y) { float tmp = tMin.y; tMin.y = tMax.y; tMax.y = tmp; }
    if (tMin.z > tMax.z) { float tmp = tMin.z; tMin.z = tMax.z; tMax.z = tmp; }

    float tEnter = max(max(tMin.x, tMin.y), tMin.z);
    float tExit = min(min(tMax.x, tMax.y), tMax.z);

    if (tEnter > tExit) {
        return hit;
    }

    hit.hit = 1;
    hit.enter = max(0.0, tEnter);
    hit.exit = tExit;
    return hit;

}

#endif