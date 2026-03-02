#ifndef EX6_HEIGHT_GEOM
#define EX6_HEIGHT_GEOM

// Copied from "../../TessShared/EX2_Domain_Height.cginc" 
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
    float du = _MainTex_TexelSize.x * _NormalApproxMapLevel; // size of the map
    float dv = _MainTex_TexelSize.y * _NormalApproxMapLevel; // 
    float hu1 = ColorToHeight(tex2Dlod(_MainTex, float4(uv + float2(du, 0), 0, _NormalApproxMapLevel))); // height at (u + du, v)
    float hu2 = ColorToHeight(tex2Dlod(_MainTex, float4(uv - float2(du, 0), 0, _NormalApproxMapLevel))); // height at (u - du, v)
    float hv1 = ColorToHeight(tex2Dlod(_MainTex, float4(uv + float2(0, dv), 0, _NormalApproxMapLevel))); // height at (u, v + dv)
    float hv2 = ColorToHeight(tex2Dlod(_MainTex, float4(uv - float2(0, dv), 0, _NormalApproxMapLevel))); // height at (u, v - dv)
    float dhu = hu1 - hu2; // height difference in u direction
    float dhv = hv1 - hv2; // height difference in v direction
    return normalize(float3(-dhu, _HeightMapStrength, -dhv)); // Normal vector based on height differences
}   

// Receives output from the Domain Shader, invoked one-triangle at a time    
[maxvertexcount(3)]  // We will perform cleanup, not going to do more
void EX6Geom(triangle Domain2Geom input[3], inout TriangleStream<Geom2Frag> triStream)
{
    Geom2Frag o[3];

    if (ModeIsSet(kGeomComputeHeight)) {
        for (int i = 0; i < 3; i++) {
            o[i].uv = input[i].uv;
            o[i].color = input[i].color;

            // Position: we will re-sample the position based on the height map, and update the normal as well
            // recompute from OC space
            float3 oc = input[i].ocPos;
            oc.y += ComputeHeightFormMap(o[i].uv); // Sample the height map
            o[i].wcPos = mul(unity_ObjectToWorld, float4(oc, 1.0)).xyz; // Get the world space position from ocPos 
            o[i].pcPos = UnityObjectToClipPos(float4(oc, 1.0)); // Recompute the clip space position

            // Normal
            float3 n = ApproxNormalWithMap(o[i].uv);
            o[i].wcNormal = normalize(mul(n, (float3x3)unity_WorldToObject)); // Recompute the normal with slope approximation
        }
    } else {
        for (int i = 0; i < 3; i++) {
            o[i].pcPos = input[i].pcPos;
            o[i].wcPos = mul(unity_ObjectToWorld, float4(input[i].ocPos, 1.0)).xyz; // Get the world space position from ocPos
            o[i].wcNormal = normalize(mul(input[i].ocNormal, (float3x3)unity_WorldToObject)); // Recompute the normal with slope approximation
            o[i].uv = input[i].uv;
            o[i].color = input[i].color;
        }

    }

    // simply by-pass
    triStream.Append(o[0]);
    triStream.Append(o[1]);
    triStream.Append(o[2]);
    triStream.RestartStrip();
}
#endif // EX6_HEIGHT_GEOM