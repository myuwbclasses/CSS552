#ifndef SIMPLE_VERT
#define SIMPLE_VERT

// Vertex Shader
// Computes every thing under the sun that we can think of
Vert2Hull SimpleVert(appdata v)
{
    Vert2Hull o;
    
    o.pcPos = UnityObjectToClipPos(v.vertex); // Compute clip space position in the vertex shader
    o.ocPos = v.vertex.xyz; // Object space position, for convenience
    o.wcPos = mul(unity_ObjectToWorld, v.vertex).xyz; // Object space position, for convenience

    o.ocNormal = v.normal; // normal in OC space
    o.wcNormal = normalize(mul(o.ocNormal, (float3x3)unity_WorldToObject)); // World space normal

    o.uv = v.uv; // TRANSFORM_TEX(v.uv, _MainTex);
    o.uv1 = v.uv1; // TRANSFORM_TEX(v.uv1, _HgtTex);
    o.color = v.color;

    // For an actual application, the vert() function would need to
    // Compute parameters that can guide the tessellation process
    // to be associated with each vertex such that the Hull program 
    // can use those parameters in subsequent staages to compute the 
    // tessellation factors and the control points

    return o;
}

#endif // SIMPLE_VERT