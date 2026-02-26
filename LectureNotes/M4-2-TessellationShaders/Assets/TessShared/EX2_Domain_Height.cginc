#ifndef HEIGHT_DOMAIN
#define HEIGHT_DOMAIN

#include "../TessShared/EX1_Domain_Simple.cginc" // For the basic domain shader structure and interpolation function

float _HeightMapStrength; // Strength of height map displacement, defined in this file
int _HeightMapLevel; // Mipmap level to sample from (0: is the base map, e.g., 9, is 2^9 filtered result)
int _NormalApproxMapLevel; //which level to use for normal

half4 _MainTex_TexelSize; // x = 1/width, y = 1/height, z = width, w = height, defined in TessControlFlags.cginc
        // this is a unity variable, updated automatically by Unity

float ColorToHeight(float4 c) {
    return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b; // Convert to grayscale using luminosity method
            // https://en.wikipedia.org/wiki/Grayscale#:~:text=Grayscale%20images%2C%20are%20black%2Dand%2Dwhite%20or,to%20white%20at%20the%20strongest.
}

float ComputeHeightFormMap(float2 uv) {
    float4 c = tex2Dlod(_MainTex, float4(uv, 0, _HeightMapLevel)); // The float4, last 0 is lod (mipmap) at 0
    return ColorToHeight(c) * _HeightMapStrength; 
}

// Page 18 of Jeremy's report: https://drive.google.com/file/d/1b1bIooafvP9nOhcY1uLmUqowbGa6otN3/view
float3 ApproxNormalWithMap(float2 uv) {
    float du = _MainTex_TexelSize.x * _NormalApproxMapLevel;   // one texel in the map
    float dv = _MainTex_TexelSize.y * _NormalApproxMapLevel;   // 
                // Does not make sense to perform sampling in relation to the current screen size!!
                // _TexelSize.zw is the actual number of texels (int)
    float hu1 = ColorToHeight(tex2Dlod(_MainTex, float4(uv + float2(du, 0), 0, _NormalApproxMapLevel))); // height at (u + du, v)
    float hu2 = ColorToHeight(tex2Dlod(_MainTex, float4(uv - float2(du, 0), 0, _NormalApproxMapLevel))); // height at (u - du, v)
    float hv1 = ColorToHeight(tex2Dlod(_MainTex, float4(uv + float2(0, dv), 0, _NormalApproxMapLevel))); // height at (u, v + dv)
    float hv2 = ColorToHeight(tex2Dlod(_MainTex, float4(uv - float2(0, dv), 0, _NormalApproxMapLevel))); // height at (u, v - dv)
    float dhu = hu1 - hu2; // height difference in u direction
    float dhv = hv1 - hv2; // height difference in v direction
    float3 n = normalize(float3(-dhu, _HeightMapStrength, -dhv)); // Normal vector based on height differences
            // assuming du and dv are the same size ...  took away the 2* for the y-term
    // Aanswer based on formula, if we know the units should be:
    //     V1 = (2du, dhu, 0) and V2 = (0, dhv, 2dv),   NOTE: _HeightMapStrength is alredy applied to the height difference
    /// then normal is 
    //    -cross(V1, V2) or cross(V2, V1) = (-dhu * 2dv, 2du * 2dv, -2du * dhv)
    if (ModeIsSet(kNormalWithFormula)) {
        // For this example only, OC is simply 10*texel space
        du *= 10; // convert to OC space
        dv *= 10;
        n = normalize(float3(-dhu * 2 * dv, 4 * du * dv, -dhv * 2 * du )); 
                // issue: du dv are based on texel size, 
                //        height and _Strength: values are based on OC space, so the unit is not consistent, 
                // dv * _HeightMapStrength can give strange answer
                // What should be done is to convert du and dv to the unit in OC space
                // Not doing that here, so this formular is not usable in practice.
    }
    return n;
}   

[domain("tri")] // Input is a triangle:
// Our job is to compute the Information to be passed to Fragment shader
Domain2Frag HeightDomain(TessFactor i, // Results from the ComputeTessFactor function
    const OutputPatch<OutputFromHull, 3> cp, // Control points from the Hull shader
    float3 bary : SV_DomainLocation) // Barycentric coordinates of the generated vertex
{
    Domain2Frag o;

    if (ModeIsSet(kDomainComputeHeight)) {

        // Use barycentric to interpolate all vertex data
        o.uv = BCInterpolate(cp[0].uv, cp[1].uv, cp[2].uv, bary);
        o.uv1 = BCInterpolate(cp[0].uv1, cp[1].uv1, cp[2].uv1, bary);
        o.color = BCInterpolate(cp[0].color, cp[1].color, cp[2].color, bary);
        
        // We need to update OC psotion, so position and normal must be re-computed
        float3 oc = BCInterpolate(cp[0].ocPos, cp[1].ocPos, cp[2].ocPos, bary);
        o.ocPos = oc; // Pass the original OC position down (to Geometry and Fragment)
        
        // Now use the interpolated UV value to sample the texture map for height information
        oc.y += ComputeHeightFormMap(o.uv); // Sample the height map 

        o.wcPos = mul(unity_ObjectToWorld, float4(oc, 1.0)).xyz; // World space position
        o.pcPos = UnityObjectToClipPos(float4(oc, 1.0)); // Clip space position

        // Now we need to recompute the normal at this new position
        // We have seen this problem in Geometry shader, 
        // we can use the same method to compute the normal based on the triangle formed by the three vertices
        //

        float3 n;
        if (ModeIsSet(kNormalWithBC))
        {
            // Assume: 0, 1, 2 in CW, oc is in the triangle, so trianges are:
            //    T312 -- Across from V0
            //    T032 -- Across from V1 and 
            //    T013 -- Across from V2
            // index-3: is oc (the new vertex in the triange).
            float3 n312 = TriangleNormal(oc,          cp[1].ocPos, cp[2].ocPos);    // Across from bc.x (V0)
            float3 n032 = TriangleNormal(cp[0].ocPos, oc,          cp[2].ocPos);    // Across from bc.y (V1)
            float3 n013 = TriangleNormal(cp[0].ocPos, cp[1].ocPos, oc);             // Across from bc.z (V2)
            n = BCInterpolate(n312, n032, n013, bary); // Interpolate the normal based on the area of the three triangles
        } else {
            // Alternative: slope approximation, which is cheaper to compute, but less accurate
            n = ApproxNormalWithMap(o.uv);
        }
        o.wcNormal = normalize(mul(n, (float3x3)unity_WorldToObject)); // World space normal
        
    } else {
        o = SimpleDomain(i, cp, bary); // If not computing height, just use the simple domain shader to interpolate values
    }

    return o;
}
#endif // HEIGHT_DOMAIN